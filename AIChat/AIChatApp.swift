//
//  AIChatApp.swift
//  AIChat
//
//  Created by Matt Davis on 9/25/24.
//

import SwiftUI

@main
struct AIChatApp: App {
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ChatView()
                .environmentObject(chatViewModel)
        }
    }
}
