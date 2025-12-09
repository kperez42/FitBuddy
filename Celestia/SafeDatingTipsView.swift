//
//  SafetyTipsView.swift
//  FitBuddy
//
//  Safety tips and resources for meeting workout partners
//

import SwiftUI

struct SafetyTipsView: View {
    @State private var selectedCategory: TipCategory = .beforeMeeting

    var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            categoryPicker

            // Tips List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(SafetyTip.tips(for: selectedCategory)) { tip in
                        SafetyTipCard(tip: tip)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Workout Safety Tips")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TipCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: TipCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.title)
                    .font(.caption.bold())
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Safety Tip Card

struct SafetyTipCard: View {
    let tip: SafetyTip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tip.priority.color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: tip.icon)
                        .font(.title3)
                        .foregroundColor(tip.priority.color)
                }

                Text(tip.title)
                    .font(.headline)

                Spacer()

                if tip.priority == .critical {
                    Text("IMPORTANT")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }

            // Description
            Text(tip.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action items if present
            if !tip.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tip.actionItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text(item)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Models

enum TipCategory: CaseIterable {
    case beforeMeeting
    case firstWorkout
    case ongoingSafety
    case redFlags
    case resources

    var title: String {
        switch self {
        case .beforeMeeting: return "Before"
        case .firstWorkout: return "First Workout"
        case .ongoingSafety: return "Ongoing"
        case .redFlags: return "Red Flags"
        case .resources: return "Resources"
        }
    }

    var icon: String {
        switch self {
        case .beforeMeeting: return "calendar.badge.clock"
        case .firstWorkout: return "figure.run"
        case .ongoingSafety: return "shield.checkered"
        case .redFlags: return "exclamationmark.triangle.fill"
        case .resources: return "link"
        }
    }
}

enum TipPriority {
    case critical
    case important
    case helpful

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .helpful: return .blue
        }
    }
}

