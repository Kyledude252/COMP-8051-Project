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
    var cameraYOffset: Float = -10
    
    var cameraZOffset: Float = 25

    var player1Tank: Tank!
    var player2Tank: Tank!
    var activePlayer: Int = 1
    var tankMovingLeft = false
    var tankMovingRight = false
    var movementPlayerSteps = 0
    var maxMovementPlayerSteps = 25 //TODO /TURNS
    let levelWidth: CGFloat = 100
    let levelHeight: CGFloat = 30
    
    var toggleGameStarted: (() -> Void)? // callback for reset

    var groundPosition: CGFloat = 5

    var levelNode = Level(levelWidth: 1, levelHeight: 1)
    
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
        

        player1Tank = Tank(position: SCNVector3(-20, groundPosition-10, 0), color: .red)
        player2Tank = Tank(position: SCNVector3(20, groundPosition-10, 0), color: .green)
        
        rootNode.addChildNode(player1Tank)
        rootNode.addChildNode(player2Tank)
        
        
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    func cleanup(){
            rootNode.childNodes.forEach { $0.removeFromParentNode() }
            NotificationCenter.default.removeObserver(self)
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

        levelNode.delete()
        levelNode = Level(levelWidth: levelWidth, levelHeight: levelHeight)
        
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
            
            if activePlayer == 1  && player1Tank.getHealth() > 0 { // Player 1
                if tankMovingLeft {
                    player1Tank.moveLeft()
                } else if tankMovingRight {
                    player1Tank.moveRight()
                }
            } else if activePlayer == 2 && player2Tank.getHealth() > 0 { // Player 2
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
    
    // Temp function to debug damage
    func takeDamage() {
        if activePlayer == 1 {
            player1Tank.decreaseHealth(damage: 10)
            deadCondition()
        } else if activePlayer == 2 {
            player2Tank.decreaseHealth(damage: 10)
            deadCondition()
        }
    }
    
    func checkForReset() -> Bool {
        if (player1Tank.getHealth() == 0 || player2Tank.getHealth() == 0) {
            return true
        } else {
            return false
        }
    }
    
    func deadCondition () {
        let winNode = SCNNode()
        var winText = SCNText()
        if (player1Tank.getHealth() <= 0) {
            winText = SCNText(string: "Player 2 Wins!", extrusionDepth: 0.0)
        } else if (player2Tank.getHealth() <= 0) {
            winText = SCNText(string: "Player 1 Wins!", extrusionDepth: 0.0)
        }
        winNode.geometry = winText
        rootNode.addChildNode(winNode)
        winNode.position = SCNVector3(-35, -6, 0)
        
        Task { try! await Task.sleep(nanoseconds: 5000000000)
            await winNode.removeFromParentNode()
            resetToStartScreen()
        }
    }
    
    func resetToStartScreen() {
        toggleGameStarted?()
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
