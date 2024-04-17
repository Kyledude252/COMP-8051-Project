import SceneKit


/**
 Class representing a tank object.
 
 The tank class is a modified SCNNode object.
 */
class Tank: SCNNode {
    var moveSpeed: Float = 0.1
    var acceleration: Float = 0.01
    var deceleration: Float = 0.02
    var currentSpeed: Float = 0.0
    var maxHealth: Int = 100
    var health: Int = 100
    let maxHealthNode = SCNNode()
    var size: Int = 1
    var currentSoundPlayer: SCNAudioPlayer?
    var tankMaterial = SCNMaterial()
    var tankModel = SCNNode()
    var facingRight = true
    let barWidth = 2.0
    
    private var tankPhysicsBody: SCNPhysicsBody?
    
    
    /**
     Constructor for a tank object.
     
     - parameter position: A SCNVector3 representing the position of a tank object in a scene.
     - parameter color: A UIColor representing the color of the tank.
     - parameter name: A string representing the name of the tank object.
     */
    init(position: SCNVector3, color: UIColor, name: String) {
        super.init()
        
        let tankGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        tankModel = loadModelFromFile(modelName: "Tank", fileExtension: "dae")
        tankModel.position = SCNVector3(0, -0.5, 0)
        tankModel.scale = SCNVector3(0.13, 0.13, 0.13)
        
        tankMaterial.diffuse.contents = color
        applyMaterialToAllNodes(node: tankModel)
        tankModel.geometry?.materials = [tankMaterial]
        
        addChildNode(tankModel)
        tankGeometry.firstMaterial?.transparency = 0
        //tankGeometry.firstMaterial?.diffuse.contents = color
        self.name = name
        self.geometry = tankGeometry
        self.position = position
        
        // Temporary implementation, to be replaced by asset
        let healthNumbers = SCNText(string: String(format: "%d/%d", health, maxHealth), extrusionDepth: 0.0)
        let healthBar = SCNPlane(width: barWidth, height: 0.4)
        let maxHealthBar = SCNPlane(width: barWidth, height: 0.4)
        let healthNode = SCNNode(geometry: healthBar)
        maxHealthNode.position = SCNVector3(0, 1, 0)
        
        healthNode.name = "HP"
        maxHealthNode.geometry = maxHealthBar
        healthNode.position = SCNVector3(0, 0, 0.01)
        healthBar.firstMaterial?.diffuse.contents = UIColor.green
        maxHealthBar.firstMaterial?.diffuse.contents = UIColor.red
        
        maxHealthNode.addChildNode(healthNode)
        self.addChildNode(maxHealthNode)
        
        setupPhysics()
    }
    
    
    /**
     NSCoding Initializer - Unused
     
     - parameter aDecoder: NSCoder used for decoding a serialized tank object.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     Function for applying a material to a node and recursively to all child nodes of the node.
     
     - parameter node: SCNNode to apply materials to and apply to children.
     */
    func applyMaterialToAllNodes(node: SCNNode) {
        if let geometry = node.geometry {
            geometry.materials = [tankMaterial]
        }
        for childNode in node.childNodes {
            applyMaterialToAllNodes(node: childNode)
        }
    }
    
    
    /**
     Function for printing out the node hierarchy of a node.
     
     - parameter node: the target node for printing.
     - parameter level: the level if a hierarchy to print.
     */
    func printNodeHierarchy(_ node: SCNNode, level: Int = 0) {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)\(node.name ?? "Unnamed Node")")
        for childNode in node.childNodes {
            printNodeHierarchy(childNode, level: level + 1)
        }
    }
    
    
    /**
     Function for handling the leftward tank movement.
     
     Called by:
     
     MainScene.tankMovement()
     */
    func moveLeft() {
        let forceMagnitude: Float = 60
        tankPhysicsBody?.applyForce(SCNVector3(-forceMagnitude, 0, 0), asImpulse: false)
        playMoveSound()
        tankModel.eulerAngles = SCNVector3(0,Double.pi,0)
        facingRight = false
    }
    
    
    /**
     Function for handling the rightward tank movement.
     
     Called by:
     
     MainScene.tankMovement()
     */
    func moveRight() {
        let forceMagnitude: Float = 60
        tankPhysicsBody?.applyForce(SCNVector3(forceMagnitude, 0, 0), asImpulse: false)
        playMoveSound()
        tankModel.eulerAngles = SCNVector3(0,0,0)
        facingRight = true
    }
    
    
    /**
     Function for handling the movement sound
     
     Called by:
     
     Tank.moveLeft(),
     Tank.moveRight()
     */
    func playMoveSound(){
        if let currentSoundPlayer = currentSoundPlayer {
            currentSoundPlayer.audioSource?.volume = 0.001
        }
        
        guard let tankSource = SCNAudioSource(named: "TankMoving.mp3") else {
            print("Failed to load TankMoving.mp3")
            return
        }
        
        tankSource.loops = false
        tankSource.volume = 0.08
        tankSource.isPositional = false
        tankSource.load()
        let tankFX = SCNAudioPlayer(source: tankSource)
        currentSoundPlayer = tankFX
        addAudioPlayer(tankFX)
    }
    
    
    /**
     Function for handling the jump.
     
     Called by:
     
     MainScene.moveActivePlayerTankVertically()
     */
    func moveUpward() {
        let forceMagnitude: Float = 180
        tankPhysicsBody?.applyForce(SCNVector3(0, forceMagnitude, 0), asImpulse: false)
        playJumpSound()
    }
    
    
    /**
     Function for handling the jump sound
     
     Called by:
     
     Tank.moveUpward()
     */
    func playJumpSound(){
        let jumpSource = SCNAudioSource(named: "woosh.mp3")
        jumpSource?.loops = false
        jumpSource?.volume = 0.2
        jumpSource?.isPositional = false
        jumpSource?.load()
        let jumpFX = SCNAudioPlayer(source: jumpSource!)
        addAudioPlayer(jumpFX)
    }
    
    
    /**
     Generic function for loading models from file.
     
     - parameter modelName: String representing the file name.
     - parameter fileExtension: String representing the file extension.
     - returns: an SCNReferenceNode containing the model.
     
     Called by:
     
     Tank.init()
     */
    func loadModelFromFile(modelName:String, fileExtension:String) -> SCNReferenceNode {
        
        let url = Bundle.main.url(forResource: modelName, withExtension: fileExtension)
        let refNode = SCNReferenceNode(url: url!)
        refNode?.load()
        refNode?.name = modelName
        return refNode!
    }
    
    
    /**
     Handles tank health deduction.
     
     - parameter damage: Int to subtract from the current health.
     
     Called by:
     
     MainScene.physicsWorld() during collision detection of explosions
     */
    func decreaseHealth(damage: Int) {
        if (health - damage > 0) {
            health -= damage
        } else {
            health = 0
        }
        
        let widthPct = Double(health) / Double(maxHealth) * barWidth
        
        var currentHealth = maxHealthNode.childNode(withName: "HP", recursively: true)
        currentHealth?.removeFromParentNode()
        
        let newHealth = SCNNode(geometry: SCNPlane(width: widthPct, height: 0.4))
        newHealth.position = SCNVector3(0.5*(widthPct-2), 0, 0.001)
        newHealth.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        newHealth.name = "HP"
        
        maxHealthNode.addChildNode(newHealth)
    }
    
    
    /**
     Accessor for the health value.
     
     - Returns: an Int representing the current health.
     
     Called by:
     
     MainScene.checkDeadCondition(),
     MainScene.checkForReset(),
     MainScene.moveActivePlayerTankVerticaly(),
     MainScene.tankMovement()
     */
    func getHealth() -> Int {
        return health
    }
    
    
    /**
     Setup function for handling the creation of the tank physics body.
     
     Called by:
     
     Tank.init()
     */
    func setupPhysics() {
        
        tankPhysicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        tankPhysicsBody?.angularVelocityFactor = SCNVector3(0, 0, 0)
        tankPhysicsBody?.angularDamping = 0
        tankPhysicsBody?.friction = 0.01
        tankPhysicsBody?.rollingFriction = 1
        tankPhysicsBody?.mass = 1
        tankPhysicsBody?.restitution = 0 // bouncing
        tankPhysicsBody?.damping = 0 // sliding
        tankPhysicsBody?.allowsResting = true
        tankPhysicsBody?.categoryBitMask = PhysicsCategory.tank
        tankPhysicsBody?.contactTestBitMask = PhysicsCategory.levelSquare
        tankPhysicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        
        
        
        applyZPositionConstraint(to: self)
        
        self.physicsBody = tankPhysicsBody
    }
    
    
    /**
     Applies a z-Constraint to an SCNNode.
     
     - parameter node: the target node to pass the z-constraint to.
     
     Called by:
     
     Tank.setupPhysics()
     */
    func applyZPositionConstraint(to node: SCNNode) {
        let zConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { node, position in
            return SCNVector3(position.x, position.y, 0) // Restricting z-position to 0
        }
        node.constraints = [zConstraint]
    }
}
