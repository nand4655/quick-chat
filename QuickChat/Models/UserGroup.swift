//
//
// File.swift
// Models
//
// Created by Nand on 28/04/25
//
        

import Foundation
import FirebaseFirestore

public struct UserGroup: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?
    public let name: String
    public let memberIds: [String]
    public let createdAt: Date
    public let lastMessage: String?
    public let lastMessageTimestamp: Date?
    
    public init(id: String? = nil, name: String, memberIds: [String], createdAt: Date, lastMessage: String?, lastMessageTimestamp: Date?) {
        self.id = id
        self.name = name
        self.memberIds = memberIds
        self.createdAt = createdAt
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
    }
}

public struct GroupMessage: Codable, Identifiable, Equatable {
    @DocumentID public var id: String?
    public let senderId: String
    public let text: String
    public let timestamp: Date
    public var status: MessageStatus
    
    public init(id: String? = nil, senderId: String, text: String, timestamp: Date, status: MessageStatus) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
        self.status = status
    }
}
