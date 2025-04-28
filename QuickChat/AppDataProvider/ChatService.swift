//
//
// ChatService.swift
// QuickChat
//
// Created by Nand on 26/04/25
//


import Foundation
import FirebaseFirestore

public protocol IChatService {
    func fetchConversations(for userId: String) async throws -> [Conversation]
    func fetchMessages(with userId: String, and otherUserId: String) async throws -> [ChatMessage]
    func sendMessage(_ message: ChatMessage, to otherUserId: String) async throws
    func setTyping(isTyping: Bool, with userId: String, and otherUserId: String) async throws
    func observeTyping(with userId: String, and otherUserId: String, onChange: @escaping (Bool) -> Void)
    func observeMessages(with userId: String, and otherUserId: String, onChange: @escaping ([ChatMessage]) -> Void)
    func updateMessageStatus(with userId: String, and otherUserId: String, messageId: String, status: MessageStatus) async throws
}

public final class ChatService: IChatService {
    private let dbService: IDatabaseService
    private let chatsCollection = "chats"
    private let messagesSubcollection = "messages"
    
    public init(dbService: IDatabaseService) {
        self.dbService = dbService
    }
    
    private func chatId(for userA: String, userB: String) -> String {
        [userA, userB].sorted().joined(separator: "_")
    }
    
    // Fetch all conversations for a user (latest message per chat)
    public func fetchConversations(for userId: String) async throws -> [Conversation] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection(chatsCollection)
            .whereField("userIds", arrayContains: userId)
            .getDocuments()
        
        var conversations: [Conversation] = []
        for doc in snapshot.documents {
            let chatId = doc.documentID
            let userIds = doc["userIds"] as? [String] ?? []
            // Get last message
            let messages = try await dbService.listSubcollection(collection: chatsCollection, documentId: chatId, subcollection: messagesSubcollection) as [ChatMessage]
            let lastMsg = messages.sorted(by: { $0.timestamp > $1.timestamp }).first
            let lastMessageText = lastMsg?.text
            let lastMessageTimestamp = lastMsg?.timestamp
            conversations.append(
                Conversation(
                    id: chatId,
                    userIds: userIds,
                    lastMessage: lastMessageText,
                    lastMessageTimestamp: lastMessageTimestamp
                )
            )
        }
        // Sort by last message timestamp descending
        return conversations.sorted { ($0.lastMessageTimestamp ?? .distantPast) > ($1.lastMessageTimestamp ?? .distantPast) }
    }
    
    public func fetchMessages(with userId: String, and otherUserId: String) async throws -> [ChatMessage] {
        let chatId = chatId(for: userId, userB: otherUserId)
        let messages = try await dbService.listSubcollection(collection: chatsCollection, documentId: chatId, subcollection: messagesSubcollection) as [ChatMessage]
        return messages.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    public func sendMessage(_ message: ChatMessage, to otherUserId: String) async throws {
        let chatId = chatId(for: message.senderId, userB: otherUserId)
        // Ensure chat document exists with userIds
        try await dbService.create(collection: chatsCollection, id: chatId, data: ["userIds": [message.senderId, otherUserId]])
        // Add message to subcollection
        try await dbService.addToSubcollection(collection: chatsCollection, documentId: chatId, subcollection: messagesSubcollection, data: message)
    }
    
    public func setTyping(isTyping: Bool, with userId: String, and otherUserId: String) async throws {
        let chatId = chatId(for: userId, userB: otherUserId)
        try await dbService.update(collection: chatsCollection, id: chatId, data: ["typing_\(userId)": isTyping])
    }
    
    public func observeTyping(with userId: String, and otherUserId: String, onChange: @escaping (Bool) -> Void) {
        let chatId = chatId(for: userId, userB: otherUserId)
        Firestore.firestore()
            .collection(chatsCollection)
            .document(chatId)
            .addSnapshotListener { snapshot, error in
                let data = snapshot?.data()
                let typing = data?["typing_\(otherUserId)"] as? Bool ?? false
                onChange(typing)
            }
    }
    
    public func observeMessages(with userId: String, and otherUserId: String, onChange: @escaping ([ChatMessage]) -> Void) {
        let chatId = chatId(for: userId, userB: otherUserId)
        Firestore.firestore()
            .collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                print("observeMessages snapshot received") // Add this
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else {
                    return
                }
                let messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                onChange(messages)
            }
    }
    
    public func updateMessageStatus(with userId: String, and otherUserId: String, messageId: String, status: MessageStatus) async throws {
        let chatId = chatId(for: userId, userB: otherUserId)
        try await dbService.updateSubcollectionDocumentField(
            collection: "chats",
            documentId: chatId,
            subcollection: "messages",
            subdocumentId: messageId,
            data: ["status": status.rawValue]
        )
    }
}

