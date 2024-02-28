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
    var cameraYOffset: Float = 1
    var cameraZOffset: Float = 25 // half of level width
    
    var player1Tank: Tank!
    var player2Tank: Tank!
    
    // Level // //////
    var groundPosition: CGFloat = -8
    var levelSquaredArea: CGFloat = 50
    var levelheight: CGFloat = 2
    
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
        
        //firing---
        
        //------
        
        Task(priority: .userInitiated) {
            //            await firstUpdate()
        }
        
        player1Tank = Tank(position: SCNVector3(-20, groundPosition, 0), color: .red)
        player2Tank = Tank(position: SCNVector3(20, groundPosition, 0), color: .white)
        rootNode.addChildNode(player1Tank)
        rootNode.addChildNode(player2Tank)
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
        let backgroundNode1 = createBackgroundNode(color: .blue, position: SCNVector3(0, 0, -50), size: CGSize(width: 40, height: 20))
        let backgroundNode2 = createBackgroundNode(color: .green, position: SCNVector3(0, 0, -75), size: CGSize(width: 80, height: 50))
        
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
               
        let groundGeometry = SCNBox(width: levelSquaredArea, height: levelheight, length:  levelSquaredArea, chamferRadius: 0)
        groundGeometry.firstMaterial?.diffuse.contents = UIColor.brown
        
        let groundNode = SCNNode(geometry: groundGeometry)
        groundNode.position = SCNVector3(0, groundPosition-(levelheight/2), -levelSquaredArea/2)
        
        
        rootNode.addChildNode(groundNode)
    }
    
    //-------------------------------------------------------------------
    //Firing Code
    //-------------------------------------------------------------------
    //function that's sent to coordinator
    @objc
    func toggleFire(){
        print("ran")
    }
    
}
