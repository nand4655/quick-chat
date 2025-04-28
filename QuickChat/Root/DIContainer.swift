//
//
// DIContainer.swift
// wapi-ai
//
// Created by Nand on 10/04/25
//
        

import Foundation
import SwiftUI
import StoreKit
import Firebase

@Observable
final class DIContainer: Observable {
    private(set) var isInitialized = false
    private(set) var authService: IAuthService!
    private(set) var dbService: IDatabaseService!
    private(set) var userService: IUserService!
    private(set) var chatService: IChatService!
    private(set) var groupChatService: IGroupChatService?
    
    init() {
        initializeDependencies()
    }
    
    private func initializeDependencies() {
        Task {            
            await registerDependencies()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { //Just to show splash animation
                self.isInitialized = true
            }
        }
    }
    
    private func registerDependencies() async {
        try? await Task.sleep(for: .seconds(1))
        self.dbService = FirestoreService()
        self.userService = UserService(dbService: dbService)
        self.chatService = ChatService(dbService: dbService)
        self.groupChatService = GroupChatService(dbService: dbService)
        authService = await AuthService(googleOAuthProvider: GoogleOAuthProvider(), appleOAuthProvider: AppleOAuthProvider())
    }
}



