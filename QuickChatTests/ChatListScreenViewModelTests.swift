//
//
// ChatListScreenViewModelTests.swift
// QuickChatTests
//
// Created by Nand on 28/04/25
//
        

import Foundation
import XCTest
@testable import QuickChat

final class ChatListScreenViewModelTests: XCTestCase {
    var mockUserService: MockUserService!
    var mockChatService: MockChatService!
    var mockAuthService: MockAuthService!
    var viewModel: ChatListScreenViewModel!
    let currentUserId = "mockUser"
    
    override func setUp() {
        super.setUp()
        mockUserService = MockUserService()
        mockChatService = MockChatService()
        mockAuthService = MockAuthService()
        viewModel = ChatListScreenViewModel()
        
        viewModel.chatService = mockChatService
        viewModel.userService = mockUserService
        viewModel.authService = mockAuthService
    }
    
    func testLoadUsers_success_excludesCurrentUser() async {
        let user1 = UserDetailsModel(uid: "1", email: "a@a.com", displayName: "A", photoURL: nil, createdAt: nil, lastLoginAt: nil)
        let user2 = UserDetailsModel(uid: "2", email: "b@b.com", displayName: "B", photoURL: nil, createdAt: nil, lastLoginAt: nil)
        let currentUser = UserDetailsModel(uid: currentUserId, email: "me@me.com", displayName: "Me", photoURL: nil, createdAt: nil, lastLoginAt: nil)
        mockUserService.usersToReturn = [user1, user2, currentUser]
        
        mockAuthService.signInResult = .success(uid: "123")
        await mockAuthService.signInWithApple()
        await viewModel.loadUsers()
        
        XCTAssertEqual(viewModel.users.count, 2)
        XCTAssertFalse(viewModel.users.contains(where: { $0.uid == currentUserId }))
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadUsers_failure_setsError() async {
        mockUserService.shouldThrow = true
        mockAuthService.signInResult = .success(uid: "123")
        await mockAuthService.signInWithApple()
        await viewModel.loadUsers()
        
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadUsers_fatalError_whenUserServiceIsNil() async {
        viewModel.userService = nil
        viewModel.authService = mockAuthService
        mockAuthService.signInResult = .success(uid: "123")
        await mockAuthService.signInWithApple()
        await viewModel.loadUsers()
        XCTAssertEqual(viewModel.users.count, 0)
    }
    
    func testLoadUsers_fatalError_whenCurrentUserIsNil() async {
        viewModel.userService = mockUserService
        viewModel.authService = nil // or mockAuthService with no user
        await viewModel.loadUsers()
        XCTAssertEqual(viewModel.users.count, 0)
    }
    
    func testOnViewAppear_loadsUsers() async {
        let user1 = UserDetailsModel(uid: "1", email: "a@a.com", displayName: "A", photoURL: nil, createdAt: nil, lastLoginAt: nil)
        let user2 = UserDetailsModel(uid: "2", email: "b@b.com", displayName: "B", photoURL: nil, createdAt: nil, lastLoginAt: nil)
        let currentUser = UserDetailsModel(uid: currentUserId, email: "me@me.com", displayName: "Me", photoURL: nil, createdAt: nil, lastLoginAt: nil)
        mockUserService.usersToReturn = [user1, user2, currentUser]
        mockAuthService.signInResult = .success(uid: currentUserId)
        await mockAuthService.signInWithApple()
        
        await viewModel.onViewAppear()
        // Wait for the async task to complete
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        XCTAssertEqual(viewModel.users.count, 2)
        XCTAssertFalse(viewModel.users.contains(where: { $0.uid == currentUserId }))
        XCTAssertFalse(viewModel.isLoading)
    }
}
