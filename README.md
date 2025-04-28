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

- Offline support (cache messages locally)  
- Media sharing (images, voice notes) 
- Furnished UI and animations 

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