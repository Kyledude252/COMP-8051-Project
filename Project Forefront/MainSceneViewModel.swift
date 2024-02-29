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
        // CALL FUNCTIONS IN SCENE FROM HERE LIKE THIS
        scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraYOffset)
    }
    
    func moveTankLeft(){
        scene.moveActivePlayerTankLeft()
    }
    func moveTankRight(){
        scene.moveActivePlayerTankRight()
    }
    func stopMoving(){
        scene.stopMovingTank()
    }
    func handleAimRotateLeft(){
        
    }
    func handleAimRotateRight(){
        
    }    
    func handleFire(){
        
    }
    func handleAdjustPower(powerLevel: Double) {
        
    }
}
