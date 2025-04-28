//
//
// MainTabScreen.swift
// QuickChat
//
// Created by Nand on 24/04/25
//


import SwiftUI

import SwiftUI

enum AppTab: Int, Identifiable, Hashable, CaseIterable, Codable {
    case chat
    case group
    case profile
    
    nonisolated var id: Int {
        rawValue
    }
    
    var tabView: some View {
        VStack(spacing: 10) {
            icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .clipped()
            Text(tabName)
        }
    }
    
    var tabName: String {
        switch self {
            case .chat:
                "Chat"
            case .group:
                "Group"
            case .profile:
                "Profile"
        }
    }
    
    var icon: Image {
        switch self {
            case .chat:
                Image(systemName: "ellipsis.message")
            case .group:
                Image(systemName: "person.3")
            case .profile:
                Image(systemName: "gear")
        }
    }
    
}

struct MainTabScreen: View {
    @State private var selectedTabRawValue: Int = AppTab.chat.rawValue
    @Environment(DIContainer.self) private var diContainer: DIContainer
    @Environment(AppRouter.self) private var rootRouter: AppRouter
    
    var body: some View {
        TabView(
            selection: $selectedTabRawValue
        ) {
            ForEach(AppTab.allCases) { tab in
                
                switch tab {
                    case .chat:
                        ChatListScreen()
                            .asTabItem(for: tab, selectedTabRawValue: selectedTabRawValue)
                            .tag(tab)
                        
                    case .group:
                        GroupChatListScreen()
                            .asTabItem(for: tab, selectedTabRawValue: selectedTabRawValue)
                            .tag(tab)
                        
                    case .profile:
                        UserProfileScreen()
                            .asTabItem(for: tab, selectedTabRawValue: selectedTabRawValue)
                            .environment(rootRouter)
                            .tag(tab)
                }
            }
        }
        .environment(rootRouter)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.bottom, 54)
        }
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
    }
}

private extension View {
    func asTabItem(for tab: AppTab, selectedTabRawValue: Int) -> some View {
        self.tabItem {
            tab.tabView
        }
        .tag(tab)
    }
}

#Preview {
    MainTabScreen()
        .withPreviewEnvironments()
}




