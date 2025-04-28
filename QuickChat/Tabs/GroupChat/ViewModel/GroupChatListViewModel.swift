//
//
// GroupChatListViewModel.swift
// QuickChat
//
// Created by Nand on 28/04/25
//
        

import Foundation
import SwiftUI

@Observable
class GroupChatListViewModel {
    var users: [UserDetailsModel] = []
    var groups: [UserGroup] = []
    var isLoading = false
    var isLoadingUsers = false
    
    var groupChatService: IGroupChatService?
    var authService: IAuthService?
    var userService: IUserService?
    
    var currentUserId: String? {
        authService?.currentUser?.uid
    }
    
    func onViewAppear() {
        Task { await fetchGroups() }
    }
    
    func fetchGroups() async {
        guard let currentUserId else {
            return
        }
        
        guard let groupChatService else {
            return
        }
        
        isLoading = true
        do {
            let fetched = try await groupChatService.fetchGroups(for: currentUserId)
            await MainActor.run {
                self.groups = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
    
    func loadUsers() async {
        guard let userService else {
            return
        }
        
        guard let currentUserId = authService?.currentUser?.uid else {
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
    
    func createGroup(name: String, memberIds: [String]) async throws {
        guard let groupChatService else {
            return
        }
        try await groupChatService.createGroup(name: name, memberIds: memberIds)
        await fetchGroups()
    }
}
