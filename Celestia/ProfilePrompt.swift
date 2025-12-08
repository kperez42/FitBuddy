//
//  ProfilePrompt.swift
//  FitBuddy
//
//  Fitness prompts for engaging profiles
//

import Foundation

struct ProfilePrompt: Codable, Identifiable, Equatable {
    var id: String
    var question: String
    var answer: String

    init(id: String = UUID().uuidString, question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }

    func toDictionary() -> [String: String] {
        return [
            "id": id,
            "question": question,
            "answer": answer
        ]
    }
}

// MARK: - Available Prompts

struct PromptLibrary {
    static let allPrompts: [String] = [
        // Fitness Goals & Motivation
        "My main fitness goal is...",
        "What motivates me to work out is...",
        "My fitness journey started when...",
        "I'm training for...",
        "My fitness mantra is...",
        "What keeps me consistent is...",
        "My biggest fitness achievement is...",
        "I want a workout partner who...",

        // Workout Style & Preferences
        "My ideal workout looks like...",
        "My go-to exercise is...",
        "I prefer working out in the...",
        "My workout playlist includes...",
        "The gym equipment I can't live without is...",
        "My favorite type of workout is...",
        "After a workout, I feel...",

        // Fitness Personality
        "As a workout partner, I'm...",
        "I'm the type of gym-goer who...",
        "My workout style is...",
        "You'll know I had a great workout if...",
        "My gym pet peeve is...",
        "I'm looking for accountability in...",
        "The best workout buddy quality is...",

        // Health & Nutrition
        "My pre-workout ritual is...",
        "My post-workout meal is usually...",
        "My approach to nutrition is...",
        "My favorite healthy snack is...",
        "I fuel my workouts with...",
        "Recovery for me means...",
        "My meal prep secret is...",

        // Fitness Fun & Quirks
        "Don't judge me, but my guilty fitness pleasure is...",
        "The exercise I secretly love is...",
        "My unpopular fitness opinion is...",
        "The workout trend I don't understand is...",
        "I'll never skip...",
        "My rest day activity is...",
        "The fitness myth I believed was...",

        // Goals & Progress
        "My biggest fitness goal this year is...",
        "In 6 months, I want to...",
        "A fitness bucket list item is...",
        "I'm currently working on improving my...",
        "My next fitness challenge is...",
        "The PR I'm chasing is...",
        "By next year, I want to...",

        // Sports & Activities
        "My favorite outdoor activity is...",
        "The sport I've always wanted to try is...",
        "My weekend active hobby is...",
        "The best workout I've ever done was...",
        "A fitness class I recommend is...",
        "My dream fitness adventure is...",
        "The activity that doesn't feel like exercise is...",

        // Community & Connection
        "I'm looking for a workout partner because...",
        "Together we could...",
        "Let's train for...",
        "We'll get along if you...",
        "Ask me about...",
        "I can help you with...",
        "Let's challenge each other to...",

        // Mindset & Philosophy
        "My fitness philosophy is...",
        "What fitness has taught me is...",
        "The best fitness advice I've received is...",
        "I believe in...",
        "My approach to rest days is...",
        "What I've learned about my body is...",
        "Fitness means to me..."
    ]

    static let categories: [String: [String]] = [
        "Fitness Goals": [
            "My main fitness goal is...",
            "I'm training for...",
            "My biggest fitness achievement is...",
            "I want a workout partner who..."
        ],
        "Workout Style": [
            "My ideal workout looks like...",
            "My go-to exercise is...",
            "My favorite type of workout is...",
            "I prefer working out in the..."
        ],
        "Partner Qualities": [
            "As a workout partner, I'm...",
            "I'm looking for accountability in...",
            "The best workout buddy quality is...",
            "I'm looking for a workout partner because..."
        ],
        "Fun & Quirky": [
            "Don't judge me, but my guilty fitness pleasure is...",
            "My unpopular fitness opinion is...",
            "I'll never skip...",
            "My rest day activity is..."
        ],
        "Progress & Goals": [
            "My biggest fitness goal this year is...",
            "In 6 months, I want to...",
            "I'm currently working on improving my...",
            "The PR I'm chasing is..."
        ],
        "Mindset": [
            "My fitness philosophy is...",
            "What fitness has taught me is...",
            "The best fitness advice I've received is...",
            "Fitness means to me..."
        ]
    ]

    static func randomPrompts(count: Int = 5) -> [String] {
        return Array(allPrompts.shuffled().prefix(count))
    }

    static func suggestedPrompts() -> [String] {
        // Return a curated mix of fitness prompts
        return [
            "My main fitness goal is...",
            "I want a workout partner who...",
            "My ideal workout looks like...",
            "As a workout partner, I'm...",
            "What motivates me to work out is..."
        ]
    }
}
