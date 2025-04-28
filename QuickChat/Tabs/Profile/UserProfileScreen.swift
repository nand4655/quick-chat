//
//
// UserProfileScreen.swift
// QuickChat
//
// Created by Nand on 26/04/25
//


import Foundation
import SwiftUI

struct UserProfileScreen: View {
    @Environment(DIContainer.self) private var diContainer: DIContainer
    @Environment(AppRouter.self) private var rootRouter: AppRouter

    @State private var showShareSheet = false
    @State private var showLogOutAlert = false
    
    var shareContent: String {
        return """
        Check out QuickChat - the amazing chat app!
        Download now : www.google.com
        """
    }

    let appVersion = "1.1.0"
    
    var body: some View {
        List {
            VStack(spacing: 8) {
                if let photoURL = diContainer.authService.currentUser?.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(.circle)
                            .padding(.top, 16)

                    } placeholder: {
                        emptyImageView
                    }
                } else {
                    emptyImageView
                }
      
                
                Text(diContainer.authService.currentUser?.displayName ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 12)
                
                Text(diContainer.authService.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 16)
                
            }
            .frame(maxWidth: .infinity)
            
            Section {
                SettingsRow(icon: "star.fill", iconColor: .blue, title: "Rate Us")

                SettingsRow(icon: "arrowshape.turn.up.right.fill", iconColor: .blue, title: "Share with a friend") {
                    showShareSheet.toggle()
                }
                
                SettingsRow(icon: "phone.fill", iconColor: .blue, title: "Contact Us")
            }
            
            Section {
                SettingsRow(icon: "trash.fill", iconColor: .red, title: "Delete account")
                
                SettingsRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .blue, title: "Log Out") {
                    showLogOutAlert.toggle()
                }
            }
            
            Section {
                HStack {
                    SettingsRow(icon: "doc.fill", iconColor: .blue, title: "Version")
                    Text(appVersion)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareContent])
        }
        .alert(isPresented: $showLogOutAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Do you really want to log out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    Task {
                        let result = await diContainer.authService.signOut()
                        if case .success  = result {
                            rootRouter.popToRoot()
                        }                        
                    }
                },
                secondaryButton: .cancel()
            )
        }
        
    }
    
    @ViewBuilder
    var emptyImageView: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundColor(.gray)
            .padding(.top, 16)
            .clipShape(.circle)
        
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var onClick: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onClick?()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .foregroundColor(.primary)
            }
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {
        // Update any settings here if needed
    }
}

#Preview("UserProfileScreen") {
    UserProfileScreen()
}
