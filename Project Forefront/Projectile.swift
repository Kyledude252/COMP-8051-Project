import Foundation
import SceneKit


/**
 Class representing a Projectile.
 
 Projectile inherits from SCNNode.
 */
class Projectile: SCNNode {
    
    
    /**
     Constructor for the Projectile.
     
     - parameter startPoint: an SCNVector3 representing the starting point of the projectile's trajectory.
     */
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
      
        //Creates new bitmask which contains both bitmasks of levelSquare and tank
        physicsBody.contactTestBitMask = PhysicsCategory.levelSquare | PhysicsCategory.tank
        
        // important!
        let zConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true, with: { (node, position) -> SCNVector3 in
                return SCNVector3(position.x, position.y, 0) // Restricting z-position to 0
            })
            self.constraints = [zConstraint]
        
        print("Position of Projectile: \(self.position)")

    }
    
    
    /**
     NSCoding Initializer - Unused
     
     - parameter aDecoder: NSCoder used for decoding a serialized Projectile object.
     
     Required
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
