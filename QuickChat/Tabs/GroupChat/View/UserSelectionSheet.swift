//
//
// UserSelectionSheet.swift
// QuickChat
//
// Created by Nand on 28/04/25
//


import Foundation
import SwiftUI

struct UserSelectionSheet: View {
    @Binding var viewModel: GroupChatListViewModel
    @Binding var groupName: String
    @State private var selectedUserIds: Set<String> = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 0) {
                Text(" \(groupName)")
                    .font(.system(size: 30, weight: .bold, design: .default))
                
                Text("Add members in")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundStyle(.gray.opacity(0.7))
            }
            .padding(.top, 4)
            
            List(viewModel.users) { user in
                HStack {
                    Text(user.displayName ?? user.email ?? "Unknown")
                    Spacer()
                    if selectedUserIds.contains(user.uid) {
                        Image(systemName: "checkmark")
                    }
                }
                .listRowBackground(Color.gray.opacity(0.3))
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedUserIds.contains(user.uid) {
                        selectedUserIds.remove(user.uid)
                    } else {
                        selectedUserIds.insert(user.uid)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            
            
            Spacer()
            
            Text("Click on the user to add/remove")
                .font(.system(size: 12, weight: .regular, design: .default))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.gray.opacity(0.6))
                .multilineTextAlignment(.center)
            
            QuickChatPrimaryButton(title: "Create Group", activeColor: .white, inActiveColor: .gray, isActive: Binding(
                get: { !selectedUserIds.isEmpty },
                set: { _ in }
            )) {
                Task {
                    let allMemberIds = Array(selectedUserIds) + [viewModel.currentUserId ?? ""]
                    try? await viewModel.createGroup(name: groupName, memberIds: allMemberIds)
                    await viewModel.fetchGroups()
                    groupName = ""
                    dismiss()
                }
            }
        }
        .padding()
    }
}
