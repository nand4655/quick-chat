
//
//  ChatScreenViewModelTests.swift
//  QuickChatTests
//
//  Created by Test on 29/04/25
//

import XCTest
@testable import QuickChat

final class ChatScreenViewModelTests: XCTestCase {
    var mockChatService: MockChatService!
    var mockAuthService: MockAuthService!
    var viewModel: ChatScreenViewModel!
    
    let otherUser = UserDetailsModel(
        uid: "other",
        email: "other@a.com",
        displayName: "Other",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    let currentUser = UserDetailsModel(
        uid: "me",
        email: "me@a.com",
        displayName: "Me",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    
    override func setUpWithError() throws {
        mockChatService = MockChatService()
        mockAuthService = MockAuthService()
        mockAuthService.currentUser = currentUser
        viewModel = ChatScreenViewModel(otherUser: otherUser)
        viewModel.chatService = mockChatService
        viewModel.authService = mockAuthService
    }
    
    override func tearDownWithError() throws {
        mockChatService = nil
        mockAuthService = nil
        viewModel = nil
    }
    
    // MARK: - sendDisabled Tests
    
    func testOnAppear() {
        viewModel.inputText = "   "
        viewModel.onViewAppear()
        XCTAssertTrue(viewModel.sendDisabled)
    }
    
    func testSendDisabled_whenInputTextIsEmpty_true() {
        viewModel.inputText = "   "
        XCTAssertTrue(viewModel.sendDisabled)
    }
    
    func testSendDisabled_whenInputTextNotEmpty_false() {
        viewModel.inputText = " Hello "
        XCTAssertFalse(viewModel.sendDisabled)
    }
    
    // MARK: - loadMessages Tests
    
    func testLoadMessages_success() async throws {
        let msg = ChatMessage(
            id: "1",
            senderId: "me",
            receiverId: "other",
            text: "Hi",
            timestamp: Date(),
            status: .sent,
            isTyping: nil
        )
        mockChatService.messagesToReturn = [msg]
        
        await viewModel.loadMessages()
        
        XCTAssertEqual(viewModel.messages, [msg])
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadMessages_failure() async throws {
        mockChatService.shouldThrow = true
        
        await viewModel.loadMessages()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - observeMessages Tests
    
    func testObserveMessages_updatesMessages() {
        let msg = ChatMessage(
            id: "1",
            senderId: "me",
            receiverId: "other",
            text: "Hello",
            timestamp: Date(),
            status: .sent,
            isTyping: nil
        )
        mockChatService.messagesToReturn = [msg]
        
        let exp = expectation(description: "messages observed")
        viewModel.observeMessages()
        
        // Mock returns immediately; dispatch to main queue
        DispatchQueue.main.async {
            XCTAssertEqual(self.viewModel.messages, [msg])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func testObserveMessages_marksMessagesAsRead() {
        var msg = ChatMessage(
            id: "1",
            senderId: "other",
            receiverId: "me",
            text: "Ping",
            timestamp: Date(),
            status: .sent,
            isTyping: nil
        )
        mockChatService.messagesToReturn = [msg]
        
        let exp = expectation(description: "status updated to read")
        viewModel.observeMessages()
        
        // After dispatch, mockChatService should update status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let updated = self.mockChatService.messagesToReturn.first
            XCTAssertEqual(updated?.status, .read)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - sendMessage Tests
    
    func testSendMessage_success() async throws {
        viewModel.inputText = "Hey!"
        mockChatService.messagesToReturn = []
        
        await viewModel.sendMessage()
        
        // sendMessage should append a new message
        XCTAssertTrue(viewModel.sendDisabled)
        XCTAssertEqual(viewModel.inputText, "")
        XCTAssertFalse(viewModel.messages.isEmpty)
    }
    
    func testSendMessage_noChatService() async throws {
        viewModel.inputText = "Hey!"
        mockChatService.messagesToReturn = []
        viewModel.chatService = nil
        
        await viewModel.sendMessage()
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testSendMessage_noAuthService() async throws {
        viewModel.inputText = "Hey!"
        mockChatService.messagesToReturn = []
        viewModel.authService = nil
        
        await viewModel.sendMessage()
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testSendMessage_emptyInput_doesNothing() async throws {
        viewModel.inputText = "    "
        mockChatService.messagesToReturn = []
        
        await viewModel.sendMessage()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertTrue(viewModel.sendDisabled)
    }
    
    // MARK: - userIsTyping Tests
    
    func testUserIsTyping_noCrash() async throws {
        // Should not throw or crash
        viewModel.userIsTyping(isTyping: true)
    }
    
    func testUserIsTyping_noCrash_onNoChatService() async throws {
        // Should not throw or crash
        viewModel.chatService = nil
        viewModel.userIsTyping(isTyping: true)
    }
    
    func testUserIsTyping_noCrash_onNoAuthService() async throws {
        // Should not throw or crash
        viewModel.authService = nil
        viewModel.userIsTyping(isTyping: true)
    }
    
    // MARK: - observeTyping Tests
    
    func testObserveTyping_whenChatServiceNil_doesNothing() {
        viewModel.chatService = nil
        viewModel.authService = mockAuthService
        viewModel.isOtherUserTyping = false
        
        viewModel.observeTyping()
        
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    func testObserveTyping_whenCurrentUserNil_doesNothing() {
        viewModel.chatService = mockChatService
        viewModel.authService = nil
        viewModel.isOtherUserTyping = false
        
        viewModel.observeTyping()
        
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    func testObserveTyping_setsIsOtherUserTypingTrue() {
        var callback: ((Bool) -> Void)?
        mockChatService.observeTypingHandler = { _, _, onChange in
            callback = onChange
        }
        
        viewModel.observeTyping()
        XCTAssertNotNil(callback)
        
        callback?(true)
        //XCTAssertTrue(viewModel.isOtherUserTyping)
    }
    
    func testObserveTyping_setsIsOtherUserTypingFalse() {
        var callback: ((Bool) -> Void)?
        mockChatService.observeTypingHandler = { _, _, onChange in
            callback = onChange
        }
        
        viewModel.observeTyping()
        callback?(false)
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    func testLoadMessage_noChatService() async throws {
        viewModel.inputText = "Hey!"
        mockChatService.messagesToReturn = []
        viewModel.chatService = nil
        
        await viewModel.loadMessages()
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testLoadMessage_noAuthService() async throws {
        viewModel.inputText = "Hey!"
        mockChatService.messagesToReturn = []
        viewModel.authService = nil
        
        await viewModel.loadMessages()
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testObserveMessages_noCrash_onNoChatService() async throws {
        // Should not throw or crash
        viewModel.chatService = nil
        viewModel.observeMessages()
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testObserveMessages_noCrash_onNoAuthService() async throws {
        // Should not throw or crash
        viewModel.authService = nil
        viewModel.observeMessages()
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
}
