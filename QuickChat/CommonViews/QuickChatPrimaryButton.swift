//
//
// QuickChatPrimaryButton.swift
// QuickChat
//
// Created by Nand on 28/04/25
//
        

import Foundation
import SwiftUI

struct QuickChatPrimaryButton: View {
    let title: String
    let activeColor: Color
    let inActiveColor: Color
    @Binding var isActive: Bool
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(isActive ? .white : inActiveColor)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(.black)
        .clipShape(.rect(cornerRadius: 9, style: .continuous))
        .disabled(!isActive)
    }
}
