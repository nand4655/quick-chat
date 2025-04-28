//
//
// MockGroupChatService.swift
// QuickChatTests
//
// Created by Nand on 28/04/25
//
        

import Foundation
import XCTest
@testable import QuickChat

// A simple mock for IGroupChatService
class MockGroupChatService: IGroupChatService {
    var groupsToReturn: [UserGroup] = []
    var shouldThrowFetch = false
    var createdGroup: (name: String, memberIds: [String])?
    
    var messagesToReturn: [GroupMessage] = []
    var sendMessageCalled = false
    var setTypingCalled: (isTyping: Bool, groupId: String, userId: String)?
    var observeMessagesHandler: (([GroupMessage]) -> Void)?
    var observeTypingHandler: ((Bool) -> Void)?
    
    func createGroup(name: String, memberIds: [String]) async throws {
        createdGroup = (name, memberIds)
    }
    
    func fetchGroups(for userId: String) async throws -> [UserGroup] {
        if shouldThrowFetch { throw NSError(domain: "Test", code: 1) }
        return groupsToReturn
    }
    
    // Unused in these tests:
    func fetchMessages(for groupId: String) async throws -> [GroupMessage] {
        return messagesToReturn
    }
    
    // Track sendMessage calls
    func sendMessage(_ message: GroupMessage, to groupId: String) async throws {
        sendMessageCalled = true
    }
    
    // Track setTyping calls
    func setTyping(isTyping: Bool, groupId: String, userId: String) async throws {
        setTypingCalled = (isTyping, groupId, userId)
    }
    
    // Capture the callback for observeMessages
    func observeMessages(for groupId: String, onChange: @escaping ([GroupMessage]) -> Void) {
        observeMessagesHandler = onChange
    }
    
    // Capture the callback for observeTyping
    func observeTyping(groupId: String, currentUserId: String, onChange: @escaping (Bool) -> Void) {
        observeTypingHandler = onChange
    }
}
