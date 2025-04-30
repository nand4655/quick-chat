# QuickChat

QuickChat is a clean, scalable chat application written in SwiftUI that uses Firebase to power real-time one-on-one and group messaging. It follows the MVVM architecture, leverages SwiftUI's declarative APIs, and uses SwiftUI's `Environment` for dependency injection.

---

## Table of Contents

- [Features](#features)  
- [Architecture](#architecture)  
- [Requirements](#requirements)  
- [Setup](#setup)  
- [Missing Features](#missing-features)  
- [Testing](#testing)  
- [Folder Structure](#folder-structure)  
- [License](#license)  
- [How to Use](#how-to-use)

---

## Features

- **User Authentication**  
  Sign up / log in with Firebase Auth (Google only).

- **Real-Time One-on-One Chat**  
  Send and receive messages instantly.

- **Group Chat**  
  Create group conversations with multiple participants.

- **Chat List**  
  Displays recent conversations, sorted by latest message timestamp.

- **Typing Indicators**  
  See when the other party is typing in real time.

- **Message Timestamps & Status**  
  • Single gray checkmark = sent  
  • Double gray checkmarks = delivered  
  • Double green checkmarks = read
  • Timestamps show the send time.

  - **User Profile** 
  • Manage user profile  
  • Logout/delete profile  

---

## Architecture

- MVVM (Model-View-ViewModel)  
  • Views bind to `@Observable`- based ViewModels.  
- SwiftUI & Swift Package Manager  
- Dependency Injection via SwiftUI's `Environment`  
- Firebase iOS SDK for Firestore and Auth
- Centralized navigation

---

## Requirements

- Xcode 15 or later  
- iOS 17.0+  
- Swift 5.8+  
- Firebase iOS SDK (via SwiftPM)  

---

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/nand4655/quick-chat.git
   cd QuickChat
   ```

2. Open the workspace in Xcode:
   ```bash
   open QuickChat.xcodeproj
   ```

3. Add your `GoogleService-Info.plist` to the `QuickChat` target, If you want to retain the data source.

4. Resolve Swift Package dependencies (Xcode should do this automatically). Rest packages if any issue.

5. Build & run on the simulator or device running iOS 17+.

---

## Missing Features

The current version covers core chat functionality. Planned/desired features:

- Offline support (cache messages locally using SwiftData)  
- Media sharing (images, voice notes)
- Improved messsage delivery status management
- Support Apple auth
- Furnished UI and animations 
- DSL - Design system language to standardise app typography and theming
- Move colors to assets
- Localise strings
- Introduce micro SPM packages to better modularise codebase
- Strict Swift6 concurrency and data safety


---

## Testing

This project includes comprehensive unit tests for all logical units and ViewModels:

- Test targets: `QuickChatTests`  
- Mock implementations live in `QuickChatTests/Mocks`  
- Run tests with **⌘U** in Xcode  

---

## Folder Structure
QuickChat/
├─ App/ # SwiftUI App entry & DIContainer
├─ Tabs/
│ ├─ Chat/ # One-on-one chat UI & ViewModel
│ └─ GroupChat/ # Group chat UI & ViewModel
├─ Services/ # AuthService, ChatService, FirestoreService
├─ Models/ # Data models (ChatMessage, User, UserGroup)
├─ Resources/ # Assets, Storyboards, InfoPlist
└─ QuickChatTests/
├─ Mocks/ # MockAuthService, MockChatService, etc.
└─ ChatScreenViewModelTests.swift

---

## License

This project is released under the MIT License. See `LICENSE` for details.

## How to Use

### Prerequisites
- At least two iOS devices (or simulators) running iOS 17.0 or later
- Google account(s) for authentication
- Internet connection

### Getting Started

1. **Installation**
   - Install the app on all devices you want to use for testing
   - Make sure each device has a different Google account signed in

2. **Sign In**
   - Launch the app on each device
   - Tap "Sign in with Google"
   - Select your Google account when prompted
   - Grant necessary permissions

3. **One-on-One Chat**
   - On the first device:
     - Navigate to the Chat tab
     - Select a user from the list
     - Start sending messages
   - On the second device:
     - Messages will appear in real-time
     - You'll see typing indicators when the other user is typing
     - Message status (sent, delivered, read) will update automatically

4. **Group Chat**
   - On any device:
     - Navigate to the Group Chat tab
     - Tap the "+" button to create a new group
     - Enter a group name
     - Select multiple users to add to the group
     - Start sending messages
   - All group members will receive messages in real-time
   - Group typing indicators show when any member is typing

### Note
- Apple Sign-In is currently not implemented but can be enabled by:
  1. Adding Sign in with Apple capability in Xcode
  2. Updating the Firebase configuration

### Troubleshooting
- If messages aren't appearing in real-time:
  - Check internet connection
  - Ensure both users are properly signed in
- If typing indicators aren't working:
  - Check if both users are online