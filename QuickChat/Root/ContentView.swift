//
//
// ContentView.swift
// wapi-ai
//
// Created by Nand on 10/04/25
//


import SwiftUI

struct ContentView: View {
    @Environment(DIContainer.self) private var diContainer: DIContainer
    @State private var router = AppRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if diContainer.authService.isLoggedIn {
                    MainTabScreen()
                        .environment(diContainer)
                        .environment(router)
                } else {
                    LoginScreen()
                        .environment(router)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                    case .loginScreen:
                        LoginScreen()
                            .environment(router)
                        
                    case .mainTabView:
                        MainTabScreen()
                            .environment(router)
                        
                    case let .chatScreen(otherUser):
                        ChatScreen(otherUser: otherUser)
                            .environment(router)
                        
                    case let .groupChatScreen(group):
                        GroupChatScreen(group: group)
                            .environment(router)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .withPreviewEnvironments()
}
