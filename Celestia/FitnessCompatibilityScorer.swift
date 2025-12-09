//
//  FitnessCompatibilityScorer.swift
//  FitBuddy
//
//  Calculates fitness compatibility scores between users for better matching
//

import Foundation

/// Calculates how compatible two users are for training together
class FitnessCompatibilityScorer {
    static let shared = FitnessCompatibilityScorer()

    private init() {}

    // MARK: - Score Weights

    private struct Weights {
        static let workoutTypes: Double = 0.25       // How similar workout preferences are
        static let fitnessLevel: Double = 0.20       // How close fitness levels are
        static let fitnessGoal: Double = 0.20        // Compatible fitness goals
        static let schedule: Double = 0.15           // Workout time compatibility
        static let gymLocation: Double = 0.10        // Same/nearby gym
        static let dietCompatibility: Double = 0.05  // Similar diet preferences
        static let generalInterests: Double = 0.05   // Shared interests beyond fitness
    }

    // MARK: - Main Scoring

    /// Calculate overall fitness compatibility score (0.0 to 1.0)
    func calculateCompatibility(currentUser: User, otherUser: User) -> FitnessCompatibilityResult {
        var scores: [String: Double] = [:]
        var matchReasons: [String] = []

        // 1. Workout Type Compatibility
        let workoutScore = calculateWorkoutTypeScore(currentUser: currentUser, otherUser: otherUser)
        scores["workoutTypes"] = workoutScore
        if workoutScore > 0.7 {
            let sharedWorkouts = getSharedWorkoutTypes(currentUser: currentUser, otherUser: otherUser)
            if !sharedWorkouts.isEmpty {
                matchReasons.append("Both enjoy \(sharedWorkouts.prefix(2).joined(separator: " & "))")
            }
        }

        // 2. Fitness Level Compatibility
        let levelScore = calculateFitnessLevelScore(currentUser: currentUser, otherUser: otherUser)
        scores["fitnessLevel"] = levelScore
        if levelScore > 0.8 {
            matchReasons.append("Similar fitness level")
        }

        // 3. Fitness Goal Compatibility
        let goalScore = calculateFitnessGoalScore(currentUser: currentUser, otherUser: otherUser)
        scores["fitnessGoal"] = goalScore
        if goalScore > 0.8 {
            matchReasons.append("Aligned fitness goals")
        }

        // 4. Schedule Compatibility
        let scheduleScore = calculateScheduleScore(currentUser: currentUser, otherUser: otherUser)
        scores["schedule"] = scheduleScore
        if scheduleScore > 0.7 {
            let sharedTimes = getSharedWorkoutTimes(currentUser: currentUser, otherUser: otherUser)
            if !sharedTimes.isEmpty {
                matchReasons.append("Available \(sharedTimes.first ?? "at similar times")")
            }
        }

        // 5. Gym Location Match
        let gymScore = calculateGymLocationScore(currentUser: currentUser, otherUser: otherUser)
        scores["gymLocation"] = gymScore
        if gymScore > 0.9 {
            matchReasons.append("Same gym")
        } else if gymScore > 0.5 {
            matchReasons.append("Nearby location")
        }

        // 6. Diet Compatibility
        let dietScore = calculateDietScore(currentUser: currentUser, otherUser: otherUser)
        scores["diet"] = dietScore

        // 7. General Interests
        let interestScore = calculateInterestScore(currentUser: currentUser, otherUser: otherUser)
        scores["interests"] = interestScore
        if interestScore > 0.5 {
            matchReasons.append("Shared interests")
        }

        // Calculate weighted total
        let totalScore =
            workoutScore * Weights.workoutTypes +
            levelScore * Weights.fitnessLevel +
            goalScore * Weights.fitnessGoal +
            scheduleScore * Weights.schedule +
            gymScore * Weights.gymLocation +
            dietScore * Weights.dietCompatibility +
            interestScore * Weights.generalInterests

        return FitnessCompatibilityResult(
            overallScore: totalScore,
            componentScores: scores,
            matchReasons: matchReasons,
            compatibilityLevel: CompatibilityLevel.from(score: totalScore)
        )
    }

    // MARK: - Component Scoring

    /// Calculate workout type compatibility (0.0 to 1.0)
    private func calculateWorkoutTypeScore(currentUser: User, otherUser: User) -> Double {
        let currentTypes = Set(currentUser.workoutTypes)
        let otherTypes = Set(otherUser.workoutTypes)

        guard !currentTypes.isEmpty, !otherTypes.isEmpty else {
            return 0.5 // Neutral if no preferences set
        }

        let intersection = currentTypes.intersection(otherTypes)
        let union = currentTypes.union(otherTypes)

        // Jaccard similarity coefficient
        return Double(intersection.count) / Double(union.count)
    }

