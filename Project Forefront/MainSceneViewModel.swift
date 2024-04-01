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
    @Published var playerBoostCount = 5
    @Published var playerMovementCount = 10
    
    
    init(){
        scene.setupViewModel(viewModel: self)
    }

    func updateCameraPosition(cameraXOffset: Float, cameraYOffset: Float) {
        // CALL FUNCTIONS IN SCENE FROM HERE LIKE THIS
        scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraYOffset)
    }
    
    
    
    func moveTankLeft(){
        scene.moveActivePlayerTankLeft()
        playerMovementCount = scene.maxMovementPlayerSteps
    }
    func moveTankRight(){
        scene.moveActivePlayerTankRight()
        playerMovementCount = scene.maxMovementPlayerSteps
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
    func takeDamage() {
//        scene.takeDamage()
    }
    

    @MainActor func rocketBoost(){
        scene.moveActivePlayerTankVertically()
        playerBoostCount = scene.playerBoostCount

    }
    
    func resetUIVariablesOnTurnChange(){
        playerBoostCount = scene.playerBoostCount
        playerMovementCount = scene.maxMovementPlayerSteps

    }
    //Use this to call toggle turns, basically ends turn immediatley in gameplay
    @MainActor func endTurn() {
        scene.turnEndedPressed()
    }
    
    // To be called from contentView only
    func resetScene() {
        DispatchQueue.main.async {
            self.scene.cleanup()
            self.scene = MainScene()
        }
    }
    
}
