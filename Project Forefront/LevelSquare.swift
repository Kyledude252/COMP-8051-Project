import Foundation
import SceneKit


/**
 Class representing a LevelSquare.
 
 LevelSquare inherits from SCNNode.
 */
class LevelSquare: SCNNode {
    var size: Int = 1
    
    
    /**
     Constructor for a LevelSquare.
     
     - parameter squareWidth: a CGFloat representing the box' width.
     - parameter squareHeight: a CGFloat representing the box'height.
     - parameter squareLength: a CGFloat representing the box' length.
     - parameter position: an SCNVector3 representing the position in the scene.
     - parameter materials: an Array of SCNMaterial objects.
     */
    init(squareWidth: CGFloat, squareHeight: CGFloat, squareLength: CGFloat, position: SCNVector3, materials: [SCNMaterial]) {
            super.init()
            
            let squareGeometry = SCNBox(width: squareWidth, height: squareHeight, length: squareLength, chamferRadius: 0)
            geometry = squareGeometry
        
        
            self.position = position
            
        squareGeometry.materials = materials
        setupPhysics()
    }
    
    
    /**
     NSCoding Initializer - Unused
     
     - parameter coder: NSCoder used for decoding a serialized LevelSquare object.
     
     Required
     */
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     Function to delete a LevelSquare.
     */
    func delete() {
        removeFromParentNode()
    }
    
    
    /**
     Setup function for handling the creation of the LevelSquare physics body.
     
     Called by:
     
     LevelSquare.init()
     */
    private func setupPhysics() {
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCategory.levelSquare
        physicsBody.contactTestBitMask = PhysicsCategory.projectile | PhysicsCategory.tank

        self.physicsBody = physicsBody
        physicsBody.mass = 0
        physicsBody.friction = 15
    }
}