    /// Get shared workout types between users
    private func getSharedWorkoutTypes(currentUser: User, otherUser: User) -> [String] {
        let currentTypes = Set(currentUser.workoutTypes)
        let otherTypes = Set(otherUser.workoutTypes)
        return Array(currentTypes.intersection(otherTypes))
    }

    /// Calculate fitness level compatibility (0.0 to 1.0)
    private func calculateFitnessLevelScore(currentUser: User, otherUser: User) -> Double {
        let levels = ["Beginner", "Intermediate", "Advanced", "Athlete"]

        guard let currentIndex = levels.firstIndex(of: currentUser.fitnessLevel),
              let otherIndex = levels.firstIndex(of: otherUser.fitnessLevel) else {
            return 0.5 // Neutral if levels not set
        }

        let levelDifference = abs(currentIndex - otherIndex)

        // Scoring:
        // Same level = 1.0
        // One level apart = 0.7 (still good - can help each other)
        // Two levels apart = 0.4 (challenging but possible)
        // Three levels apart = 0.2 (likely not a good match)
        switch levelDifference {
        case 0: return 1.0
        case 1: return 0.7
        case 2: return 0.4
        default: return 0.2
        }
    }

    /// Calculate fitness goal compatibility (0.0 to 1.0)
    private func calculateFitnessGoalScore(currentUser: User, otherUser: User) -> Double {
        // Define goal compatibility matrix
        let compatibleGoals: [String: Set<String>] = [
            "Weight Loss": ["Weight Loss", "General Fitness", "Endurance"],
            "Muscle Building": ["Muscle Building", "Strength Training", "Bodybuilding"],
            "Strength Training": ["Strength Training", "Muscle Building", "Powerlifting"],
            "Endurance": ["Endurance", "Marathon Training", "Cardio", "Weight Loss"],
            "General Fitness": ["General Fitness", "Weight Loss", "Endurance", "Flexibility"],
            "Flexibility": ["Flexibility", "Yoga", "General Fitness"],
            "Sports Training": ["Sports Training", "Endurance", "Strength Training"],
            "Rehabilitation": ["Rehabilitation", "Flexibility", "General Fitness"],
            "Bodybuilding": ["Bodybuilding", "Muscle Building", "Strength Training"],
            "Powerlifting": ["Powerlifting", "Strength Training", "Muscle Building"],
            "CrossFit": ["CrossFit", "General Fitness", "Strength Training", "Endurance"],
            "Marathon Training": ["Marathon Training", "Endurance", "Cardio"],
            "Yoga": ["Yoga", "Flexibility", "General Fitness"],
            "Cardio": ["Cardio", "Endurance", "Weight Loss"]
        ]

        let currentGoal = currentUser.fitnessGoal
        let otherGoal = otherUser.fitnessGoal

        // Same goal = perfect match
        if currentGoal == otherGoal {
            return 1.0
        }

        // Check if goals are compatible
        if let compatible = compatibleGoals[currentGoal], compatible.contains(otherGoal) {
            return 0.75
        }

        // Check reverse compatibility
        if let compatible = compatibleGoals[otherGoal], compatible.contains(currentGoal) {
            return 0.75
        }

        // Different goals but not incompatible
        return 0.3
    }

    /// Calculate schedule compatibility (0.0 to 1.0)
    private func calculateScheduleScore(currentUser: User, otherUser: User) -> Double {
        let currentTimes = Set(currentUser.preferredWorkoutTimes)
        let otherTimes = Set(otherUser.preferredWorkoutTimes)

        guard !currentTimes.isEmpty, !otherTimes.isEmpty else {
            return 0.5 // Neutral if no preferences set
        }

        let intersection = currentTimes.intersection(otherTimes)

        // At least one matching time slot is good
        if intersection.isEmpty {
            return 0.1 // Very low score - schedules don't align
        }

        // More overlapping time slots = better
        let overlapRatio = Double(intersection.count) / Double(min(currentTimes.count, otherTimes.count))
        return overlapRatio
    }

    /// Get shared workout times
    private func getSharedWorkoutTimes(currentUser: User, otherUser: User) -> [String] {
        let currentTimes = Set(currentUser.preferredWorkoutTimes)
        let otherTimes = Set(otherUser.preferredWorkoutTimes)
        return Array(currentTimes.intersection(otherTimes))
    }

