//
//
// AppleOAuthProvider.swift
// Wedding Yantra
//
// Created by Nand on 09/08/24
//


import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import CryptoKit

public class AppleOAuthProvider: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    private var currentNonce: String?
    
    public override init() {}
    
    public func signIn() async -> OAuthCredential? {
        
        let nonce = String.randomNonce()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        DispatchQueue.main.async {
            authorizationController.performRequests()
        }
        
        do {
            let authResults = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ASAuthorization, Error>) in
                self.continuation = continuation
            }
            
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                return nil
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                return nil
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return nil
            }            
            
            return OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenString,
                rawNonce: nonce
            )
        } catch {
            return nil
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
        continuation = nil
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("Unable to find a UIWindowScene")
        }
        return windowScene.windows.first { $0.isKeyWindow }!
    }
}
