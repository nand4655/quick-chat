//
//
// SplashScreen.swift
// QuickChat
//
// Created by Nand on 24/04/25
//


import SwiftUI

struct SplashScreen: View {
    @State private var isHexagonVisible = true
    @State private var hexagonOffset: CGFloat = 0
    @State private var isTextVisible = false
    
    let moveDelay: Double = 2.0
    let moveDuration: Double = 1
    let textAnimationDelay: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background with glass morphism gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue,
                    Color.white.opacity(0.8),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass effect overlay
            Color.blue
            //.blur(radius: 50)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {                
                Spacer()
                
                ZStack {
                    if isHexagonVisible {
                        Image(.polygonWhite)
                            .offset(y: hexagonOffset)
                            .rotationEffect(.degrees(rotationAngle))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation(.easeInOut(duration: moveDuration)) {
                                        hexagonOffset = 0
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    startRotationAnimation()
                                }
                            }
                    }
                    
                    Text(String(localized: "q"))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if isTextVisible {
                    HStack(spacing: 0) {
                        Text(String(localized: "Introducing "))
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                        Text(String(localized: "QuickChat"))
                            .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + textAnimationDelay) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isTextVisible = true
                }
            }
        }
    }
    
    @State private var rotationAngle: Double = 0
    @State private var shouldAnimate: Bool = true
    func startRotationAnimation() {
        guard shouldAnimate else { return }
        
        withAnimation(Animation.linear(duration: 0.5)) { // Rotate in 0.5 seconds
            rotationAngle += 90
        }
        
        // Wait for 2 seconds before repeating
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startRotationAnimation()
        }
    }
}

#Preview {
    SplashScreen()
}
