//
//
// ChatListScreenViewModel.swift
// QuickChat
//
// Created by Nand on 28/04/25
//


import Foundation
import SwiftUI

@Observable
class ChatListScreenViewModel {
    var users: [UserDetailsModel] = []
    var chatSummaries: [Conversation] = []
    var isLoading = false
    
    var userService: IUserService?
    var chatService: IChatService?
    var authService: IAuthService?
    
    var currentUser: UserDetailsModel? {
        return authService?.currentUser
    }
    
    func onViewAppear() {
        Task {
            await loadUsers()
        }
        observeNewUsers()
    }
    
    func loadUsers() async {
        guard let userService else {
            return
        }
        
        guard let currentUserId = currentUser?.uid else {
            return
        }
        
        isLoading = true
        do {
            let allUsers = try await userService.listUsers()
            await MainActor.run {
                self.users = allUsers.filter { $0.uid != currentUserId }
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
    
    func observeNewUsers() {
        guard let userService else {
            return
        }
        
        guard let currentUserId = currentUser?.uid else {
            return
        }
        
        userService.observeUsers { [weak self] allUsers in
            guard let self else { return }
            Task { @MainActor in
                self.users = allUsers.filter { $0.uid != currentUserId }
            }
        }
    }
}

