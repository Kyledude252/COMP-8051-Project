//
//  LevelSquare.swift
//  Project Forefront
//
//  Created by user on 2/28/24.
//

import Foundation
import SceneKit

class LevelSquare: SCNNode {
    
    
    init(squareSize: CGFloat, position: SCNVector3, materials: [SCNMaterial]) {
            super.init()
            
            let squareGeometry = SCNBox(width: squareSize, height: squareSize, length: squareSize, chamferRadius: 0)
            geometry = squareGeometry
        
        
            self.position = position
            
        squareGeometry.materials = materials
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func delete() {
        removeFromParentNode()
    }
}
