//
//  PersonalizedOnboardingManager.swift
//  FitBuddy
//
//  Manages personalized onboarding paths based on user fitness goals and preferences
//  Adapts the onboarding experience to match user fitness intentions
//

import Foundation
import SwiftUI

/// Manages personalized onboarding experiences based on fitness goals
@MainActor
class PersonalizedOnboardingManager: ObservableObject {

    static let shared = PersonalizedOnboardingManager()

    @Published var selectedGoal: FitnessGoalType?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum FitnessGoalType: String, Codable, CaseIterable {
        case intensiveTraining = "intensive_training"
        case casualFitness = "casual_fitness"
        case socialWorkouts = "social_workouts"
        case competitiveTraining = "competitive_training"
        case exploreOptions = "explore_options"

        var displayName: String {
            switch self {
            case .intensiveTraining: return "Intensive Training Partner"
            case .casualFitness: return "Casual Workout Buddy"
            case .socialWorkouts: return "Social Fitness Groups"
            case .competitiveTraining: return "Competitive Training"
            case .exploreOptions: return "Open to all workout types"
            }
        }

        var icon: String {
            switch self {
            case .intensiveTraining: return "flame.fill"
            case .casualFitness: return "figure.walk"
            case .socialWorkouts: return "person.3.fill"
            case .competitiveTraining: return "trophy.fill"
            case .exploreOptions: return "star.fill"
            }
        }

        var description: String {
            switch self {
            case .intensiveTraining:
                return "Find dedicated partners for serious training goals"
            case .casualFitness:
                return "Looking for friendly workout companions"
            case .socialWorkouts:
                return "Join group fitness activities and classes"
            case .competitiveTraining:
                return "Train with athletes for competitions"
            case .exploreOptions:
                return "Exploring different workouts and activities"
            }
        }

        var color: Color {
            switch self {
            case .intensiveTraining: return .red
            case .casualFitness: return .orange
            case .socialWorkouts: return .blue
            case .competitiveTraining: return .purple
            case .exploreOptions: return .green
            }
        }
    }

