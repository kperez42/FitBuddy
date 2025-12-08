//
//  ConversationStarters.swift
//  FitBuddy
//
//  Service for generating smart workout conversation starters
//

import Foundation

// MARK: - Conversation Starter Model

struct ConversationStarter: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let category: StarterCategory

    enum StarterCategory {
        case sharedInterest
        case location
        case bio
        case fitness
        case generic
    }
}

// MARK: - Conversation Starters Service

class ConversationStarters {
    static let shared = ConversationStarters()

    private init() {}

    func generateStarters(currentUser: User, otherUser: User) -> [ConversationStarter] {
        var starters: [ConversationStarter] = []

        // Shared workout types
        let sharedWorkoutTypes = Set(currentUser.workoutTypes).intersection(Set(otherUser.workoutTypes))
        if let workoutType = sharedWorkoutTypes.first {
            starters.append(ConversationStarter(
                text: "I see you're into \(workoutType) too! What's your typical routine?",
                icon: "figure.run",
                category: .sharedInterest
            ))
        }

        // Shared interests (fitness activities)
        let sharedInterests = Set(currentUser.interests).intersection(Set(otherUser.interests))
        if let interest = sharedInterests.first {
            starters.append(ConversationStarter(
                text: "I noticed we both like \(interest)! How long have you been doing it?",
                icon: "star.fill",
                category: .sharedInterest
            ))
        }

        // Location-based (gym location)
        if let gymLocation = otherUser.gymLocation, !gymLocation.isEmpty {
            starters.append(ConversationStarter(
                text: "Do you usually work out at \(gymLocation)? I've been looking for training partners there!",
                icon: "mappin.circle.fill",
                category: .location
            ))
        } else if !otherUser.location.isEmpty {
            starters.append(ConversationStarter(
                text: "What's your favorite spot to work out in \(otherUser.location)?",
                icon: "mappin.circle.fill",
                category: .location
            ))
        }

        // Bio-based (fitness keywords)
        if !otherUser.bio.isEmpty {
            if otherUser.bio.lowercased().contains("marathon") || otherUser.bio.lowercased().contains("running") {
                starters.append(ConversationStarter(
                    text: "I saw you're into running! Are you training for any races?",
                    icon: "figure.run.circle",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("gym") || otherUser.bio.lowercased().contains("lift") {
                starters.append(ConversationStarter(
                    text: "Fellow gym enthusiast! What's your current training split?",
                    icon: "dumbbell",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("yoga") {
                starters.append(ConversationStarter(
                    text: "I noticed you're into yoga! Do you have a favorite style?",
                    icon: "figure.yoga",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("crossfit") {
                starters.append(ConversationStarter(
                    text: "CrossFit fan too! What's your favorite WOD?",
                    icon: "figure.cross.training",
                    category: .bio
                ))
            }
        }

        // Fitness-specific starters
        let fitnessStarters = [
            ConversationStarter(
                text: "What's your current fitness goal? I'd love to support each other!",
                icon: "target",
                category: .fitness
            ),
            ConversationStarter(
                text: "What time of day do you usually work out?",
                icon: "clock.fill",
                category: .fitness
            ),
            ConversationStarter(
                text: "What got you into fitness? I'd love to hear your story!",
                icon: "heart.circle",
                category: .fitness
            ),
            ConversationStarter(
                text: "What's the best workout advice you've ever received?",
                icon: "lightbulb.fill",
                category: .fitness
            ),
            ConversationStarter(
                text: "Are you training for anything specific right now?",
                icon: "figure.strengthtraining.traditional",
                category: .fitness
            ),
            ConversationStarter(
                text: "What's your go-to workout when you need motivation?",
                icon: "bolt.heart.fill",
                category: .fitness
            )
        ]

        // Add fitness starters to fill up to 5 total
        let remainingCount = max(0, 5 - starters.count)
        starters.append(contentsOf: fitnessStarters.shuffled().prefix(remainingCount))

        return Array(starters.prefix(5))
    }
}
