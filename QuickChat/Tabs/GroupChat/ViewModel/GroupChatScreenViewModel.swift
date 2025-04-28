//
//
// GroupChatScreenViewModel.swift
// QuickChat
//
// Created by Nand on 28/04/25
//
        

import Foundation
import FirebaseFirestore

@Observable
class GroupChatScreenViewModel {
    var messages: [GroupMessage] = []
    var inputText: String = ""
    
    var authService: IAuthService?
    var groupChatService: IGroupChatService?
    let group: UserGroup
    
    
    var isOtherUserTyping: Bool = false
    var isLoading: Bool = false
    
    var sendDisabled: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var currentUser: UserDetailsModel? {
        authService?.currentUser
    }
    
    init(group: UserGroup) {
        self.group = group
    }
    
    func onViewAppear() {
        observeTyping()
        observeMessages()
    }
    
    func observeMessages() {
        guard let groupChatService else {
            return
        }
        
        guard let groupId = group.id else {
            return
        }
        
        groupChatService.observeMessages(for: groupId) { [weak self] messages in
            DispatchQueue.main.async {
                self?.messages = messages
                self?.markMessagesAsDelivered(messages)
            }
        }
    }
    
    func sendMessage() async {
        guard let groupChatService else {
            return
        }
        
        guard let currentUserUid = currentUser?.uid else {
            return
        }
        
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let message = GroupMessage(
            id: nil,
            senderId: currentUserUid,
            text: trimmed,
            timestamp: Date(),
            status: .sent
        )
        do {
            try await groupChatService.sendMessage(message, to: group.id ?? "")
            inputText = ""
        } catch {
            // Handle error
        }
    }
    
    func userIsTyping(isTyping: Bool) {
        guard let groupChatService else {
            return
        }
        
        guard let currentUserUid = currentUser?.uid, let groupId = group.id else {
            return
        }
        
        Task { try? await groupChatService.setTyping(isTyping: isTyping, groupId: groupId, userId: currentUserUid) }
    }
    
    
    func markMessagesAsDelivered(_ messages: [GroupMessage]) {
        // Optionally, update message status to delivered/read for group messages
        // This is more complex in groups, so we may want to skip or customize this
    }
    
    func observeTyping() {
        guard let groupChatService else {
            return
        }
        
        guard let currentUserUid = currentUser?.uid, let groupId = group.id else {
            return
        }
        
        groupChatService.observeTyping(groupId: groupId, currentUserId: currentUserUid) { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.isOtherUserTyping = isTyping
            }
        }
    }
}

