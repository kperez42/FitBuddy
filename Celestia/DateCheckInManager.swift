//
//  WorkoutCheckInManager.swift
//  FitBuddy
//
//  Manages workout check-in and safety features for in-person fitness meetups
//

import Foundation
import Combine
import CoreLocation

// MARK: - Workout Check-In Manager

@MainActor
class WorkoutCheckInManager: ObservableObject {

    // MARK: - Singleton

    static let shared = WorkoutCheckInManager()

    // MARK: - Published Properties

    @Published var activeCheckIns: [WorkoutCheckIn] = []
    @Published var scheduledCheckIns: [WorkoutCheckIn] = []
    @Published var pastCheckIns: [WorkoutCheckIn] = []
    @Published var hasActiveCheckIn: Bool = false

    // MARK: - Properties

    private var checkInTimers: [String: Timer] = [:]
    private let defaults = UserDefaults.standard

    // MARK: - Initialization

    private init() {
        loadCheckIns()
        Logger.shared.info("WorkoutCheckInManager initialized", category: .general)
    }

    // MARK: - Check-In Management

    /// Schedule a workout check-in
    func scheduleCheckIn(
        partnerId: String,
        partnerName: String,
        location: String,
        scheduledTime: Date,
        checkInTime: Date,
        emergencyContacts: [EmergencyContact]
    ) async throws -> WorkoutCheckIn {

        Logger.shared.info("Scheduling check-in for workout partner: \(partnerName)", category: .general)

        // Validate times
        guard scheduledTime > Date() else {
            throw FitBuddyError.invalidData
        }

        guard checkInTime > scheduledTime else {
            throw FitBuddyError.invalidData
        }

        // Create check-in
        let checkIn = WorkoutCheckIn(
            id: UUID().uuidString,
            partnerId: partnerId,
            partnerName: partnerName,
            location: location,
            scheduledTime: scheduledTime,
            checkInTime: checkInTime,
            emergencyContacts: emergencyContacts,
            status: .scheduled
        )

        // Add to scheduled list
        scheduledCheckIns.append(checkIn)
        saveCheckIns()

        // Schedule notifications
        try await scheduleCheckInNotifications(for: checkIn)

        // Track analytics
        AnalyticsManager.shared.logEvent(.workoutCheckInScheduled, parameters: [
            "partner_id": partnerId,
            "scheduled_time": scheduledTime.timeIntervalSince1970
        ])

        Logger.shared.info("Check-in scheduled successfully", category: .general)

        return checkIn
    }

    /// Start an active check-in
    func startCheckIn(checkInId: String) async throws {
        guard let index = scheduledCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw FitBuddyError.checkInNotFound
        }

        var checkIn = scheduledCheckIns.remove(at: index)
        checkIn.status = .active
        checkIn.activatedAt = Date()

        activeCheckIns.append(checkIn)
        hasActiveCheckIn = true
        saveCheckIns()

        // Start monitoring
        startMonitoring(checkIn: checkIn)

        // Notify emergency contacts
        await notifyEmergencyContacts(checkIn: checkIn, message: "Check-in started for workout with \(checkIn.partnerName)")

        // Track analytics
        AnalyticsManager.shared.logEvent(.workoutCheckInStarted, parameters: [
            "check_in_id": checkInId
        ])

