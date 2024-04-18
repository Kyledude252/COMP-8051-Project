import SwiftUI
import AVFoundation


/**
 A struct defining the structure of the app.
 
 Project_ForefrontApp inherits from App.
 */
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
    
    
    /**
     Function to handle the configuration of an audio session.
     
     Called by:
     
     Project_ForefrontApp.init()
     */
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up the audio session: \(error)")
        }
    }
}