    /// Calculate gym location compatibility (0.0 to 1.0)
    private func calculateGymLocationScore(currentUser: User, otherUser: User) -> Double {
        let currentGym = currentUser.gymLocation.lowercased().trimmingCharacters(in: .whitespaces)
        let otherGym = otherUser.gymLocation.lowercased().trimmingCharacters(in: .whitespaces)

        // No gym set
        guard !currentGym.isEmpty, !otherGym.isEmpty else {
            // Check distance as fallback
            if let currentLat = currentUser.latitude,
               let currentLon = currentUser.longitude,
               let otherLat = otherUser.latitude,
               let otherLon = otherUser.longitude {
                let distance = calculateDistance(lat1: currentLat, lon1: currentLon, lat2: otherLat, lon2: otherLon)
                // Score based on distance (0-50 miles)
                return max(0, 1.0 - (distance / 50.0))
            }
            return 0.3 // Neutral
        }

        // Same gym name
        if currentGym == otherGym {
            return 1.0
        }

        // Check if gyms contain similar keywords (chain gyms)
        let gymChains = ["planet fitness", "24 hour fitness", "la fitness", "gold's gym", "equinox",
                        "crunch", "anytime fitness", "orangetheory", "crossfit", "ymca", "lifetime"]

        for chain in gymChains {
            if currentGym.contains(chain) && otherGym.contains(chain) {
                return 0.8 // Same gym chain
            }
        }

        // Check location proximity if coordinates available
        if let currentLat = currentUser.latitude,
           let currentLon = currentUser.longitude,
           let otherLat = otherUser.latitude,
           let otherLon = otherUser.longitude {
            let distance = calculateDistance(lat1: currentLat, lon1: currentLon, lat2: otherLat, lon2: otherLon)
            // Within 5 miles is good
            if distance <= 5 {
                return 0.6
            } else if distance <= 15 {
                return 0.4
            }
        }

        return 0.2 // Different gyms, unknown proximity
    }

    /// Calculate diet compatibility (0.0 to 1.0)
    private func calculateDietScore(currentUser: User, otherUser: User) -> Double {
        guard let currentDiet = currentUser.diet,
              let otherDiet = otherUser.diet else {
            return 0.5 // Neutral if not set
        }

        if currentDiet == otherDiet {
            return 1.0
        }

        // Define compatible diets
        let compatibleDiets: [String: Set<String>] = [
            "Vegan": ["Vegan", "Vegetarian", "Plant-Based"],
            "Vegetarian": ["Vegetarian", "Vegan", "Pescatarian"],
            "Keto": ["Keto", "Low-Carb", "Paleo"],
            "Paleo": ["Paleo", "Keto", "Whole30"],
            "High-Protein": ["High-Protein", "Bodybuilding", "Keto"],
            "No Restrictions": ["No Restrictions", "Flexible", "High-Protein"]
        ]

        if let compatible = compatibleDiets[currentDiet], compatible.contains(otherDiet) {
            return 0.7
        }

        return 0.4
    }

    /// Calculate general interest compatibility (0.0 to 1.0)
    private func calculateInterestScore(currentUser: User, otherUser: User) -> Double {
        let currentInterests = Set(currentUser.interests)
        let otherInterests = Set(otherUser.interests)

        guard !currentInterests.isEmpty, !otherInterests.isEmpty else {
            return 0.5
        }

        let intersection = currentInterests.intersection(otherInterests)
        let union = currentInterests.union(otherInterests)

        return Double(intersection.count) / Double(union.count)
    }

    // MARK: - Helpers

    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusMiles = 3958.8

        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180

        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))

        return earthRadiusMiles * c
    }
}

// MARK: - Result Types

struct FitnessCompatibilityResult {
    let overallScore: Double           // 0.0 to 1.0
    let componentScores: [String: Double]
    let matchReasons: [String]         // Human-readable reasons
    let compatibilityLevel: CompatibilityLevel

    /// Get top compatibility reasons for display
    var topReasons: [String] {
        Array(matchReasons.prefix(3))
    }

    /// Formatted score percentage
    var scorePercentage: Int {
        Int(overallScore * 100)
    }
}

enum CompatibilityLevel: String {
    case excellent = "Excellent Match"
    case great = "Great Match"
    case good = "Good Match"
    case fair = "Fair Match"
    case low = "Limited Compatibility"

    static func from(score: Double) -> CompatibilityLevel {
        switch score {
        case 0.8...1.0: return .excellent
        case 0.65..<0.8: return .great
        case 0.5..<0.65: return .good
        case 0.35..<0.5: return .fair
        default: return .low
        }
    }

    var color: String {
        switch self {
        case .excellent: return "green"
        case .great: return "blue"
        case .good: return "purple"
        case .fair: return "orange"
        case .low: return "gray"
        }
    }

    var icon: String {
        switch self {
        case .excellent: return "flame.fill"
        case .great: return "star.fill"
        case .good: return "hand.thumbsup.fill"
        case .fair: return "figure.walk"
        case .low: return "questionmark.circle"
        }
    }
}
