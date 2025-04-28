//
//
// Contract.swift
// Wedding Yantra
//
// Created by Nand on 09/08/24
//


import Foundation
import FirebaseAuth

public protocol IAuthService {
    var currentUser: UserDetailsModel? { get }
    var isLoggedIn: Bool { get }
    @discardableResult func signInWithGoogle() async -> AuthResult
    @discardableResult func signInWithApple() async -> AuthResult
    func singIn(with type: OAuthProviderType) async -> AuthResult
    func signOut() async -> AuthResult
    func setIsLoggedIn() async
}

public enum AuthResult {
    case success(uid: String)
    case failure(AuthError)
}

public enum AuthError: Error {
    case invalidCredential
    case missingNonce
    case missingToken
    case serializationError
    case authenticationFailed
    case signedOutFailed
    case userNotLoggedIn    
}

public enum OAuthProviderType {
    case google
    case apple
}
