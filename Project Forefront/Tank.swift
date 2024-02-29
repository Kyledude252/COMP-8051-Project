//
//  Tank.swift
//  Project Forefront
//
//  Created by user on 2/14/24.
//
import SceneKit

class Tank: SCNNode {
    var moveSpeed: Float = 0.1
    
    init(position: SCNVector3, color: UIColor) {
        super.init()
        
        let tankGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        tankGeometry.firstMaterial?.diffuse.contents = color
        
        self.geometry = tankGeometry
        self.position = position
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
}
