//
//
// GroupChatService.swift
// QuickChat
//
// Created by Nand on 28/04/25
//


import Foundation
import FirebaseFirestore

public protocol IGroupChatService {
    func createGroup(name: String, memberIds: [String]) async throws
    func fetchGroups(for userId: String) async throws -> [UserGroup]
    func fetchMessages(for groupId: String) async throws -> [GroupMessage]
    func sendMessage(_ message: GroupMessage, to groupId: String) async throws
    func setTyping(isTyping: Bool, groupId: String, userId: String) async throws
    func observeMessages(for groupId: String, onChange: @escaping ([GroupMessage]) -> Void)
    func observeTyping(groupId: String, currentUserId: String, onChange: @escaping (Bool) -> Void)
}

public final class GroupChatService: IGroupChatService {
    private let dbService: IDatabaseService
    private let groupsCollection = "groups"
    private let messagesSubcollection = "messages"
    private let typingSubcollection = "typing"
    
    public init(dbService: IDatabaseService) {
        self.dbService = dbService
    }
    
    public func createGroup(name: String, memberIds: [String]) async throws {
        let group = UserGroup(
            id: nil,
            name: name,
            memberIds: memberIds,
            createdAt: Date(),
            lastMessage: nil,
            lastMessageTimestamp: nil
        )
        let groupId = UUID().uuidString
        try await dbService.create(collection: groupsCollection, id: groupId, data: group)
    }
    
    public func fetchGroups(for userId: String) async throws -> [UserGroup] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection(groupsCollection)
            .whereField("memberIds", arrayContains: userId)
            .getDocuments()
        let groups = snapshot.documents.compactMap { try? $0.data(as: UserGroup.self) }
        return groups.sorted { ($0.lastMessageTimestamp ?? .distantPast) > ($1.lastMessageTimestamp ?? .distantPast) }
    }
    
    public func fetchMessages(for groupId: String) async throws -> [GroupMessage] {
        return try await dbService.listSubcollection(collection: groupsCollection, documentId: groupId, subcollection: messagesSubcollection)
    }
    
    public func sendMessage(_ message: GroupMessage, to groupId: String) async throws {
        try await dbService.addToSubcollection(collection: groupsCollection, documentId: groupId, subcollection: messagesSubcollection, data: message)
        // Optionally update lastMessage and lastMessageTimestamp in group doc
        try await dbService.updateFields(
            collection: groupsCollection,
            id: groupId,
            data: [
                "lastMessage": message.text,
                "lastMessageTimestamp": message.timestamp
            ]
        )
    }
    
    public func setTyping(isTyping: Bool, groupId: String, userId: String) async throws {
        let db = Firestore.firestore()
        try await db.collection(groupsCollection)
            .document(groupId)
            .collection(typingSubcollection)
            .document(userId)
            .setData(["isTyping": isTyping])
    }
    
    public func observeMessages(for groupId: String, onChange: @escaping ([GroupMessage]) -> Void) {
        let db = Firestore.firestore()
        db.collection(groupsCollection)
            .document(groupId)
            .collection(messagesSubcollection)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                let messages = snapshot?.documents.compactMap { try? $0.data(as: GroupMessage.self) } ?? []
                onChange(messages)
            }
    }
    
    public func observeTyping(groupId: String, currentUserId: String, onChange: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection(groupsCollection)
            .document(groupId)
            .collection(typingSubcollection)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else {
                    onChange(false)
                    return
                }
                // Check if any user (except current) is typing
                let someoneElseTyping = docs.contains { doc in
                    doc.documentID != currentUserId && (doc["isTyping"] as? Bool ?? false)
                }
                onChange(someoneElseTyping)
            }
    }
}
