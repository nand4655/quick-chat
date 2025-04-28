//
//
// LoginViewModel.swift
// QuickChat
//
// Created by Nand on 25/04/25
//
        

import Foundation
import SwiftUI

@Observable
final class LoginViewModel {
    var authService: IAuthService?
    var userService: IUserService?
    
    var isSignedIn = false
    
    func signInWithApple() async {
        guard let authService else {
            return
        }
        
        let res = await authService.signInWithApple()
        switch res {
            case .success(let uid):
                onSignInSuccess(uid: uid)
                
            case .failure:
                onSignInFailure()
        }
    }
    
    func signInWithGoogle() async {
        guard let authService else {
            return
        }
        
        let res = await authService.signInWithGoogle()
        switch res {
            case .success(let uid):
                onSignInSuccess(uid: uid)
         
            case .failure:
                onSignInFailure()
        }
    }
    
    func onSignInSuccess(uid: String) {
        guard let authService,
                let userService,
                var currentUser = authService.currentUser else {
            return
        }
        
        Task {
            do {
                if try await userService.checkIfUserExists(uid: uid) == false {
                    currentUser.updateCreatedAt()
                    currentUser.updateLastLoginAt()
                    try await userService.createUser(user: currentUser)
                } else {
                    currentUser.updateLastLoginAt()
                    try await userService.updateUser(user: currentUser)
                }
                await authService.setIsLoggedIn()
            } catch {
                print("Error: \(error)")
            }
        }
        
        DispatchQueue.main.async {
            self.isSignedIn = true
            print("Google sign-in success")
        }
    }
    
    func onSignInFailure() {
        DispatchQueue.main.async {
            self.isSignedIn = false
            print("Google sign-in failed")
        }
    }
}
