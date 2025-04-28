//
//
// GroupChatScreen.swift
// QuickChat
//
// Created by Nand on 28/04/25
//
        

import Foundation
import SwiftUI

struct GroupChatScreen: View {
    @State var viewModel: GroupChatScreenViewModel
    @Environment(DIContainer.self) private var diContainer: DIContainer
    
    init(group: UserGroup) {
        self._viewModel = State(wrappedValue: GroupChatScreenViewModel(group: group))
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
                                            // Optionally, add statusIcon for group messages
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
                    Text("Someone is typing...")
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
            .padding()
        }
        .padding()
        .onAppear {
            viewModel.authService = diContainer.authService
            viewModel.groupChatService = diContainer.groupChatService
            
            viewModel.onViewAppear()
        }
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
