//
//  StatsSceneViewModel.swift
//  Project Forefront
//
//  Created by Nicky Cheng on 2024-03-31.
//

import Foundation
import SwiftUI
import SceneKit

class StatsSceneViewModel : ObservableObject {
    @Published var scene = StatsScene()
    
    func updateStats() {
        scene.updateStats()
    }
}
