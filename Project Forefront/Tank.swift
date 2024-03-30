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
    let healthBar = SCNNode()
    
    private var tankPhysicsBody: SCNPhysicsBody?
    
    
    init(position: SCNVector3, color: UIColor) {
        super.init()
        
        let tankGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        tankGeometry.firstMaterial?.diffuse.contents = color
        
        self.geometry = tankGeometry
        self.position = position
        
        // Temporary implementation, to be replaced by asset
        let healthNumbers = SCNText(string: String(format: "%d/%d", health, maxHealth), extrusionDepth: 0.0)
        healthBar.geometry = healthNumbers
        healthBar.scale = SCNVector3(0.2, 0.2, 0.2)
        healthBar.position = SCNVector3(-4, 1, 0)
        
        self.addChildNode(healthBar)
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveLeft() {
        let forceMagnitude: Float = 70
        tankPhysicsBody?.applyForce(SCNVector3(-forceMagnitude, 0, 0), asImpulse: false)
    }
    
    func moveRight() {
        let forceMagnitude: Float = 70
        tankPhysicsBody?.applyForce(SCNVector3(forceMagnitude, 0, 0), asImpulse: false)
    }
    
    func decreaseHealth(damage: Int) {
        if (health - damage > 0) {
            health -= damage
        } else {
            health = 0
        }
        
        // Temporary implementation, to be replaced by asset
        let healthNumbers = SCNText(string: String(format: "%d/%d", health, maxHealth), extrusionDepth: 0.0)
        healthBar.geometry = healthNumbers
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

//        tankPhysicsBody?.velocity.z = 0

        let zConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true, with: { (node, position) -> SCNVector3 in
                return SCNVector3(position.x, position.y, 0) // Restricting z-position to 0
            })
            self.constraints = [zConstraint]

        self.physicsBody = tankPhysicsBody
    }
    
    func handleCollision(with object: SCNPhysicsBody) {
            // Check if the collision object is moving in the z-direction
            let zVelocity = object.velocity.y
            
            // If the collision object has z-axis velocity, adjust the tank's velocity
            if zVelocity != 0 {
                // Set the tank's velocity along the z-axis to zero
                tankPhysicsBody?.velocity.z = 0
            }
        }
    
}
