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
        VStack {
            if viewModel.users.isEmpty {
                Image(.sad)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .scaledToFit()
                
                Text("Looks like you have no friends yet! \nInvite some friends to start chatting!")
                    .multilineTextAlignment(.center)
                    .monospaced()
                    .padding(.top)
            } else {
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
