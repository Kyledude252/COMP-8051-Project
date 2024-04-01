//
//  LevelSquare.swift
//  Project Forefront
//
//  Created by user on 2/28/24.
//

import Foundation
import SceneKit

class LevelSquare: SCNNode {
    var size: Int = 1
    
    init(squareSize: CGFloat, position: SCNVector3, materials: [SCNMaterial]) {
            super.init()
            
            let squareGeometry = SCNBox(width: squareSize, height: squareSize, length: squareSize, chamferRadius: 0)
            geometry = squareGeometry
        
        
            self.position = position
            
        squareGeometry.materials = materials
        setupPhysics()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func delete() {
        removeFromParentNode()
    }
    
    private func setupPhysics() {
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCategory.levelSquare
        physicsBody.contactTestBitMask = PhysicsCategory.projectile | PhysicsCategory.tank

        self.physicsBody = physicsBody
        physicsBody.mass = 0
        physicsBody.friction = 10
    }
}
