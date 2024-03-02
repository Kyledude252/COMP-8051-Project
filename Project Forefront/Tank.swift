//
//  Tank.swift
//  Project Forefront
//
//  Created by user on 2/14/24.
//
import SceneKit

class Tank: SCNNode {
    var moveSpeed: Float = 0.1
    var maxHealth: Int = 100
    var health: Int = 100
    let healthBar = SCNNode()
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveLeft() {
            self.position.x -= moveSpeed
        }
        
    func moveRight() {
        self.position.x += moveSpeed
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
}
