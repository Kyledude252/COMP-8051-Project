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
    
    var cameraYOffset: Float = -10 // set to make stage line straight, adjusting this later will probably be important
    
    var cameraZOffset: Float = 25 // half of level width
    
    var player1Tank: Tank!
    var player2Tank: Tank!
    
    // Level // //////
    var groundPosition: CGFloat = -8
    var levelSquaredArea: CGFloat = 50
    var levelheight: CGFloat = 2
    
    //grab view
    weak var scnView: SCNView?
    // holds line for redrawing it
    var lineNode: SCNNode?
    // throttle drawing line to prevent lag fest if needed, currently not used
    var isThrottling = false
    let triggerPeriod = 0.1
    
    var projectile: SCNNode?
    
    
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
        
        
        Task(priority: .userInitiated) {
            //            await firstUpdate()
        }
        
        player1Tank = Tank(position: SCNVector3(-20, groundPosition, 0), color: .red)
        player2Tank = Tank(position: SCNVector3(20, groundPosition, 0), color: .white)
        rootNode.addChildNode(player1Tank)
        rootNode.addChildNode(player2Tank)
        
        //firing---
        //drawHorizontalLine()
        //------
    }
    
    // CAMERA // ////////////
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
        //cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        
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
    func toggleFire(isFireMode: Bool){
        print(player1Tank.position)
        if !isFireMode {
            lineNode?.removeFromParentNode()
            lineNode = nil
        }
        //tank firing object funciton
    }
    
    //Takes in a start and end point of 3d Vectors and draws a custom line based on vertices between points
    func createTrajectoryLine(from startPoint: SCNVector3, to endPoint: SCNVector3) {
        //array containing start and end point of the line
        let vertices: [SCNVector3] = [startPoint, endPoint]
        //A container for vertex data forming part of the definition for a three-dimensional object, or geometry. <- check documentation
        let vertexSource = SCNGeometrySource(vertices: vertices)
        //defines 0 as start point and 1 as end point of hte line
        let indices: [Int32] = [0, 1]
        //conversion required
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        //Set primative type to .line, connects points vertexSource with just one line line
        //Ironically this means the line width requires other solutions to increase the thickness
        let element = SCNGeometryElement(data: indexData, primitiveType: .line, primitiveCount: 1, bytesPerIndex: MemoryLayout<Int32>.size)
        
        //Actually creating a line
        let lineGeometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let lineNode = SCNNode(geometry: lineGeometry)
        
        //this color can be changed later based on player color based on active player
        lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

        // Remove the old line node
        self.lineNode?.removeFromParentNode()
        
        // Set the new line node
        self.lineNode = lineNode
        self.rootNode.addChildNode(lineNode)
    }
    //startPoint: Tank that is firing, endPoint: point of mouse 
    //Later add collision detection
    func createProjectile(from startPoint: SCNVector3) -> SCNNode {
        //basic setup
        let testProjectile = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let testMaterial = SCNMaterial()
        testProjectile.materials = [testMaterial]
        //add collision here later
        //Change this color later to adjust for shot fired
        testMaterial.diffuse.contents = UIColor.red
        let projectileNode = SCNNode(geometry: testProjectile)
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        projectileNode.physicsBody = physicsBody
        
        return projectileNode
    }
    
    func launchProjectile(from startPoint: SCNVector3, to endPoint: SCNVector3) {
        projectile = createProjectile(from: startPoint)
        projectile?.position = startPoint
        //remove later
        self.rootNode.addChildNode(projectile!)
        //Get direction of vector
        let direction = SCNVector3(endPoint.x - startPoint.x, endPoint.y - startPoint.y, 0)//endPoint.z - startPoint.z)
        //Add scalar, edit as needed, maybe add to paramter later for different shots
        let forceVector = SCNVector3(direction.x*3, direction.y*3, direction.z)
        //Apply force to node
        projectile?.physicsBody?.applyForce(forceVector, asImpulse: true)
    }
}
