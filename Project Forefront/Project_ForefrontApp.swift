//
//  Project_ForefrontApp.swift
//  Project Forefront
//
//  Created by Kyle Alexander on 2024-01-31.
//

import SwiftUI
import AVFoundation

@main
struct Project_ForefrontApp: App {
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up the audio session: \(error)")
        }
    }
}
