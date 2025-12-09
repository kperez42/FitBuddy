# FitBuddy

A modern iOS fitness partner matching application built with SwiftUI and Firebase, featuring fitness-based partner discovery, real-time messaging, and premium subscriptions.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Firebase Configuration](#firebase-configuration)
- [Architecture](#architecture)
- [Testing](#testing)
- [Premium Features](#premium-features)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Features

### Core Fitness Partner Features
- **User Discovery** - Fitness-based partner matching with advanced filters (fitness level, workout types, location, availability)
- **Profile System** - Multi-photo profiles with bio, fitness goals, workout preferences, and gym locations
- **Matching System** - Mutual interest creates instant workout partner matches
- **Real-time Messaging** - Live chat with partner tracking, unread counts, and typing indicators
- **Interests/Likes** - Send training interest to users with optional messages

### Advanced Features
- **Photo Verification** - Face detection using Apple's Vision framework
- **Referral System** - Users earn 7 days of premium for each successful referral
- **Profile Insights** - Analytics on profile views, swipe stats, match rates, and photo performance
- **Content Moderation** - Automatic profanity filtering, spam detection, and personal info blocking
- **Safety Center** - Safety tips, reporting, blocking, and screenshot detection
- **Profile Prompts** - 100+ personality questions for engaging profiles
- **Conversation Starters** - Pre-built icebreaker messages
- **Email Verification** - Required for full app access

### Premium Features
- Unlimited swipes (free users: 50/day limit)
- See who liked you
- Profile boosting (10x visibility)
- 5 super likes per day
- Rewind swipes
- Priority support
- Advanced analytics

## Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **CocoaPods** or **Swift Package Manager**
- **Firebase Account** (free tier works for development)
- **Apple Developer Account** (for StoreKit testing)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/FitBuddy.git
cd FitBuddy
```

### 2. Install Dependencies

If using CocoaPods:

```bash
pod install
open FitBuddy.xcworkspace
```

If using Swift Package Manager (SPM):
- Open `FitBuddy.xcodeproj` in Xcode
- Dependencies should auto-resolve

### 3. Configure Firebase

See [Firebase Configuration](#firebase-configuration) section below for detailed setup.

### 4. Configure Signing

- Open the project in Xcode
- Select the FitBuddy target
- Go to "Signing & Capabilities"
- Select your development team
- Xcode will automatically create provisioning profiles

### 5. Run the App

- Select a simulator or connected device
- Press `Cmd + R` to build and run

## Firebase Configuration

### Prerequisites

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an iOS app to your Firebase project
3. Download `GoogleService-Info.plist`

### Setup Steps

#### 1. Add Configuration File

- Place `GoogleService-Info.plist` in the root of the FitBuddy Xcode project
- Make sure it's added to the FitBuddy target

#### 2. Enable Firebase Services

In the Firebase Console, enable:

**Authentication:**
- Email/Password authentication
- Configure email verification (see [FIREBASE_EMAIL_SETUP.md](./FIREBASE_EMAIL_SETUP.md))

**Firestore Database:**
- Create database in production mode
- Deploy security rules from `firestore.rules` (if provided)

**Firebase Storage:**
- Enable Storage
- Configure security rules for profile images

**Cloud Messaging (FCM):**
- Enable FCM for push notifications
- Upload APNs certificates (Development & Production)

**Analytics:**
- Automatically enabled when you add Firebase

#### 3. Firestore Collections

The app uses these Firestore collections:

```
users/
  - {userId}/
    - email, fullName, age, gender, location, etc.

matches/
  - {matchId}/
    - user1Id, user2Id, timestamp, lastMessage, etc.

messages/
  - {messageId}/
    - matchId, senderId, text, timestamp, etc.

likes/
  - {likeId}/
    - fromUserId, toUserId, isSuperLike, timestamp

passes/
  - {passId}/
    - fromUserId, toUserId, timestamp

referrals/
  - {referralId}/
    - referrerUserId, referredUserId, referralCode, status

reports/
  - {reportId}/
    - reporterId, reportedUserId, reason, timestamp
```

#### 4. Security Rules

Deploy Firestore security rules to protect user data:

```bash
firebase deploy --only firestore:rules
```

See [Firebase Documentation](https://firebase.google.com/docs/firestore/security/get-started) for more details.

### Email Verification Setup

Email verification is required for all users. See the comprehensive guide: [FIREBASE_EMAIL_SETUP.md](./FIREBASE_EMAIL_SETUP.md)

## Architecture

FitBuddy follows the **MVVM (Model-View-ViewModel)** architecture pattern with a service layer for business logic.

### Architecture Diagram

```
┌─────────────────────────────────────────┐
│           Views (SwiftUI)                │
│  - SignInView, SignUpView               │
│  - MainTabView, DiscoverView            │
│  - ProfileView, MatchesView             │
│  - MessagesView, PremiumUpgradeView     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       ViewModels (@Published)            │
│  - AuthViewModel (deprecated)            │
│  - DiscoverViewModel                     │
│  - ProfileViewModel                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Services (Business Logic)        │
│  - AuthService                           │
│  - UserService                           │
│  - MatchService                          │
│  - MessageService                        │
│  - SwipeService                          │
│  - ReferralManager                       │
│  - StoreManager                          │
│  - NotificationService                   │
│  - ContentModerator                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        Data Layer (Firebase)             │
│  - Firestore Database                    │
│  - Firebase Auth                         │
│  - Firebase Storage                      │
│  - Firebase Analytics                    │
└──────────────────────────────────────────┘
```

### Key Components

#### Services

**AuthService** (`AuthService.swift:256`)
- User authentication (sign up, sign in, sign out)
- Email verification
- Password reset
- Input validation and sanitization

**MatchService** (`MatchService.swift`)
- Match creation and management
- Real-time match listeners
- Unread count tracking
- Match deletion/unmatch

**SwipeService** (`SwipeService.swift`)
- Like/pass recording
- Mutual match detection
- Super likes
- Swipe history tracking

**ReferralManager** (`ReferralManager.swift`)
- Referral code generation
- Referral tracking and rewards
- Premium days calculation
- Leaderboard management

**StoreManager** (`StoreManager.swift`)
- In-app purchases using StoreKit 2
- Subscription management
- Transaction verification
- Server-side validation (template provided)
- Firestore premium status updates

**ContentModerator** (`ContentModerator.swift`)
- Profanity detection and filtering
- Spam detection
- Personal info detection (phone, email, address)
- Content scoring

**NotificationService** (`NotificationService.swift`)
- Push notification management
- FCM token handling
- New match/message notifications

#### Models

**User** (`User.swift:220`)
- Comprehensive user profile model
- Supports Firestore encoding/decoding
- Contains preferences, stats, and referral info

**Match** (`Match.swift`)
- Represents a match between two users
- Tracks last message and unread counts

**Message** (`Message.swift`)
- Chat message model
- Supports text, images, and metadata

#### Utilities

**ErrorHandling** (`ErrorHandling.swift`)
- Comprehensive error types
- User-friendly error messages
- Recovery suggestions

**Constants** (`Constants.swift:233`)
- Centralized configuration
- Feature flags
- API limits and constraints

**HapticManager** (`HapticManager.swift`)
- Haptic feedback management

**AnalyticsManager** (`AnalyticsManager.swift`)
- Firebase Analytics integration
- Event tracking

### Design Patterns

1. **Singleton Pattern** - Services use shared instances
2. **Protocol-Based Design** - `ServiceProtocols.swift` defines interfaces
3. **Dependency Injection** - Ready for testing with DI
4. **Observer Pattern** - SwiftUI's `@Published` for reactive updates
5. **Strategy Pattern** - Content moderation strategies

## Testing

FitBuddy includes comprehensive unit tests for core services.

### Running Tests

```bash
# Run all tests
Command + U in Xcode

# Or via command line
xcodebuild test -workspace FitBuddy.xcworkspace -scheme FitBuddy -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

The following services have comprehensive unit tests:

- **AuthServiceTests** - Authentication flows, validation, error handling
- **MatchServiceTests** - Match creation, sorting, unread counts
- **ContentModeratorTests** - Profanity, spam, personal info detection
- **SwipeServiceTests** - Like/pass logic, mutual matching
- **ReferralManagerTests** - Code generation, rewards calculation

### Test Files

```
FitBuddyTests/
├── AuthServiceTests.swift          (56 tests)
├── MatchServiceTests.swift         (32 tests)
├── ContentModeratorTests.swift     (45 tests)
├── SwipeServiceTests.swift         (38 tests)
└── ReferralManagerTests.swift      (41 tests)
```

### Writing New Tests

Use Swift Testing framework:

```swift
import Testing
@testable import FitBuddy

@Suite("My Feature Tests")
struct MyFeatureTests {
    @Test("Test description")
    func testFeature() async throws {
        #expect(condition, "Failure message")
    }
}
```

## Premium Features

### Subscription Tiers

| Feature | Free | Monthly | 6 Months | Annual |
|---------|------|---------|----------|--------|
| **Price** | $0 | $19.99/mo | $14.99/mo | $9.99/mo |
| **Swipes/Day** | 50 | Unlimited | Unlimited | Unlimited |
| **See Likes** | ❌ | ✅ | ✅ | ✅ |
| **Super Likes** | 1/day | 5/day | 5/day | 5/day |
| **Profile Boost** | ❌ | ✅ | ✅ | ✅ |
| **Rewind** | ❌ | ✅ | ✅ | ✅ |
| **Priority Support** | ❌ | ✅ | ✅ | ✅ |

### StoreKit 2 Implementation

FitBuddy uses StoreKit 2 for in-app purchases with:

- **Transaction Verification** - Automatic verification of purchases
- **Subscription Status** - Real-time subscription state tracking
- **Auto-Renewable Subscriptions** - Handled by Apple
- **Purchase Restoration** - Users can restore purchases on new devices
- **Grace Period Support** - Handles billing issues gracefully
- **Server Validation Template** - Ready for backend receipt validation

### Testing In-App Purchases

1. Create a Sandbox test user in App Store Connect
2. Sign out of App Store on device/simulator
3. Run the app and test purchases with sandbox account
4. Purchases are free and immediate in sandbox mode

## Project Structure

```
FitBuddy/
├── FitBuddyApp.swift                 # App entry point
├── ContentView.swift                 # Root view with auth routing
│
├── Models/                          # Data models
│   ├── User.swift                   # User profile model
│   ├── Match.swift                  # Match model
│   ├── Message.swift                # Message model
│   ├── Referral.swift               # Referral system models
│   └── ProfilePrompt.swift          # Profile prompts
│
├── Services/                        # Business logic layer
│   ├── AuthService.swift            # Authentication
│   ├── UserService.swift            # User management
│   ├── MatchService.swift           # Match operations
│   ├── MessageService.swift         # Messaging
│   ├── SwipeService.swift           # Like/pass logic
│   ├── ReferralManager.swift        # Referral system
│   ├── StoreManager.swift           # In-app purchases
│   ├── NotificationService.swift    # Push notifications
│   ├── ContentModerator.swift       # Content filtering
│   ├── ImageUploadService.swift     # Photo uploads
│   ├── BlockReportService.swift     # Safety features
│   └── ServiceProtocols.swift       # Service interfaces
│
├── Views/                           # SwiftUI views
│   ├── Authentication/
│   │   ├── SignInView.swift
│   │   ├── SignUpView.swift
│   │   └── EmailVerificationView.swift
│   │
│   ├── Main/
│   │   ├── MainTabView.swift
│   │   ├── DiscoverView.swift
│   │   ├── MatchesView.swift
│   │   ├── MessagesView.swift
│   │   └── ProfileView.swift
│   │
│   ├── Premium/
│   │   └── PremiumUpgradeView.swift
│   │
│   └── Components/
│       ├── UserCardView.swift
│       ├── MessageRowView.swift
│       └── LoadingView.swift
│
├── Utilities/                       # Helper classes
│   ├── Constants.swift              # App constants
│   ├── ErrorHandling.swift          # Error management
│   ├── HapticManager.swift          # Haptic feedback
│   ├── AnalyticsManager.swift       # Analytics
│   ├── RateLimiter.swift            # Rate limiting
│   ├── RetryManager.swift           # Network retry logic
│   └── ImageCache.swift             # Image caching
│
├── Resources/                       # Assets and config
│   ├── Assets.xcassets
│   ├── GoogleService-Info.plist
│   └── Info.plist
│
├── FitBuddyTests/                   # Unit tests
│   ├── AuthServiceTests.swift
│   ├── MatchServiceTests.swift
│   ├── ContentModeratorTests.swift
│   ├── SwipeServiceTests.swift
│   └── ReferralManagerTests.swift
│
└── Documentation/                   # Documentation
    ├── README.md                    # This file
    └── FIREBASE_EMAIL_SETUP.md      # Email verification guide
```

## Key Files Reference

| File | Purpose | Lines |
|------|---------|-------|
| `AuthService.swift` | User authentication and validation | 526 |
| `User.swift` | User profile model | 220 |
| `Constants.swift` | Centralized configuration | 233 |
| `ErrorHandling.swift` | Error types and handling | 436 |
| `StoreManager.swift` | In-app purchase management | 350+ |
| `ContentModerator.swift` | Content filtering | 238 |

## Code Style Guidelines

### Swift Conventions

- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use explicit `self` only when required
- Prefer `let` over `var` when possible
- Use meaningful variable names

### Comments

- Use `// MARK: -` to organize code sections
- Document complex logic with inline comments
- Keep comments up-to-date with code changes

### Error Handling

```swift
// Good
do {
    try await someOperation()
} catch {
    print("❌ Operation failed: \(error.localizedDescription)")
    throw FitBuddyError.from(error)
}

// Bad
try! riskyOperation()  // Avoid force try
```

### Logging

```swift
// Use consistent logging format
print("✅ Success message")  // Green check for success
print("❌ Error message")    // Red X for errors
print("⚠️ Warning message")  // Warning symbol
print("🔵 Info message")     // Blue circle for info
print("ℹ️ Debug message")    // Info symbol for debug
```

## Environment Variables

### Debug Mode

Debug features are controlled in `Constants.swift`:

```swift
enum Debug {
    #if DEBUG
    static let loggingEnabled = true
    static let showDebugInfo = true
    #else
    static let loggingEnabled = false
    static let showDebugInfo = false
    #endif
}
```

### Feature Flags

Enable/disable features in `Constants.swift`:

```swift
enum Features {
    static let voiceMessagesEnabled = false
    static let videoCallsEnabled = false
    static let storiesEnabled = false
    static let groupChatsEnabled = false
}
```

## Troubleshooting

### Common Issues

**1. Email Verification Not Working**
- See [FIREBASE_EMAIL_SETUP.md](./FIREBASE_EMAIL_SETUP.md)
- Check Firebase Console > Authentication > Templates
- Verify authorized domains include your app domain

**2. Firestore Permission Denied**
- Check security rules in Firebase Console
- Ensure user is authenticated
- Verify rules allow the operation

**3. Photos Not Uploading**
- Check Firebase Storage rules
- Verify image size is under limits
- Check network connection

**4. Matches Not Appearing**
- Verify Firestore OR queries are supported (requires Firebase iOS SDK 10.0+)
- Check user filters and preferences
- Ensure both users meet each other's criteria

**5. In-App Purchases Not Working**
- Test with Sandbox account
- Verify product IDs match App Store Connect
- Check StoreKit configuration file
- Ensure device can make payments

### Debug Logging

Enable verbose logging:

```swift
// In AppDelegate or App init
Constants.log("App started", category: "Lifecycle")
```

### Reset User Data (Development)

```swift
// Sign out and clear local data
AuthService.shared.signOut()

// Delete Firestore user document (careful!)
// Only do this in development
```

## Contributing

We welcome contributions! Please follow these guidelines:

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Commit Messages

Use conventional commit format:

```
feat: Add voice message support
fix: Resolve crash on profile save
docs: Update Firebase setup guide
test: Add tests for SwipeService
refactor: Extract StoreManager to separate file
```

### Code Review Checklist

- [ ] Code follows Swift style guidelines
- [ ] All tests pass
- [ ] New features have unit tests
- [ ] Documentation is updated
- [ ] No hardcoded credentials or secrets
- [ ] Print statements use consistent logging format
- [ ] Error handling is comprehensive

## Security

### Reporting Security Issues

Please email security concerns to: support@fitbuddy.app

**Do not** open public issues for security vulnerabilities.

### Security Best Practices

- Never commit `GoogleService-Info.plist` with real credentials
- Use environment variables for sensitive data
- Implement proper Firestore security rules
- Validate all user input server-side
- Use HTTPS for all network requests
- Implement rate limiting for API calls

## Performance

### Optimization Tips

- Use `ImageCache` for profile photos
- Implement pagination for large lists
- Use Firestore listeners carefully (remember to detach)
- Lazy load images in scrollable views
- Profile with Instruments regularly

### Monitoring

- Firebase Analytics for user behavior
- Firebase Crashlytics for crash reporting
- Custom events for funnel tracking

## Roadmap

### Planned Features

- [ ] Voice messages in chat
- [ ] Video calling with matches
- [ ] Stories feature
- [ ] Group chats
- [ ] Advanced AI matching algorithm
- [ ] Video profile support
- [ ] In-app workout planning tools

### Known Issues

- Voice messages feature flag disabled (in development)
- Video calls not yet implemented
- Stories feature planned for future release

## Support

### Documentation

- [Firebase Setup Guide](./FIREBASE_EMAIL_SETUP.md)
- [Apple StoreKit Documentation](https://developer.apple.com/storekit/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

### Contact

- **Email**: support@fitbuddy.app
- **Website**: https://fitbuddy.app
- **Twitter**: @fitbuddyapp

## License

Copyright © 2025 FitBuddy. All rights reserved.

## Acknowledgments

- Firebase for backend infrastructure
- Apple for StoreKit and SwiftUI
- All contributors and beta testers

---

**Built with 💪 using SwiftUI and Firebase**

*Last Updated: January 2025*
