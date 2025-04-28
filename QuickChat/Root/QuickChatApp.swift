//
//
// QuickChatApp.swift
// QuickChat
//
// Created by Nand on 24/04/25
//


import SwiftUI
import SwiftData

@main
struct QuickChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var diContainer = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            if !diContainer.isInitialized {
                withAnimation {
                    SplashScreen()
                }
            } else {
                ContentView()
                    .environment(diContainer)
            }
        }
    }
}

extension View {
    func withPreviewEnvironments() -> some View {
        self
            .environment(DIContainer())
            .environment(AppRouter())
            .preferredColorScheme(.light)
    }
}
