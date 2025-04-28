//
//
// CreateGroupSheet.swift
// QuickChat
//
// Created by Nand on 28/04/25
//
        

import Foundation
import SwiftUI

struct CreateGroupSheet: View {
    @Binding var viewModel: GroupChatListViewModel
    @Binding var groupName: String
    @Binding var showCreateGroupSheet: Bool
    @Binding var showUserSelection: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group name")
                .font(.system(size: 34, weight: .bold, design: .default))
                .padding(.top, 4)
            
            VStack {
                TextField("Enter group name", text: $groupName)
                    .padding()
            }
            .frame(height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(groupName.count > 2 ? .blue.opacity(0.7) : .gray.opacity(0.7), lineWidth: 1)
            )
            .background(.white)
            .padding(.top, 24)
            
            Text("Minimum 3 characters")
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(.gray.opacity(0.6))
            
            Spacer()
            
            QuickChatPrimaryButton(title: "Next", activeColor: .white, inActiveColor: .gray, isActive: Binding(
                get: { groupName.count > 2 },
                set: { _ in }
            )) {
                showCreateGroupSheet.toggle()
                showUserSelection.toggle()
            }
            .padding(.top, 12)
        }
        .padding()
        
    }
}
