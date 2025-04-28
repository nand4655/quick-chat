//
//
// GroupChatListScreen.swift
// QuickChat
//
// Created by Nand on 26/04/25
//


import Foundation
import SwiftUI


struct GroupChatListScreen: View {
    @State private var viewModel: GroupChatListViewModel = .init()
    @State private var showCreateGroupSheet = false
    @State private var isUserListLoaded = false
    @State private var groupName = ""
    @State private var showUserSelection = false
    
    @Environment(AppRouter.self) private var router: AppRouter
    @Environment(DIContainer.self) private var diContainer: DIContainer
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.loadUsers()
                        if !viewModel.users.isEmpty {
                            showCreateGroupSheet.toggle()
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .tint(.blue)
                }
                .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            
            Spacer()
            
            if viewModel.groups.isEmpty {
                Text("No groups yet")
                    .foregroundColor(.gray)
            } else {
                List(viewModel.groups) { group in
                    HStack(spacing: 12) {
                        Image(systemName: group.memberIds.count <= 2 ? "person.2.fill" : "person.2.badge.plus.fill")
                            .resizable()
                            .frame(width: 42, height: 28)
                            .scaledToFit()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.name)
                                .font(.system(size: 18, weight: .regular, design: .default))
                            
                            Text("You and \(group.memberIds.count - 1) others")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundStyle(.gray.opacity(0.7))
                        }
                        
                    }
                    .onTapGesture {
                        router.navigate(to: .groupChatScreen(group: group))
                    }
                }
            }
        }
        .onAppear {
            viewModel.authService = diContainer.authService
            viewModel.userService = diContainer.userService
            viewModel.groupChatService = diContainer.groupChatService
            viewModel.onViewAppear()
        }
        .navigationTitle("Groups")
        .sheet(isPresented: $showCreateGroupSheet) {
            CreateGroupSheet(
                viewModel: $viewModel,
                groupName: $groupName,
                showCreateGroupSheet: $showCreateGroupSheet,
                showUserSelection: $showUserSelection
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showUserSelection, onDismiss: {
            groupName = ""
        }) {
            UserSelectionSheet(
                viewModel: $viewModel,
                groupName: $groupName
            )
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview("GroupChatListScreen") {
    GroupChatListScreen()
        .withPreviewEnvironments()
}
