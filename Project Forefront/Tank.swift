//
//  Tank.swift
//  Project Forefront
//
//  Created by user on 2/14/24.
//
import SceneKit

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyMaterialToAllNodes(node: SCNNode) {
        if let geometry = node.geometry {
            geometry.materials = [tankMaterial]
        }
        for childNode in node.childNodes {
            applyMaterialToAllNodes(node: childNode)
        }
    }
    
    func printNodeHierarchy(_ node: SCNNode, level: Int = 0) {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)\(node.name ?? "Unnamed Node")")
        for childNode in node.childNodes {
            printNodeHierarchy(childNode, level: level + 1)
        }
    }
    
    func moveLeft() {
        let forceMagnitude: Float = 60
        tankPhysicsBody?.applyForce(SCNVector3(-forceMagnitude, 0, 0), asImpulse: false)
        playMoveSound()
        tankModel.eulerAngles = SCNVector3(0,Double.pi,0)
        facingRight = false
    }
    
    func moveRight() {
        let forceMagnitude: Float = 60
        tankPhysicsBody?.applyForce(SCNVector3(forceMagnitude, 0, 0), asImpulse: false)
        playMoveSound()
        tankModel.eulerAngles = SCNVector3(0,0,0)
        facingRight = true
    }
    
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
    
    func moveUpward() {
        let forceMagnitude: Float = 180
        tankPhysicsBody?.applyForce(SCNVector3(0, forceMagnitude, 0), asImpulse: false)
        playJumpSound()
    }
    
    func playJumpSound(){
        let jumpSource = SCNAudioSource(named: "woosh.mp3")
        jumpSource?.loops = false
        jumpSource?.volume = 0.2
        jumpSource?.isPositional = false
        jumpSource?.load()
        let jumpFX = SCNAudioPlayer(source: jumpSource!)
        addAudioPlayer(jumpFX)
    }
    
    
    func loadModelFromFile(modelName:String, fileExtension:String) -> SCNReferenceNode {
        
        let url = Bundle.main.url(forResource: modelName, withExtension: fileExtension)
        let refNode = SCNReferenceNode(url: url!)
        refNode?.load()
        refNode?.name = modelName
        return refNode!
    }
    
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
    
    func getHealth() -> Int {
        return health
    }
    
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

    func applyZPositionConstraint(to node: SCNNode) {
        let zConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { node, position in
            return SCNVector3(position.x, position.y, 0) // Restricting z-position to 0
        }
        node.constraints = [zConstraint]
    }}
