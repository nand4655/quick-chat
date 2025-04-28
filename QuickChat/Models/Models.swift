// The Swift Programming Language
// https://docs.swift.org/swift-book

import FirebaseFirestore
import Foundation

public enum MessageStatus: String, Codable {
    case sent, delivered, read
}

public struct ChatMessage: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?
    public let senderId: String
    public let receiverId: String
    public let text: String
    public let timestamp: Date
    public var status: MessageStatus
    public var isTyping: Bool? // Optional, for typing indicator
    
    public init(id: String? = nil, senderId: String, receiverId: String, text: String, timestamp: Date, status: MessageStatus, isTyping: Bool? = nil) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.text = text
        self.timestamp = timestamp
        self.status = status
        self.isTyping = isTyping
    }
}

public struct Conversation: Codable, Identifiable {
    @DocumentID public var id: String?
    public let userIds: [String] // Always 2 UIDs, sorted
    public let lastMessage: String?
    public let lastMessageTimestamp: Date?
    
    public init(id: String? = nil, userIds: [String], lastMessage: String?, lastMessageTimestamp: Date?) {
        self.id = id
        self.userIds = userIds
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
    }
}