        Logger.shared.info("Check-in started: \(checkInId)", category: .general)
    }

    /// Complete a check-in (user is safe)
    func completeCheckIn(checkInId: String) async throws {
        guard let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw FitBuddyError.checkInNotFound
        }

        var checkIn = activeCheckIns.remove(at: index)
        checkIn.status = .completed
        checkIn.completedAt = Date()

        pastCheckIns.insert(checkIn, at: 0)
        hasActiveCheckIn = activeCheckIns.isEmpty == false
        saveCheckIns()

        // Stop monitoring
        stopMonitoring(checkInId: checkInId)

        // Notify emergency contacts
        await notifyEmergencyContacts(checkIn: checkIn, message: "Check-in completed successfully")

        // Track analytics
        AnalyticsManager.shared.logEvent(.workoutCheckInCompleted, parameters: [
            "check_in_id": checkInId,
            "duration": checkIn.completedAt?.timeIntervalSince(checkIn.activatedAt ?? Date()) ?? 0
        ])

        Logger.shared.info("Check-in completed: \(checkInId)", category: .general)
    }

    /// Cancel a check-in
    func cancelCheckIn(checkInId: String) async throws {
        // Check scheduled list
        if let index = scheduledCheckIns.firstIndex(where: { $0.id == checkInId }) {
            var checkIn = scheduledCheckIns.remove(at: index)
            checkIn.status = .cancelled

            pastCheckIns.insert(checkIn, at: 0)
            saveCheckIns()

            Logger.shared.info("Scheduled check-in cancelled: \(checkInId)", category: .general)
            return
        }

        // Check active list
        if let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) {
            var checkIn = activeCheckIns.remove(at: index)
            checkIn.status = .cancelled

            pastCheckIns.insert(checkIn, at: 0)
            hasActiveCheckIn = activeCheckIns.isEmpty == false
            saveCheckIns()

            stopMonitoring(checkInId: checkInId)

            Logger.shared.info("Active check-in cancelled: \(checkInId)", category: .general)
            return
        }

        throw FitBuddyError.checkInNotFound
    }

    /// Trigger emergency alert
    func triggerEmergency(checkInId: String) async throws {
        guard let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw FitBuddyError.checkInNotFound
        }

        var checkIn = activeCheckIns[index]
        checkIn.status = .emergency
        activeCheckIns[index] = checkIn
        saveCheckIns()

        // Send emergency notifications
        await sendEmergencyAlerts(checkIn: checkIn)

        // Track analytics
        AnalyticsManager.shared.logEvent(.emergencyTriggered, parameters: [
            "check_in_id": checkInId
        ])

        Logger.shared.warning("Emergency triggered for check-in: \(checkInId)", category: .general)
    }

    // MARK: - Monitoring

    private func startMonitoring(checkIn: WorkoutCheckIn) {
        // Set up timer to check if user checks in on time
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.checkCheckInStatus(checkIn: checkIn)
            }
        }

        checkInTimers[checkIn.id] = timer
    }

    private func stopMonitoring(checkInId: String) {
        checkInTimers[checkInId]?.invalidate()
        checkInTimers.removeValue(forKey: checkInId)
    }

    private func checkCheckInStatus(checkIn: WorkoutCheckIn) async {
        // Check if check-in time has passed
        guard Date() > checkIn.checkInTime else { return }

        // If user hasn't checked in, trigger alert
        if checkIn.status == .active {
            Logger.shared.warning("Check-in overdue: \(checkIn.id)", category: .general)

            // Send warning notification
            await notifyEmergencyContacts(
                checkIn: checkIn,
                message: "⚠️ Check-in overdue for workout with \(checkIn.partnerName)"
            )

            // Trigger emergency after grace period
            let gracePeriod: TimeInterval = 15 * 60 // 15 minutes
            if Date().timeIntervalSince(checkIn.checkInTime) > gracePeriod {
                try? await triggerEmergency(checkInId: checkIn.id)
            }
        }
    }

    // MARK: - Notifications

    private func scheduleCheckInNotifications(for checkIn: WorkoutCheckIn) async throws {
        // Schedule reminder before workout
        // Schedule check-in reminder
        // In production, use UNUserNotificationCenter
        Logger.shared.debug("Scheduled notifications for check-in: \(checkIn.id)", category: .general)
    }

    private func notifyEmergencyContacts(checkIn: WorkoutCheckIn, message: String) async {
        for contact in checkIn.emergencyContacts {
            // In production, send SMS or call emergency contacts
            Logger.shared.info("Notifying emergency contact: \(contact.name)", category: .general)
        }
    }

    private func sendEmergencyAlerts(checkIn: WorkoutCheckIn) async {
        // Send emergency SMS/calls to all contacts
        // Include location, workout partner info, and emergency details
        for contact in checkIn.emergencyContacts {
            Logger.shared.warning("EMERGENCY: Notifying \(contact.name) about \(checkIn.partnerName)", category: .general)
        }

        // In production, also:
        // - Call emergency services if no response
        // - Send location updates
        // - Trigger loud alarm on device
    }

    // MARK: - Persistence

    private func loadCheckIns() {
        // Load from UserDefaults or database
        // In production, use Firestore or Core Data
    }

    private func saveCheckIns() {
        // Save to UserDefaults or database
    }

    // MARK: - Cleanup

    func cleanup() {
        // Cancel all timers
        for timer in checkInTimers.values {
            timer.invalidate()
        }
        checkInTimers.removeAll()
    }
}

// MARK: - Workout Check-In Model

struct WorkoutCheckIn: Identifiable, Codable {
    let id: String
    let partnerId: String
    let partnerName: String
    let location: String
    let scheduledTime: Date
    let checkInTime: Date
    let emergencyContacts: [EmergencyContact]
    var status: CheckInStatus
    var activatedAt: Date?
    var completedAt: Date?

    enum CheckInStatus: String, Codable {
        case scheduled
        case active
        case completed
        case cancelled
        case emergency
    }
}
