//
//
// FirestoreService.swift
// QuickChat
//
// Created by Nand on 26/04/25
//


import Foundation
import FirebaseFirestore

//TODO: Utilise this for better error handling
public enum DatabaseError: Error {
    case documentNotFound
    case invalidData
    case encodingError
    case decodingError
    case operationFailed(String)
}

public protocol IDatabaseService {
    func create<T: Codable>(collection: String, id: String, data: T) async throws
    func read<T: Codable>(collection: String, id: String) async throws -> T?
    func update<T: Codable>(collection: String, id: String, data: T) async throws
    func delete(collection: String, id: String) async throws
    func exists(collection: String, id: String) async throws -> Bool
    func list<T: Codable>(collection: String) async throws -> [T]
    func listSubcollection<T: Codable>(collection: String, documentId: String, subcollection: String) async throws -> [T]
    func addToSubcollection<T: Codable>(collection: String, documentId: String, subcollection: String, data: T) async throws
    func updateSubcollectionDocumentField(collection: String,documentId: String,subcollection: String,subdocumentId: String,data: [String: Any]) async throws
    func updateFields(collection: String,id: String,data: [String: Any]) async throws
}

public final class FirestoreService: IDatabaseService {
    private let db = Firestore.firestore()
    
    public init() {}
    
    public func create<T: Codable>(collection: String, id: String, data: T) async throws {
        try db.collection(collection).document(id).setData(from: data)
    }
    
    public func read<T: Codable>(collection: String, id: String) async throws -> T? {
        let docSnapshot = try await db.collection(collection).document(id).getDocument()
        guard docSnapshot.exists else { return nil }
        return try docSnapshot.data(as: T.self)
    }
    
    public func update<T: Codable>(collection: String, id: String, data: T) async throws {
        try db.collection(collection).document(id).setData(from: data, merge: true)
    }
    
    public func delete(collection: String, id: String) async throws {
        try await db.collection(collection).document(id).delete()
    }
    
    public func exists(collection: String, id: String) async throws -> Bool {
        let docSnapshot = try await db.collection(collection).document(id).getDocument()
        return docSnapshot.exists
    }
    
    public func list<T: Codable>(collection: String) async throws -> [T] {
        let querySnapshot = try await db.collection(collection).getDocuments()
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: T.self)
        }
    }
    
    public func listSubcollection<T: Codable>(collection: String, documentId: String, subcollection: String) async throws -> [T] {
        let snapshot = try await db.collection(collection).document(documentId).collection(subcollection).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }
    
    public func addToSubcollection<T: Codable>(collection: String, documentId: String, subcollection: String, data: T) async throws {
        _ = try db.collection(collection).document(documentId).collection(subcollection).addDocument(from: data)
    }
    
    public func updateSubcollectionDocumentField(collection: String,documentId: String,subcollection: String,subdocumentId: String,data: [String: Any]) async throws {
        let db = Firestore.firestore()
        try await db.collection(collection)
            .document(documentId)
            .collection(subcollection)
            .document(subdocumentId)
            .updateData(data)
    }
    
    public func updateFields(collection: String,id: String,data: [String: Any]) async throws {
        try await db.collection(collection).document(id).updateData(data)
    }
}

