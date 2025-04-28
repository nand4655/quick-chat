//
//  GroupChatListViewModelTests.swift
//  QuickChatTests
//
//  Created by Test on 29/04/25
//

import XCTest
@testable import QuickChat

final class GroupChatListViewModelTests: XCTestCase {
    var viewModel: GroupChatListViewModel!
    var mockGroupService: MockGroupChatService!
    var mockAuthService: MockAuthService!
    var mockUserService: MockUserService!
    
    let dummyGroup = UserGroup(
        id: "g1",
        name: "Dummy",
        memberIds: ["me","u2"],
        createdAt: Date(),
        lastMessage: nil,
        lastMessageTimestamp: nil
    )
    let dummyUser = UserDetailsModel(
        uid: "u2",
        email: "u2@test.com",
        displayName: "User2",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    let currentUser = UserDetailsModel(
        uid: "me",
        email: "me@test.com",
        displayName: "Me",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    let otherUser = UserDetailsModel(
        uid: "u2",
        email: "u2@test.com",
        displayName: "User2",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    
    override func setUpWithError() throws {
        mockGroupService = MockGroupChatService()
        mockAuthService = MockAuthService()
        mockUserService = MockUserService()
        
        mockAuthService.currentUser = currentUser
        
        viewModel = GroupChatListViewModel()
        viewModel.authService = mockAuthService
        viewModel.groupChatService = mockGroupService
        viewModel.userService = mockUserService
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockGroupService = nil
        mockAuthService = nil
        mockUserService = nil
    }
    
    // MARK: - fetchGroups tests
    
    func testFetchGroups_success() async throws {
        // Given
        mockGroupService.groupsToReturn = [
            UserGroup(
                id: "g1",
                name: "Group1",
                memberIds: ["me","u2"],
                createdAt: Date(),
                lastMessage: "Hello",
                lastMessageTimestamp: Date()
            )
        ]
        
        // When
        await viewModel.fetchGroups()
        
        // Then
        XCTAssertEqual(viewModel.groups.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.groups.first?.name, "Group1")
    }
    
    func testFetchGroups_failure() async throws {
        // Given
        mockGroupService.shouldThrowFetch = true
        viewModel.groups = []
        
        // When
        await viewModel.fetchGroups()
        
        // Then
        XCTAssertTrue(viewModel.groups.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testOnViewAppear_loadsGroups() {
        // Given
        mockGroupService.groupsToReturn = [
            UserGroup(
                id: "g1",
                name: "Group1",
                memberIds: ["me","u2"],
                createdAt: Date(),
                lastMessage: nil,
                lastMessageTimestamp: nil
            )
        ]
        
        // Expectation
        let exp = expectation(description: "onViewAppear loads groups")
        
        // When
        viewModel.onViewAppear()
        
        // Then: wait briefly for the Task to run
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.groups.count, 1)
            XCTAssertFalse(self.viewModel.isLoading)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - loadUsers tests
    
    func testLoadUsers_success_excludesCurrentUser() async throws {
        // Given
        mockUserService.usersToReturn = [currentUser, otherUser]
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertEqual(viewModel.users, [otherUser])
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadUsers_failure() async throws {
        // Given
        mockUserService.shouldThrow = true
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - createGroup tests
    
    func testCreateGroup_success_invokesService_andFetchesGroups() async throws {
        // Given
        let name = "NewGroup"
        let members = ["me", "u2"]
        mockGroupService.groupsToReturn = []
        
        // Prepare fetchGroups return after creation
        let created = UserGroup(
            id: "g2",
            name: name,
            memberIds: members,
            createdAt: Date(),
            lastMessage: nil,
            lastMessageTimestamp: nil
        )
        // After createGroup, fetchGroups will be called again:
        mockGroupService.groupsToReturn = [created]
        
        // When
        try await viewModel.createGroup(name: name, memberIds: members)
        
        // Then
        // Service was invoked
        XCTAssertEqual(mockGroupService.createdGroup?.name, name)
        XCTAssertEqual(mockGroupService.createdGroup?.memberIds, members)
        
        // And the viewModel's groups list was updated
        XCTAssertEqual(viewModel.groups, [created])
    }
    
    
    func testFetchGroups_earlyReturn_whenCurrentUserNil() async {
        // Arrange: authService missing
        viewModel.authService = nil
        viewModel.groups = [dummyGroup]
        viewModel.isLoading = true
        
        // Act
        await viewModel.fetchGroups()
        
        // Assert: no change to groups or isLoading
        XCTAssertEqual(viewModel.groups, [dummyGroup])
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func testFetchGroups_earlyReturn_whenGroupServiceNil() async {
        // Arrange: groupChatService missing
        viewModel.groupChatService = nil
        viewModel.groups = [dummyGroup]
        viewModel.isLoading = true
        
        // Act
        await viewModel.fetchGroups()
        
        // Assert
        XCTAssertEqual(viewModel.groups, [dummyGroup])
        XCTAssertTrue(viewModel.isLoading)
    }
    
    // MARK: - loadUsers guard tests
    
    func testLoadUsers_earlyReturn_whenUserServiceNil() async {
        // Arrange: userService missing
        viewModel.userService = nil
        viewModel.users = [dummyUser]
        viewModel.isLoading = true
        
        // Act
        await viewModel.loadUsers()
        
        // Assert
        XCTAssertEqual(viewModel.users, [dummyUser])
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func testLoadUsers_earlyReturn_whenCurrentUserNil() async {
        // Arrange: authService.currentUser missing
        mockAuthService.currentUser = nil
        viewModel.users = [dummyUser]
        viewModel.isLoading = true
        
        // Act
        await viewModel.loadUsers()
        
        // Assert
        XCTAssertEqual(viewModel.users, [dummyUser])
        XCTAssertTrue(viewModel.isLoading)
    }
    
    // MARK: - createGroup guard test
    
    func testCreateGroup_earlyReturn_whenGroupServiceNil() async {
        // Arrange: groupChatService missing
        viewModel.groupChatService = nil
        viewModel.groups = [dummyGroup]
        
        // Act
        do {
            try await viewModel.createGroup(name: "X", memberIds: ["me","u2"])
        } catch {
            XCTFail("createGroup should not throw when service is nil")
        }
        
        // Assert: groups unchanged
        XCTAssertEqual(viewModel.groups, [dummyGroup])
    }

}
