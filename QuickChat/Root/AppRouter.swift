//
//
// AppRouter.swift
// wapi-ai
//
// Created by Nand on 10/04/25
//
        

import Foundation
import SwiftUI

enum AppRoute: Hashable {
    case loginScreen
    case mainTabView
    case chatScreen(otherUser: UserDetailsModel)
    case groupChatScreen(group: UserGroup)
}

@Observable
final class AppRouter {
    var path = NavigationPath()
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func popScreen() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
