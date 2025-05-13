//
//  AuthService.swift
//  Wedding Yantra
//
// Created by Nand on 09/08/24
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import CryptoKit

@Observable
public final class AuthService: IAuthService, @unchecked Sendable {
    private let _auth = Auth.auth()
    let googleOAuthProvider: GoogleOAuthProvider
    let appleOAuthProvider: AppleOAuthProvider
    public private(set) var isLoggedIn: Bool = false
    
    private var _currentUser: UserDetailsModel? = nil
    public var currentUser: UserDetailsModel? {
        _currentUser
    }
    
    public init(googleOAuthProvider: GoogleOAuthProvider, appleOAuthProvider: AppleOAuthProvider) {
        self.googleOAuthProvider = googleOAuthProvider
        self.appleOAuthProvider = appleOAuthProvider
        Task {
            await setCurrentUser()
            await setIsLoggedIn()
        }
    }
    
    public func singIn(with type: OAuthProviderType) async -> AuthResult {
        switch type {
            case .apple:
                return await signInWithApple()
            case .google:
                return await signInWithGoogle()
        }
    }
    
    public func signInWithGoogle() async -> AuthResult {
        guard let credential = await googleOAuthProvider.signIn() else {
            return .failure(AuthError.invalidCredential)
        }
        
        do {
            let authResult = try await _auth.signIn(with: credential)
            await setCurrentUser()
            return .success(uid: authResult.user.uid)
        }
        catch(let e) {
            print("error in signInWithGoogle: \(e)")
        }
        
        return .failure(.authenticationFailed)
    }
    
    public func signInWithApple() async -> AuthResult {
        guard let credential = await appleOAuthProvider.signIn() else {
            return .failure(AuthError.invalidCredential)
        }
        
        do {
            let authResult = try await _auth.signIn(with: credential)
            await setCurrentUser()
            return .success(uid: authResult.user.uid)
        }
        catch(let e) {
            print("error in signInWithApple: \(e)")
        }
        
        return .failure(.authenticationFailed)
    }
    
    public func signOut() async -> AuthResult {
        guard let uid = _auth.currentUser?.uid else {
            return .failure(.userNotLoggedIn)
        }
        
        do {
            try _auth.signOut()
            await setCurrentUser()
            await setIsLoggedIn()
            return .success(uid: uid)
        }
        catch(let e) {
            print("error in signOut: \(e)")
        }
        
        return .failure(.signedOutFailed)
    }
    
    public func setCurrentUser() async {
        await MainActor.run {
            if let user = self._auth.currentUser {
                self._currentUser =  UserDetailsModel(uid: user.uid, email: user.email, displayName: user.displayName, photoURL: user.photoURL?.absoluteString, createdAt: nil, lastLoginAt: nil)
            }
        }
    }
    
    public func setIsLoggedIn() async {
        await MainActor.run {
            self.isLoggedIn = self._auth.currentUser != nil
        }
    }
}
