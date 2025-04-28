//
//
// GoogleOAuthProvider.swift
// Wedding Yantra
//
// Created by Nand on 09/08/24
//


import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import UIKit
import OSLog
import Utility

private let logger = Logger(subsystem:"com.QuickChat", category: "GoogleOAuthProvider")

public class GoogleOAuthProvider {
    private let auth = Auth.auth()
    
    public init() {}
    
    func signIn() async -> AuthCredential? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return nil
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let user = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDGoogleUser, Error>) in
                DispatchQueue.main.async {
                    GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) { user, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let user = user?.user, let idToken = user.idToken else {
                            continuation.resume(throwing: AuthError.invalidCredential)
                            return
                        }
                        
                        continuation.resume(returning: user)
                    }
                }
            }
            
            guard let idToken = user.idToken?.tokenString else { return nil }
            return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        } catch {
            return nil
        }
    }
}
