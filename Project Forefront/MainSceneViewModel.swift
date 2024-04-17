import Foundation
import SwiftUI
import SceneKit


/**
 Class representing a MainSceneViewModel.
 
 MainSceneViewModel inherits from ObservableObject.
 */
class MainSceneViewModel: ObservableObject {
    @Published var scene = MainScene()
    @Published var playerBoostCount = 5
    @Published var playerMovementCount = 10
    
    
    /**
     Constructor for MainSceneViewModel.
     */
    init(){
        scene.setupViewModel(viewModel: self)
    }

    
    /**
     Function to handle updating the camera position.
     
     Defunct.
     */
    func updateCameraPosition(cameraXOffset: Float, cameraYOffset: Float) {
        // CALL FUNCTIONS IN SCENE FROM HERE LIKE THIS
        scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraYOffset)
    }
    
    
    /**
     Function to handle leftward movement.
     
     Called by:
     
     ContentView.body
     */
    func moveTankLeft(){
        scene.moveActivePlayerTankLeft()
        playerMovementCount = scene.maxMovementPlayerSteps
    }
    
    
    /**
     Function to handle rightward movement.
     
     Called by:
     
     ContentView.body
     */
    func moveTankRight(){
        scene.moveActivePlayerTankRight()
        playerMovementCount = scene.maxMovementPlayerSteps
    }
    
    
    /**
     Function to handle damage in the scene.
     
     Called by:
     
     ContentView.body
     */
    func stopMoving(){
        scene.stopMovingTank()
    }
    
    
    /**
     Function to handle aim rotation counterclockwise.
     
     Defunct.
     */
    func handleAimRotateLeft(){
        
    }
    
    
    /**
     Function to handle aim rotation clockwise.
     
     Defunct.
     */
    func handleAimRotateRight(){
        
    }
    
    
    /**
     Function to handle firing a weapon.
     
     Defunct.
     */
    func handleFire(){
        
    }
    
    
    /**
     Function to handle the projectile power.
     
     Defunct.
     */
    func handleAdjustPower(powerLevel: Double) {
        
    }
    
    
    /**
     Function to handle damage in the scene.
     
     Defunct.
     */
    func takeDamage() {
//        scene.takeDamage()
    }
    

    /**
     Function to handle the tank jump.
     
     Defunct.
     */
    @MainActor func rocketBoost(){
        scene.moveActivePlayerTankVertically()
        playerBoostCount = scene.playerBoostCount

    }
    
    
    /**
     Function to reset the variables when the turns switch.
     
     Called by:
     
     MainScene.toggleTurns()
     */
    func resetUIVariablesOnTurnChange(){
        playerBoostCount = scene.playerBoostCount
        playerMovementCount = scene.maxMovementPlayerSteps

    }
    
    
    /**
     Function to end a turn in MainScene.swift.
     */
    @MainActor func endTurn() {
        scene.turnEndedPressed()
    }
    
    
    /**
     Function to handle the resetting of the scene.
     
     Only call from ContentView.swift
     */
    func resetScene() {
        DispatchQueue.main.async {
            self.scene.cleanup()
            self.scene = MainScene()
        }
    }
}
