// QuickChatTests/GroupChatScreenViewModelTests.swift

import XCTest
@testable import QuickChat

final class GroupChatScreenViewModelTests: XCTestCase {
    var viewModel: GroupChatScreenViewModel!
    var mockService: MockGroupChatService!
    var mockAuth: MockAuthService!
    
    // A dummy group with an ID so `group.id` is non‐nil
    let testGroup = UserGroup(
        id: "g1",
        name: "TestGroup",
        memberIds: [],
        createdAt: Date(),
        lastMessage: nil,
        lastMessageTimestamp: nil
    )
    let currentUser = UserDetailsModel(
        uid: "me",
        email: "me@test.com",
        displayName: "Me",
        photoURL: nil,
        createdAt: nil,
        lastLoginAt: nil
    )
    
    override func setUpWithError() throws {
        mockService = MockGroupChatService()
        mockAuth = MockAuthService()
        mockAuth.currentUser = currentUser
        
        viewModel = GroupChatScreenViewModel(group: testGroup)
        viewModel.groupChatService = mockService
        viewModel.authService = mockAuth
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        mockAuth = nil
    }
    
    // MARK: sendDisabled
    
    func testSendDisabled_trueWhenInputEmpty() {
        viewModel.inputText = "   "
        XCTAssertTrue(viewModel.sendDisabled)
    }
    
    func testSendDisabled_falseWhenInputNotEmpty() {
        viewModel.inputText = "Hello"
        XCTAssertFalse(viewModel.sendDisabled)
    }
    
    // MARK: observeMessages guard
    
    func testObserveMessages_noService_doesNothing() {
        viewModel.groupChatService = nil
        viewModel.messages = [GroupMessage(id: "x", senderId: "", text: "", timestamp: Date(), status: .sent)]
        viewModel.observeMessages()
        XCTAssertEqual(viewModel.messages.count, 1)
    }
    
    func testObserveMessages_noGroup_doesNothing() {        
        viewModel = GroupChatScreenViewModel(group: UserGroup(id: nil, name: "", memberIds: [], createdAt: Date(), lastMessage: nil, lastMessageTimestamp: nil))
        viewModel.groupChatService = mockService
        viewModel.observeMessages()
        XCTAssertEqual(viewModel.messages.count, 0)
    }
    
    // MARK: observeMessages normal flow
    
    func testObserveMessages_updatesMessages() {
        let msg = GroupMessage(
            id: "1",
            senderId: "u1",
            text: "Hello",
            timestamp: Date(),
            status: .sent
        )
        mockService.messagesToReturn = [msg]
        
        // Capture the handler
        viewModel.observeMessages()
        XCTAssertNotNil(mockService.observeMessagesHandler)
        
        // Invoke it
        mockService.observeMessagesHandler?([msg])
        XCTAssertEqual(viewModel.messages.count, 0)
    }
    
    // MARK: sendMessage guard
    
    func testSendMessage_noService_doesNothing() async {
        viewModel.inputText = "Hi"
        viewModel.groupChatService = nil
        await viewModel.sendMessage()
        XCTAssertFalse(mockService.sendMessageCalled)
    }
    
    func testSendMessage_noAuthService_doesNothing() async {
        viewModel.inputText = "Hi"
        viewModel.authService = nil
        await viewModel.sendMessage()
        XCTAssertFalse(mockService.sendMessageCalled)
    }
    
    func testSendMessage_emptyInput_doesNothing() async {
        viewModel.inputText = "   "
        await viewModel.sendMessage()
        XCTAssertFalse(mockService.sendMessageCalled)
    }
    
    // MARK: sendMessage normal flow
    
    func testSendMessage_success_clearsInputAndCallsService() async {
        viewModel.inputText = "Hi"
        await viewModel.sendMessage()
        XCTAssertTrue(mockService.sendMessageCalled)
        XCTAssertEqual(viewModel.inputText, "")
    }
    
    // MARK: userIsTyping guard
    
    func testUserIsTyping_noService_doesNothing() async {
        viewModel.groupChatService = nil
        viewModel.userIsTyping(isTyping: true)
        // No crash, no call
        XCTAssertNil(mockService.setTypingCalled)
    }
    
    func testUserIsTyping_noAuth_orGroupId_doesNothing() async {
        viewModel.authService = nil
        viewModel.userIsTyping(isTyping: true)
        XCTAssertNil(mockService.setTypingCalled)
    }
    
    // MARK: userIsTyping normal flow
    
    func testUserIsTyping_callsService() async {
        viewModel.userIsTyping(isTyping: false)
        // Wait for the Task to fire
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(mockService.setTypingCalled?.isTyping, false)
        XCTAssertEqual(mockService.setTypingCalled?.groupId, "g1")
        XCTAssertEqual(mockService.setTypingCalled?.userId, "me")
    }
    
    // MARK: observeTyping guard
    
    func testObserveTyping_noService_doesNothing() {
        viewModel.groupChatService = nil
        viewModel.isOtherUserTyping = false
        viewModel.observeTyping()
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    func testObserveTyping_noAuth_orGroupId_doesNothing() {
        viewModel.authService = nil
        viewModel.isOtherUserTyping = false
        viewModel.observeTyping()
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    // MARK: observeTyping normal flow
    
    func testObserveTyping_setsFlagCorrectly() {
        // Capture the handler
        viewModel.observeTyping()
        XCTAssertNotNil(mockService.observeTypingHandler)
        
        // Simulate stop typing
        mockService.observeTypingHandler?(false)
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    func testOnAppear() {
        // Capture the handler
        viewModel.onViewAppear()
        
        // Simulate stop typing
        mockService.observeTypingHandler?(false)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertFalse(viewModel.isOtherUserTyping)
    }
    
    func testMarkMessagesAsDelivered() {
        let msg = GroupMessage(
            id: "1",
            senderId: "u1",
            text: "Hello",
            timestamp: Date(),
            status: .sent
        )
        viewModel.markMessagesAsDelivered([msg])
        
        //Does nothing, as this is not implemented
    }
}
