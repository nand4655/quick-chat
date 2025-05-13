//
//
// UserService.swift
// QuickChat
//
// Created by Nand on 26/04/25
//
        

import Foundation
import FirebaseFirestore

public protocol IUserService {
    func checkIfUserExists(uid: String) async throws -> Bool
    func createUser(user: UserDetailsModel) async throws
    func getUser(uid: String) async throws -> UserDetailsModel?
    func listUsers() async throws -> [UserDetailsModel]
    func deleteUser(uid: String) async throws
    func updateUser(user: UserDetailsModel) async throws
    func observeUsers(onChange: @escaping ([UserDetailsModel]) -> Void)
}


public final class UserService: IUserService {
    private let dbService: IDatabaseService
    private let collectionName = "users"
    
    public init(dbService: IDatabaseService) {
        self.dbService = dbService
    }
    
    public func checkIfUserExists(uid: String) async throws -> Bool {
        return try await dbService.exists(collection: collectionName, id: uid)
    }
    
    public func createUser(user: UserDetailsModel) async throws {
        try await dbService.create(collection: collectionName, id: user.uid, data: user)
    }
    
    public func getUser(uid: String) async throws -> UserDetailsModel? {
        return try await dbService.read(collection: collectionName, id: uid)
    }
    
    public func listUsers() async throws -> [UserDetailsModel] {
        return try await dbService.list(collection: collectionName)
    }
    
    public func deleteUser(uid: String) async throws {
        try await dbService.delete(collection: collectionName, id: uid)
    }
    
    public func updateUser(user: UserDetailsModel) async throws {
        try await dbService.update(collection: collectionName, id: user.uid, data: user)
    }
    
    public func observeUsers(onChange: @escaping ([UserDetailsModel]) -> Void) {
        Firestore.firestore()
            .collection(collectionName)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error observing users: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else {
                    return
                }
                let users = docs.compactMap { try? $0.data(as: UserDetailsModel.self) }
                onChange(users)
            }
    }
}
