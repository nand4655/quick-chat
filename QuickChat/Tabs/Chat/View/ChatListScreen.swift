//
//
// ChatListScreen.swift
// QuickChat
//
// Created by Nand on 26/04/25
//
        

import Foundation
import SwiftUI

struct ChatListScreen: View {
    @Environment(DIContainer.self) private var diContainer: DIContainer
    @State var viewModel: ChatListScreenViewModel = .init()
    @Environment(AppRouter.self) private var router: AppRouter
    
    var body: some View {
        List(viewModel.users) { user in
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(user.displayName?.first.map { String($0) } ?? "?")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
                Text(user.displayName ?? user.email ?? "Unknown")
            }
            .onTapGesture {
                router.navigate(to: .chatScreen(otherUser: user))
            }
        }
        .onAppear {
            viewModel.authService = diContainer.authService
            viewModel.userService = diContainer.userService
            viewModel.chatService = diContainer.chatService
            viewModel.onViewAppear()
        }
    }
}
