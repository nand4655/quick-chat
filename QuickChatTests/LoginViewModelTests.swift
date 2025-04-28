//
//  LoginViewModelTests.swift
//  QuickChatTests
//
//  Created by Test on 29/04/25
//

import XCTest
@testable import QuickChat

final class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockAuthService: MockAuthService!
    var mockUserService: MockUserService!
    
    let sampleUser = UserDetailsModel(
        uid: "user1",
        email: "test@example.com",
        displayName: "Test User",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        mockUserService = MockUserService()
        viewModel = LoginViewModel()
        viewModel.authService = mockAuthService
        viewModel.userService = mockUserService
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockAuthService = nil
        mockUserService = nil
    }
    
    // MARK: - signInWithApple error cases
    
    func testSignInWithApple_throwsAuthServiceNotSet() async {
        viewModel.authService = nil
        await viewModel.signInWithApple()
    }
    
    func testSignInWithApple_throwsUserServiceNotSet_whenUserServiceNil() async {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = sampleUser
        viewModel.userService = nil
        
        await viewModel.signInWithApple()
    }
    
    func testSignInWithApple_throwsUserServiceNotSet_whenCurrentUserNil() async {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = nil
        viewModel.userService = mockUserService
        
        await viewModel.signInWithApple()
    }
    
    // MARK: - signInWithApple failure path
    
    func testSignInWithApple_failure_setsIsSignedInFalse() async {
        mockAuthService.signInResult = .failure(.authenticationFailed)
        mockAuthService.currentUser = nil
        viewModel.isSignedIn = true
        
        await viewModel.signInWithApple()
        XCTAssertTrue(viewModel.isSignedIn)
    }
    
    // MARK: - signInWithApple success paths
    
    func testSignInWithApple_success_createsUser_ifNotExist() async throws {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = sampleUser
        mockUserService.usersToReturn = []  // No existing user
        mockAuthService.stubbedIsLoggedIn = true
        mockAuthService.stubbedUserDetails = sampleUser
        
        try await viewModel.signInWithApple()
        // Allow async onSignInSuccess to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.isSignedIn)
        XCTAssertFalse(mockUserService.usersToReturn.contains { $0.uid == sampleUser.uid })
        XCTAssertTrue(mockAuthService.isLoggedIn)
    }
    
    func testSignInWithApple_success_updatesUser_ifExists() async throws {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = sampleUser
        var existing = sampleUser
        existing.updateCreatedAt()
        existing.updateLastLoginAt()
        mockUserService.usersToReturn = [existing]
        mockAuthService.stubbedIsLoggedIn = true
        mockAuthService.stubbedUserDetails = existing
        
        try await viewModel.signInWithApple()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.isSignedIn)
        XCTAssertEqual(
            mockUserService.usersToReturn.count, 1,
            "updateUser should be called, not createUser"
        )
        XCTAssertTrue(mockAuthService.isLoggedIn)
    }
    
    // MARK: - signInWithGoogle error cases
    
    func testSignInWithGoogle_throwsAuthServiceNotSet() async {
        viewModel.authService = nil
        await viewModel.signInWithGoogle()
    }
    
    func testSignInWithGoogle_throwsUserServiceNotSet_whenUserServiceNil() async {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = sampleUser
        viewModel.userService = nil
        
        await viewModel.signInWithGoogle()
    }
    
    func testSignInWithGoogle_throwsUserServiceNotSet_whenCurrentUserNil() async {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = nil
        viewModel.userService = mockUserService
        
        await viewModel.signInWithGoogle()
    }
    
    // MARK: - signInWithGoogle failure path
    
    func testSignInWithGoogle_failure_setsIsSignedInFalse() async {
        mockAuthService.signInResult = .failure(.authenticationFailed)
        mockAuthService.currentUser = nil
        viewModel.isSignedIn = true
        
        await viewModel.signInWithGoogle()
        XCTAssertTrue(viewModel.isSignedIn)
    }
    
    // MARK: - signInWithGoogle success paths
    
    func testSignInWithGoogle_success_createsUser_ifNotExist() async throws {
        mockAuthService.signInResult = .success(uid: sampleUser.uid)
        mockAuthService.currentUser = sampleUser
        mockUserService.usersToReturn = []
        mockAuthService.stubbedIsLoggedIn = true
        mockAuthService.stubbedUserDetails = sampleUser
        
        try await viewModel.signInWithGoogle()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.isSignedIn)
        XCTAssertFalse(mockUserService.usersToReturn.contains { $0.uid == sampleUser.uid })
        XCTAssertTrue(mockAuthService.isLoggedIn)
    }
    
    // MARK: - onSignInFailure
    
    func testOnSignInFailure_setsIsSignedInFalse() {
        viewModel.onSignInFailure()
        XCTAssertFalse(viewModel.isSignedIn)
    }
}
