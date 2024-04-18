import Foundation
import SwiftUI
import SceneKit


/**
 Class representing a StatsSceneViewModel.
 
 StatsSceneViewModel inherits from ObservableObject.
 */
class StatsSceneViewModel : ObservableObject {
    @Published var scene = StatsScene()
    
    
    /**
     Function for handling stat updates.
     
     Called by:
     
     ContentView.body
     */
    func updateStats() {
        scene.updateStats()
    }
}
