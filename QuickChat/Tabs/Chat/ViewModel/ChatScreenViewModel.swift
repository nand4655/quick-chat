//
//
// ChatScreenViewModel.swift
// QuickChat
//
// Created by Nand on 28/04/25
//


import Foundation
import SwiftUI

@Observable
class ChatScreenViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var sendDisabled: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isOtherUserTyping: Bool = false
    var isLoading: Bool = false
    
    var chatService: IChatService?
    var authService: IAuthService?
    
    let otherUser: UserDetailsModel
    var currentUser: UserDetailsModel? {
        authService?.currentUser
    }
    
    private var typingTimer: Timer?
    
    init(otherUser: UserDetailsModel) {
        self.otherUser = otherUser
    }
    
    func onViewAppear() {
        Task {
            await loadMessages()
        }
        observeTyping()
        observeMessages()
    }
    
    
    func observeMessages() {
        guard let chatService else {
            return
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        chatService.observeMessages(
            with: currentUser.uid,
            and: otherUser.uid
        ) {
            [weak self] messages in
            guard let self else { return }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.messages = messages
                }
                
                for message in messages {
                    if message.receiverId == currentUser.uid && message.status == .sent, let messageId = message.id {
                        Task {
                            try? await chatService.updateMessageStatus(
                                with: currentUser.uid,
                                and: self.otherUser.uid,
                                messageId: messageId,
                                status: .read
                            )
                        }
                    }
                }
            }
        }
    }
    
    func loadMessages() async {
        guard let chatService else {
            return
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        isLoading = true
        do {
            let msgs = try await chatService.fetchMessages(with: currentUser.uid, and: otherUser.uid)
            await MainActor.run {
                withAnimation {
                    self.messages = msgs
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
    
    func sendMessage() async {
        guard let chatService else {
            return
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let message = ChatMessage(
            id: nil,
            senderId: currentUser.uid,
            receiverId: otherUser.uid,
            text: trimmed,
            timestamp: Date(),
            status: .sent,
            isTyping: nil
        )
        do {
            try await chatService.sendMessage(message, to: otherUser.uid)
            inputText = ""
            await loadMessages()
            try? await chatService.setTyping(isTyping: false, with: currentUser.uid, and: otherUser.uid)
        } catch {
            // Handle error
        }
    }
    
    func userIsTyping(isTyping: Bool) {
        guard let chatService else {
            return
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        Task { try? await chatService.setTyping(isTyping: isTyping, with: currentUser.uid, and: otherUser.uid) }
    }
    
    func observeTyping() {
        guard let chatService else {
            return
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        chatService.observeTyping(with: currentUser.uid, and: otherUser.uid) { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.isOtherUserTyping = isTyping
            }
        }
    }
}
