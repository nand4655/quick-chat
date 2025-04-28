//
//
// ChatScreen.swift
// QuickChat
//
// Created by Nand on 26/04/25
//


import SwiftUI

struct ChatScreen: View {
    @Environment(DIContainer.self) private var diContainer: DIContainer
    @State var viewModel: ChatScreenViewModel
    
    init(otherUser: UserDetailsModel) {
        self._viewModel = State(wrappedValue: ChatScreenViewModel(otherUser: otherUser))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.senderId == viewModel.currentUser?.uid {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(message.text)
                                            .padding(10)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(10)
                                        HStack(spacing: 4) {
                                            Text(message.timestamp, style: .time)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            statusIcon(for: message.status)
                                        }
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(message.text)
                                            .padding(10)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                        Text(message.timestamp, style: .time)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                            }
                            .id(message.id ?? UUID().uuidString)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(last.id ?? UUID().uuidString, anchor: .bottom)
                        }
                    }
                }
            }
            
            if viewModel.isOtherUserTyping {
                HStack {
                    Text("\(viewModel.otherUser.displayName ?? "User") is typing...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            HStack {
                TextField("Type a message...", text: $viewModel.inputText, onEditingChanged: { isTyping in
                    viewModel.userIsTyping(isTyping: isTyping)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    Task { await viewModel.sendMessage() }
                }) {
                    Image(systemName: viewModel.sendDisabled ? "paperplane.circle" : "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .tint(viewModel.sendDisabled ? .gray : .blue)
                }
                .padding(.leading, 8)
                .disabled(viewModel.sendDisabled)
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle(viewModel.otherUser.displayName ?? viewModel.otherUser.email ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.authService = diContainer.authService
            viewModel.chatService = diContainer.chatService
            
            viewModel.onViewAppear()
        }
    }
    
    
    func statusIcon(for status: MessageStatus) -> some View {
        switch status {
            case .sent:
                // Single gray tick
                return AnyView(
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.gray)
                )
            case .delivered:
                // Double gray ticks
                return AnyView(
                    HStack(spacing: 0) {
                        Group {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.gray)
                                .offset(x: -5)
                        }
                    }
                )
            case .read:
                // Double green ticks
                return AnyView(HStack(spacing: 0) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.green)
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.green)
                        .offset(x: -5)
                })
        }
    }
}
