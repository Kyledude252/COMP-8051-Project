//
//  StatsScene.swift
//  Project Forefront
//
//  Created by Nicky Cheng on 2024-03-31.
//

import Foundation
import SceneKit

class StatsScene : SCNScene {
    var cameraNode = SCNNode()
    var cameraXOffset: Float = 0
    var cameraYOffset: Float = 0
    var cameraZOffset: Float = 30
    var player1Wins = UserDefaults.standard.integer(forKey: "Player1Wins")
    var player2Wins = UserDefaults.standard.integer(forKey: "Player2Wins")
    let player1Stats = SCNNode()
    let player2Stats = SCNNode()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not yet been implemented")
    }
    
    override init() {
        super.init()
        
        setupCamera()
        setupStats()
    }
    
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
        
        rootNode.addChildNode(cameraNode)
    }
    
    func setupStats() {
        let player1Text = SCNText(string: String(format: "Player 1 Wins: %d", player1Wins), extrusionDepth: 0.0)
        let player2Text = SCNText(string: String(format: "Player 2 Wins: %d", player2Wins), extrusionDepth: 0.0)
        player1Stats.geometry = player1Text
        player2Stats.geometry = player2Text
        player1Stats.scale = SCNVector3(0.5, 0.5, 0.5)
        player2Stats.scale = SCNVector3(0.5, 0.5, 0.5)
        player1Stats.position = SCNVector3(-20, 0, 0)
        player2Stats.position = SCNVector3(-20, -15, 0)
        player1Text.firstMaterial?.diffuse.contents = UIColor.black
        player2Text.firstMaterial?.diffuse.contents = UIColor.black
        
        rootNode.addChildNode(player1Stats)
        rootNode.addChildNode(player2Stats)
    }
    
    func updateStats() {
        player1Wins = UserDefaults.standard.integer(forKey: "Player1Wins")
        player2Wins = UserDefaults.standard.integer(forKey: "Player2Wins")
        if let player1Text = player1Stats.geometry as? SCNText {
            player1Text.string = String(format: "Player 1 Wins: %d", player1Wins)
        }
        if let player2Text = player2Stats.geometry as? SCNText {
            player2Text.string = String(format: "Player 2 Wins: %d", player2Wins)
        }
    }
}
