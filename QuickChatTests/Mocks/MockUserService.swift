//
//
// MockUserService.swift
// QuickChatTests
//
// Created by Nand on 28/04/25
//
        

import Foundation
@testable import QuickChat

class MockUserService: IUserService {
    var usersToReturn: [UserDetailsModel] = []
    var shouldThrow = false
    
    var observeUsersHandler: (([UserDetailsModel]) -> Void)?
    func observeUsers(onChange: @escaping ([UserDetailsModel]) -> Void) {
        observeUsersHandler = onChange
        // Immediately return current users for mock
        onChange(usersToReturn)
    }
    
    func checkIfUserExists(uid: String) async throws -> Bool {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return usersToReturn.contains(where: { $0.uid == uid })
    }
    
    func createUser(user: UserDetailsModel) async throws {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        usersToReturn.append(user)
    }
    
    func getUser(uid: String) async throws -> UserDetailsModel? {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return usersToReturn.first(where: { $0.uid == uid })
    }
    
    func listUsers() async throws -> [UserDetailsModel] {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return usersToReturn
    }
    
    func deleteUser(uid: String) async throws {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        usersToReturn.removeAll(where: { $0.uid == uid })
    }
    
    func updateUser(user: UserDetailsModel) async throws {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        if let idx = usersToReturn.firstIndex(where: { $0.uid == user.uid }) {
            usersToReturn[idx] = user
        }
    }
}
