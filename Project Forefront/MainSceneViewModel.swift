//
//  MainSceneViewModel.swift
//  Project Forefront
//
//  Created by user on 2/13/24.
//
import Foundation
import SwiftUI
import SceneKit

class MainSceneViewModel: ObservableObject {
    @Published var scene = MainScene()
    
    func updateCameraPosition(cameraXOffset: Float, cameraYOffset: Float) {
        scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraYOffset)
    }
}
