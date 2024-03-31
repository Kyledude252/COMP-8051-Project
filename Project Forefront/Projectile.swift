//
//  Projectile.swift
//  Project Forefront
//
//  Created by user on 3/29/24.
//

import Foundation
import SceneKit

class Projectile: SCNNode {
    
    init(from startPoint: SCNVector3) {
        super.init()
        
        // Basic setup
        let projectileGeometry = SCNSphere(radius: 0.3)
        let projectileMaterial = SCNMaterial()
        projectileGeometry.materials = [projectileMaterial]
        
        // Add collision setup here - For destroy or effect TODO
        
        
        // Change color later to adjust for shot fired
        projectileMaterial.diffuse.contents = UIColor.red
        self.geometry = projectileGeometry
        self.position = startPoint
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody = physicsBody
        physicsBody.categoryBitMask = PhysicsCategory.projectile
        physicsBody.contactTestBitMask = PhysicsCategory.levelSquare
        physicsBody.contactTestBitMask = PhysicsCategory.tank
        
        // important!
        let zConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true, with: { (node, position) -> SCNVector3 in
                return SCNVector3(position.x, position.y, 0) // Restricting z-position to 0
            })
            self.constraints = [zConstraint]
        
        print("Position of Projectile: \(self.position)")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
