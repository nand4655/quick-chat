//
//
// MockAuthService.swift
// QuickChatTests
//
// Created by Nand on 28/04/25
//
        

import Foundation
import XCTest
@testable import QuickChat

class MockAuthService: IAuthService {
    
    var currentUser: UserDetailsModel?
    var isLoggedIn: Bool = false
    
    // Control these for test scenarios
    var signInResult: AuthResult = .failure(.authenticationFailed)
    var signOutResult: AuthResult = .success(uid: "mockUser")
    var shouldCallSetIsLoggedIn = false
    
    @discardableResult
    func singIn(with type: OAuthProviderType) async -> AuthResult {
        isLoggedIn = (signInResult.isSuccess)
        if isLoggedIn {
            currentUser = UserDetailsModel(
                uid: "mockUser",
                email: "mock@user.com",
                displayName: "Mock User",
                photoURL: nil,
                createdAt: Date(),
                lastLoginAt: Date()
            )
        } else {
            currentUser = nil
        }
        return signInResult
    }
    
    func signInWithGoogle() async -> AuthResult {
        return await singIn(with: .google)
    }
    
    func signInWithApple() async -> AuthResult {
        return await singIn(with: .apple)
    }
    
    func signOut() async -> AuthResult {
        isLoggedIn = false
        currentUser = nil
        return signOutResult
    }
    
    var stubbedIsLoggedIn: Bool = false
    var stubbedUserDetails: UserDetailsModel?
    func setIsLoggedIn() async {
        isLoggedIn = stubbedIsLoggedIn
        currentUser = stubbedUserDetails
    }
}

// Helper for AuthResult success check
extension AuthResult {
    var isSuccess: Bool {
        switch self {
            case .success: return true
            default: return false
        }
    }
}