struct SafetyTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: TipPriority
    let actionItems: [String]

    static func tips(for category: TipCategory) -> [SafetyTip] {
        switch category {
        case .beforeMeeting:
            return [
                SafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Get to Know Them First",
                    description: "Message for at least a few days before working out together. Discuss fitness goals and experience levels.",
                    priority: .important,
                    actionItems: [
                        "Have several conversations about fitness",
                        "Video chat before meeting",
                        "Verify their fitness background"
                    ]
                ),
                SafetyTip(
                    icon: "video.fill",
                    title: "Video Chat First",
                    description: "A video call helps verify they are who they say they are and builds comfort before meeting.",
                    priority: .important,
                    actionItems: [
                        "Suggest a quick video call",
                        "Check they match their photos",
                        "Gauge your comfort level"
                    ]
                ),
                SafetyTip(
                    icon: "person.2.fill",
                    title: "Share Your Plans",
                    description: "Always tell a friend or family member where you're working out and who you're meeting.",
                    priority: .critical,
                    actionItems: [
                        "Share workout location and time",
                        "Send workout partner's profile info",
                        "Set up check-in times"
                    ]
                ),
                SafetyTip(
                    icon: "magnifyingglass",
                    title: "Do Your Research",
                    description: "Look them up online. A quick search can reveal important information.",
                    priority: .helpful,
                    actionItems: [
                        "Google their name",
                        "Check social media profiles",
                        "Look for fitness community presence"
                    ]
                )
            ]

        case .firstWorkout:
            return [
                SafetyTip(
                    icon: "building.2.fill",
                    title: "Meet at a Public Gym",
                    description: "Always choose a busy, public gym or fitness facility for first workouts. Avoid private locations.",
                    priority: .critical,
                    actionItems: [
                        "Choose a well-known gym or park",
                        "Avoid secluded trails",
                        "Stay in well-populated areas"
                    ]
                ),
                SafetyTip(
                    icon: "car.fill",
                    title: "Arrange Your Own Transportation",
                    description: "Drive yourself or use a rideshare. Don't share your home address too quickly.",
                    priority: .critical,
                    actionItems: [
                        "Drive yourself",
                        "Use Uber/Lyft",
                        "Have an exit strategy"
                    ]
                ),
                SafetyTip(
                    icon: "figure.strengthtraining.traditional",
                    title: "Start With a Light Workout",
                    description: "Don't push too hard on the first session. Focus on getting to know your partner's style.",
                    priority: .important,
                    actionItems: [
                        "Agree on workout intensity",
                        "Respect fitness levels",
                        "Communicate during exercises"
                    ]
                ),
                SafetyTip(
                    icon: "iphone",
                    title: "Keep Your Phone Charged",
                    description: "Ensure your phone is fully charged and you have a way to call for help if needed.",
                    priority: .important,
                    actionItems: [
                        "Charge phone before leaving",
                        "Bring a portable charger",
                        "Keep emergency numbers handy"
                    ]
                ),
                SafetyTip(
                    icon: "drop.fill",
                    title: "Bring Your Own Water",
                    description: "Always bring your own water bottle and snacks. Stay hydrated during workouts.",
                    priority: .important,
                    actionItems: [
                        "Bring your own water bottle",
                        "Never share drinks",
                        "Pack your own nutrition"
                    ]
                )
            ]

        case .ongoingSafety:
            return [
                SafetyTip(
                    icon: "ear",
                    title: "Trust Your Instincts",
                    description: "If something feels off, it probably is. You can end a workout partnership at any time.",
                    priority: .critical,
                    actionItems: [
                        "Listen to your gut",
                        "Don't ignore red flags",
                        "Leave if uncomfortable"
                    ]
                ),
                SafetyTip(
                    icon: "lock.shield.fill",
                    title: "Protect Personal Information",
                    description: "Don't share your address, workplace details, or financial information too quickly.",
                    priority: .important,
                    actionItems: [
                        "Wait before sharing address",
                        "Be vague about work location",
                        "Never share financial details"
                    ]
                ),
                SafetyTip(
                    icon: "clock.fill",
                    title: "Build Trust Gradually",
                    description: "Take time to build trust before sharing personal details or working out in private.",
                    priority: .helpful,
                    actionItems: [
                        "Set your own pace",
                        "Don't feel pressured",
                        "Build trust gradually"
                    ]
                ),
                SafetyTip(
                    icon: "checkmark.shield.fill",
                    title: "Verify Their Identity",
                    description: "Make sure they are who they claim to be through various verification methods.",
                    priority: .important,
                    actionItems: [
                        "Check verified badge",
                        "Video call before meeting",
                        "Verify social profiles"
                    ]
                )
            ]

        case .redFlags:
            return [
                SafetyTip(
                    icon: "exclamationmark.triangle.fill",
                    title: "Pressure or Aggression",
                    description: "Anyone who pressures you, gets angry when you set boundaries, or seems aggressive is a major red flag.",
                    priority: .critical,
                    actionItems: [
                        "End contact immediately",
                        "Block and report them",
                        "Tell someone you trust"
                    ]
                ),
                SafetyTip(
                    icon: "eye.slash.fill",
                    title: "Inconsistent Stories",
                    description: "Pay attention if their fitness claims don't add up or they contradict themselves frequently.",
                    priority: .important,
                    actionItems: [
                        "Note inconsistencies",
                        "Ask clarifying questions",
                        "Trust your judgment"
                    ]
                ),
                SafetyTip(
                    icon: "dollarsign.circle.fill",
                    title: "Asks for Money",
                    description: "Never send money to someone you haven't met, regardless of their story. This is almost always a scam.",
                    priority: .critical,
                    actionItems: [
                        "Never send money",
                        "Report immediately",
                        "Block the user"
                    ]
                ),
                SafetyTip(
                    icon: "figure.run",
                    title: "Pushes Your Limits Unsafely",
                    description: "Be wary of anyone who pushes you to exercise beyond your limits or ignores your fitness level.",
                    priority: .important,
                    actionItems: [
                        "Communicate your limits",
                        "Don't be pushed too hard",
                        "Safety comes first"
                    ]
                ),
                SafetyTip(
                    icon: "photo.on.rectangle.angled",
                    title: "Refuses to Video Chat",
                    description: "If they consistently avoid video calls or meeting at public gyms, they may be hiding something.",
                    priority: .important,
                    actionItems: [
                        "Insist on video chat",
                        "Be suspicious of excuses",
                        "Consider ending contact"
                    ]
                )
            ]

        case .resources:
            return [
                SafetyTip(
                    icon: "phone.fill",
                    title: "Emergency Services",
                    description: "In immediate danger, always call 911 (or your local emergency number).",
                    priority: .critical,
                    actionItems: [
                        "911 for emergencies",
                        "Know local police non-emergency",
                        "Save these in your phone"
                    ]
                ),
                SafetyTip(
                    icon: "cross.case.fill",
                    title: "Sports Medicine Resources",
                    description: "Know where your local urgent care or sports medicine clinic is for workout injuries.",
                    priority: .important,
                    actionItems: [
                        "Find nearest urgent care",
                        "Know your gym's first aid location",
                        "Learn basic injury care"
                    ]
                ),
                SafetyTip(
                    icon: "heart.text.square.fill",
                    title: "Mental Health Support",
                    description: "National Suicide Prevention Lifeline: 988. Free, confidential 24/7 support.",
                    priority: .important,
                    actionItems: [
                        "Call or text 988",
                        "Online chat available",
                        "Completely confidential"
                    ]
                ),
                SafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Crisis Text Line",
                    description: "Text HOME to 741741 for free, 24/7 crisis support via text message.",
                    priority: .helpful,
                    actionItems: [
                        "Text HOME to 741741",
                        "Available 24/7",
                        "All issues welcome"
                    ]
                ),
                SafetyTip(
                    icon: "network",
                    title: "Fitness Safety Resources",
                    description: "Visit these websites for more information on safe exercise practices.",
                    priority: .helpful,
                    actionItems: [
                        "acsm.org (American College of Sports Medicine)",
                        "nasm.org (National Academy of Sports Medicine)",
                        "acefitness.org (ACE Fitness)"
                    ]
                )
            ]
        }
    }
}

#Preview {
    NavigationStack {
        SafetyTipsView()
    }
}
