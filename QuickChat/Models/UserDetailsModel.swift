//
//
// File.swift
// Models
//
// Created by Nand on 28/04/25
//
        

import Foundation
import FirebaseFirestore

public struct UserDetailsModel: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?  // This will map to Firestore document ID
    public let uid: String             // Firebase Auth UID
    public let email: String?
    public let displayName: String?
    public let photoURL: String?
    public var createdAt: Date?
    public var lastLoginAt: Date?
    
    public init(id: String? = nil, uid: String, email: String?, displayName: String?, photoURL: String?, createdAt: Date? = nil, lastLoginAt: Date? = nil) {
        self.id = id
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
    
    public mutating func updateLastLoginAt() {
        self.lastLoginAt = Date()
    }
    
    public mutating func updateCreatedAt() {
        self.createdAt = Date()
    }
}