    struct OnboardingPath {
        let goal: FitnessGoalType
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case profileDepth = "profile_depth"
            case photoQuality = "photo_quality"
            case bioOptimization = "bio_optimization"
            case fitnessMatching = "fitness_matching"
            case locationAccuracy = "location_accuracy"
            case verificationTrust = "verification_trust"
            case workoutSchedule = "workout_schedule"
        }
    }

    struct OnboardingPathStep {
        let id: String
        let title: String
        let description: String
        let importance: StepImportance
        let tips: [String]

        enum StepImportance {
            case critical
            case recommended
            case optional
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedGoal()
    }

    // MARK: - Goal Selection

    func selectGoal(_ goal: FitnessGoalType) {
        selectedGoal = goal
        recommendedPath = generatePath(for: goal)
        saveGoal()

        // Track analytics
        AnalyticsManager.shared.logEvent(.onboardingStepCompleted, parameters: [
            "step": "goal_selection",
            "goal": goal.rawValue,
            "goal_name": goal.displayName
        ])

        Logger.shared.info("User selected fitness goal: \(goal.displayName)", category: .onboarding)
    }

    // MARK: - Path Generation

    private func generatePath(for goal: FitnessGoalType) -> OnboardingPath {
        switch goal {
        case .intensiveTraining:
            return createIntensiveTrainingPath()
        case .casualFitness:
            return createCasualFitnessPath()
        case .socialWorkouts:
            return createSocialWorkoutsPath()
        case .competitiveTraining:
            return createCompetitiveTrainingPath()
        case .exploreOptions:
            return createExploreOptionsPath()
        }
    }

    private func createIntensiveTrainingPath() -> OnboardingPath {
        OnboardingPath(
            goal: .intensiveTraining,
            steps: [
                OnboardingPathStep(
                    id: "detailed_profile",
                    title: "Create Your Fitness Profile",
                    description: "Share your fitness goals, experience level, and training preferences",
                    importance: .critical,
                    tips: [
                        "Describe your current fitness level and goals",
                        "Add photos showing your training activities",
                        "Share your workout schedule and preferred gym"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_profile",
                    title: "Verify Your Profile",
                    description: "Build trust with verified photos",
                    importance: .critical,
                    tips: [
                        "Verified profiles get 2x more workout buddy requests",
                        "Shows you're serious about fitness partnerships",
                        "Takes less than 2 minutes"
                    ]
                ),
                OnboardingPathStep(
                    id: "fitness_preferences",
                    title: "Set Your Workout Preferences",
                    description: "Help us find compatible training partners",
                    importance: .recommended,
                    tips: [
                        "Select your preferred workout types",
                        "Set your training schedule availability",
                        "Specify your fitness level requirements"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .bioOptimization, .fitnessMatching, .workoutSchedule],
            recommendedFeatures: ["Training Videos", "Progress Tracking", "Verified Athletes"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "safety", "scrolling"]
        )
    }

    private func createCasualFitnessPath() -> OnboardingPath {
        OnboardingPath(
            goal: .casualFitness,
            steps: [
                OnboardingPathStep(
                    id: "fun_profile",
                    title: "Create Your Workout Profile",
                    description: "Show your personality and fitness interests",
                    importance: .critical,
                    tips: [
                        "Add photos of your favorite activities",
                        "Keep your bio friendly and approachable",
                        "Share what motivates you to stay active"
                    ]
                ),
                OnboardingPathStep(
                    id: "activities",
                    title: "Share Your Activities",
                    description: "Find buddies with similar interests",
                    importance: .recommended,
                    tips: [
                        "Select activities you enjoy or want to try",
                        "Be open to different workout styles",
                        "Show what makes fitness fun for you"
                    ]
                )
            ],
            focusAreas: [.photoQuality, .fitnessMatching, .locationAccuracy],
            recommendedFeatures: ["Quick Match", "Nearby Gyms", "Activity Suggestions"],
            tutorialPriority: ["scrolling", "matching", "messaging", "profile_quality"]
        )
    }

    private func createSocialWorkoutsPath() -> OnboardingPath {
        OnboardingPath(
            goal: .socialWorkouts,
            steps: [
                OnboardingPathStep(
                    id: "social_profile",
                    title: "Create Your Social Fitness Profile",
                    description: "Show what kind of workout buddy you'd be",
                    importance: .critical,
                    tips: [
                        "Highlight your favorite group activities",
                        "Share what fitness classes you enjoy",
                        "Be genuine and approachable"
                    ]
                ),
                OnboardingPathStep(
                    id: "location_activities",
                    title: "Share Location & Activities",
                    description: "Find fitness friends near you",
                    importance: .critical,
                    tips: [
                        "Add your city and preferred gyms",
                        "Select group activities you enjoy",
                        "Be specific about your schedule"
                    ]
                )
            ],
            focusAreas: [.fitnessMatching, .locationAccuracy, .bioOptimization, .workoutSchedule],
            recommendedFeatures: ["Group Classes", "Fitness Events", "Workout Meetups"],
            tutorialPriority: ["scrolling", "matching", "messaging", "profile_quality"]
        )
    }

    private func createCompetitiveTrainingPath() -> OnboardingPath {
        OnboardingPath(
            goal: .competitiveTraining,
            steps: [
                OnboardingPathStep(
                    id: "athlete_profile",
                    title: "Create Your Athlete Profile",
                    description: "Showcase your competitive background and goals",
                    importance: .critical,
                    tips: [
                        "Share your sport and competition history",
                        "Mention your training goals and timeline",
                        "Add action photos from training or events"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_athlete",
                    title: "Verify Your Profile",
                    description: "Build credibility with fellow athletes",
                    importance: .recommended,
                    tips: [
                        "Verification builds trust among serious athletes",
                        "Shows your commitment to training",
                        "Attracts dedicated training partners"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .fitnessMatching, .workoutSchedule],
            recommendedFeatures: ["Athlete Network", "Competition Calendar", "Performance Tracking"],
            tutorialPriority: ["profile_quality", "matching", "messaging"]
        )
    }

    private func createExploreOptionsPath() -> OnboardingPath {
        OnboardingPath(
            goal: .exploreOptions,
            steps: [
                OnboardingPathStep(
                    id: "basic_profile",
                    title: "Create Your Profile",
                    description: "Start with the basics and discover what works for you",
                    importance: .critical,
                    tips: [
                        "Add a few photos showing your interests",
                        "Write a brief bio about your fitness journey",
                        "Select activities you'd like to try"
                    ]
                ),
                OnboardingPathStep(
                    id: "explore",
                    title: "Start Exploring",
                    description: "Discover workout buddies and activities near you",
                    importance: .recommended,
                    tips: [
                        "Browse different workout partners",
                        "You can always update your preferences",
                        "Try different activities to find your fit"
                    ]
                )
            ],
            focusAreas: [.photoQuality, .bioOptimization, .fitnessMatching],
            recommendedFeatures: ["Discovery", "Activity Filters", "Workout Suggestions"],
            tutorialPriority: ["welcome", "scrolling", "matching", "messaging", "profile_quality"]
        )
    }

    // MARK: - Customizations

    func getCustomTips() -> [String] {
        guard let path = recommendedPath else { return [] }
        return path.steps.flatMap { $0.tips }
    }

    func shouldEmphasize(focusArea: OnboardingPath.FocusArea) -> Bool {
        guard let path = recommendedPath else { return false }
        return path.focusAreas.contains(focusArea)
    }

    func getPrioritizedTutorials() -> [String] {
        guard let path = recommendedPath else {
            return ["welcome", "scrolling", "matching", "messaging"]
        }
        return path.tutorialPriority
    }

    func getRecommendedFeatures() -> [String] {
        return recommendedPath?.recommendedFeatures ?? []
    }

    // MARK: - Persistence

    private func saveGoal() {
        if let goal = selectedGoal,
           let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedGoal() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let goal = try? JSONDecoder().decode(FitnessGoalType.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.FitnessGoalType) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("What's your fitness goal?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us find your perfect workout partners")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.FitnessGoalType.allCases, id: \.self) { goal in
                        GoalCard(goal: goal, isSelected: manager.selectedGoal == goal) {
                            withAnimation(.spring(response: 0.3)) {
                                manager.selectGoal(goal)
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(24)
            }

            // Continue Button
            if manager.selectedGoal != nil {
                Button {
                    if let goal = manager.selectedGoal {
                        onGoalSelected(goal)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.purple, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.05), Color.green.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GoalCard: View {
    let goal: PersonalizedOnboardingManager.FitnessGoalType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: goal.icon)
                            .font(.title2)
                            .foregroundColor(goal.color)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? goal.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? goal.color.opacity(0.2) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingGoalSelectionView { goal in
        print("Selected goal: \(goal.displayName)")
    }
}
