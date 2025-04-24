//
//
// Item.swift
// QuickChat
//
// Created by Nand on 24/04/25
//
        

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
