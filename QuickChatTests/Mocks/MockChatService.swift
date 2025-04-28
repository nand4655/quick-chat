//
//
// MockChatService.swift
// QuickChatTests
//
// Created by Nand on 28/04/25
//
        

import Foundation
@testable import QuickChat

class MockChatService: IChatService {
    var conversationsToReturn: [Conversation] = []
    var messagesToReturn: [ChatMessage] = []
    var shouldThrow = false
    
    func fetchConversations(for userId: String) async throws -> [Conversation] {
        if shouldThrow { throw NSError(domain: "Test", code: 2) }
        // Return only conversations where userId is a participant
        return conversationsToReturn.filter { $0.userIds.contains(userId) }
    }
    
    func fetchMessages(with userId: String, and otherUserId: String) async throws -> [ChatMessage] {
        if shouldThrow { throw NSError(domain: "Test", code: 2) }
        // Return messages between userId and otherUserId
        return messagesToReturn.filter {
            ($0.senderId == userId && $0.receiverId == otherUserId) ||
            ($0.senderId == otherUserId && $0.receiverId == userId)
        }
    }
    
    func sendMessage(_ message: ChatMessage, to otherUserId: String) async throws {
        if shouldThrow { throw NSError(domain: "Test", code: 2) }
        // Simulate sending by appending to messagesToReturn
        var msg = message
        msg.id = UUID().uuidString
        messagesToReturn.append(msg)
    }
    
    func setTyping(isTyping: Bool, with userId: String, and otherUserId: String) async throws {
        // No-op for mock
    }
    
    var observeTypingHandler: ((String, String, @escaping (Bool) -> Void) -> Void)?
    func observeTyping(with userId: String, and otherUserId: String, onChange: @escaping (Bool) -> Void) {
        observeTypingHandler?(userId, otherUserId, onChange)
    }
    
    func observeMessages(with userId: String, and otherUserId: String, onChange: @escaping ([ChatMessage]) -> Void) {
        // Immediately return current messages for mock
        let filtered = messagesToReturn.filter {
            ($0.senderId == userId && $0.receiverId == otherUserId) ||
            ($0.senderId == otherUserId && $0.receiverId == userId)
        }
        onChange(filtered)
    }
    
    func updateMessageStatus(with userId: String, and otherUserId: String, messageId: String, status: MessageStatus) async throws {
        if shouldThrow { throw NSError(domain: "Test", code: 2) }
        if let idx = messagesToReturn.firstIndex(where: { $0.id == messageId }) {
            messagesToReturn[idx].status = status
        }
    }
}
