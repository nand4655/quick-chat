//
//
// LoginScreen.swift
// QuickChat
//
// Created by Nand on 24/04/25
//
        

import SwiftUI
import FirebaseAuth
import _AuthenticationServices_SwiftUI

struct LoginScreen: View {
    @Environment(DIContainer.self) private var diContainer: DIContainer
    @State private var viewModel: LoginViewModel = .init()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("QuickChat")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 110, height: 56)
                        .background(.blue)
                    
                    Spacer()
                }
               
                
                Text("Now chatting with friends made even more fun! \nWant to try it out? \nLogin now")
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .monospaced()
            }
            .padding()
            .padding(.top, 12)
            
            
            Spacer()
            
            Text("Login with Apple coming soon...")
                .font(.system(size: 12, weight: .regular, design: .default))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.gray.opacity(0.6))
                .multilineTextAlignment(.center)
            
            // Apple Sign In button
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    Task {
                        await viewModel.signInWithApple()
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(12)
            .padding(.horizontal, 30)
            
            // Google Sign Up Button
            Button(action: {
                Task {
                    await viewModel.signInWithGoogle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(.googleIcon)
                        .resizable()
                        .frame(width: 22, height: 22)
                        .scaledToFit()
                    Text("Sign up with Google")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 93/255, green: 177/255, blue: 255/255))
                .cornerRadius(12)
                .padding(.horizontal, 30)
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            viewModel.authService = diContainer.authService
            viewModel.userService = diContainer.userService
        }
    }
}

#Preview {
    LoginScreen()
        .withPreviewEnvironments()
}
