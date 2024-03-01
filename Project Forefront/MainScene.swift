//
//  MainScene.swift
//  Project Forefront
//
//  Created by user on 2/13/24.
//

import Foundation
import SceneKit


class MainScene: SCNScene {
    var cameraNode = SCNNode()
    var cameraXOffset: Float = 0
    var cameraYOffset: Float = 0
    var cameraZOffset: Float = 35
    var player1Tank: Tank!
    var player2Tank: Tank!
    var activePlayer: Int = 1
    var tankMovingLeft = false
    var tankMovingRight = false
    var movementPlayerSteps = 0
    var maxMovementPlayerSteps = 25 //TODO /TURNS
    
    var groundPosition: CGFloat = -8
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Initializer
    override init() {
        super.init()
        
        background.contents = UIColor.black
        
        setupCamera()
        setupBackgroundLayers()
        setupForegroundLevel()
        
        player1Tank = Tank(position: SCNVector3(-20, groundPosition, 0), color: .red)
        player2Tank = Tank(position: SCNVector3(20, groundPosition, 0), color: .blue)
        
        rootNode.addChildNode(player1Tank)
        rootNode.addChildNode(player2Tank)
        
        
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    // GRAPHICS // //////
    @MainActor
    func firstUpdate() {
        tankMovement() // Call reanimate on the first graphics update frame
    }
    
    // CAMERA // ////////////
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
        //        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0)
        rootNode.addChildNode(cameraNode)
    }
    
    func updateCameraPosition(cameraXOffset: Float, cameraYOffset: Float) {
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
    }
    
    
    // BACKGROUND / ENVIORNMENT // ////////////
    func setupBackgroundLayers() {
        // For parallax perspective -
        // TODO: Joe (PROBABLY)
        
        //Example starter code
        let backgroundNode1 = createBackgroundNode(color: .blue, position: SCNVector3(0, 0, -10), size: CGSize(width: 100, height: 20))
        let backgroundNode2 = createBackgroundNode(color: .green, position: SCNVector3(0, 0, -20), size: CGSize(width: 120, height: 50))
        
        // Add the background nodes to the scene
        rootNode.addChildNode(backgroundNode1)
        rootNode.addChildNode(backgroundNode2)
    }
    
    func createBackgroundNode(color: UIColor, position: SCNVector3, size: CGSize) -> SCNNode {
        let geometry = SCNPlane(width: size.width, height: size.height)
        geometry.firstMaterial?.diffuse.contents = color // temp, just to show
        // TODO: JOE
        //        geometry.firstMaterial?.diffuse.contents = UIImage(named: imageName)  //for real use with images
        
        
        let backgroundNode = SCNNode(geometry: geometry)
        backgroundNode.position = position
        
        return backgroundNode
    }
    
    
    func setupForegroundLevel() {
        let levelWidth: CGFloat = 100
        let levelHeight: CGFloat = 20
        
        let levelNode = Level(levelWidth: levelWidth, levelHeight: levelHeight)
        
        
        levelNode.position = SCNVector3(-(levelWidth/2), groundPosition - (levelNode.squareSize / 2), -levelNode.squareSize)
        
        levelNode.eulerAngles = SCNVector3(x: .pi/2 , y: 0, z: 0)
        
        
        rootNode.addChildNode(levelNode)
    }
    
    // PLAYER CONTROL & SWITCHING // ///////////
    
    func switchActivePlayer() {
        activePlayer = (activePlayer == 1) ? 2 : 1
    }
    
    
    func moveActivePlayerTankLeft() {
        tankMovingLeft = true
        tankMovingRight = false
        movementPlayerSteps = 5
        
    }
    
    func moveActivePlayerTankRight() {
        tankMovingRight = true
        tankMovingLeft = false
        movementPlayerSteps = 5
    }
    
    func stopMovingTank() {
        tankMovingLeft = false
        tankMovingRight = false
        
    }
    @MainActor
    func tankMovement (){
        if movementPlayerSteps > 0 {
            
            if activePlayer == 1 { // Player 1
                if tankMovingLeft {
                    player1Tank.moveLeft()
                } else if tankMovingRight {
                    player1Tank.moveRight()
                }
            } else if activePlayer == 2 { // Player 2
                if tankMovingLeft {
                    player2Tank.moveLeft()
                } else if tankMovingRight {
                    player2Tank.moveRight()
                }
            }
            
            movementPlayerSteps -= 1
            if movementPlayerSteps == 0 {
                stopMovingTank()
            } else {

            }
        }
        
        Task { try! await Task.sleep(nanoseconds: 10000)
            tankMovement()
        }
    }
    
    
    
    
}
