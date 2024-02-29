//
//  LevelNode.swift
//  Project Forefront
//
//  Created by user on 2/28/24.
//

import Foundation
import SceneKit

class Level: SCNNode {
    let squareSize: CGFloat = 0.25
    let numRows: Int
    let numCols: Int
    
    // COLORS
    let lightBrown = UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0)
    let darkBrown = UIColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 1.0)
    let slateBlueGray = UIColor(red: 112/255, green: 128/255, blue: 144/255, alpha: 1.0)
    let grassGreen = UIColor(red: 124/255, green: 252/255, blue: 0, alpha: 1.0)


    
    init(levelWidth: CGFloat, levelHeight: CGFloat) {
        self.numRows = Int(levelWidth / squareSize)
        self.numCols = Int(levelHeight / squareSize)
        super.init()
        
        setupLevel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLevel() {
        let topMaterial = SCNMaterial()
        let sideMaterial = SCNMaterial()
        topMaterial.diffuse.contents = grassGreen
        sideMaterial.diffuse.contents = slateBlueGray

        for row in 0..<numRows {
            for col in 0..<numCols {
//                for row in stride(from: 0, to: numRows, by: 2) {
//                    for col in stride(from: 0, to: numCols, by: 2) {
                
                let materials = [sideMaterial, sideMaterial, sideMaterial, sideMaterial, (col == 0) ? topMaterial : sideMaterial, sideMaterial]
                
                let squareNode = LevelSquare(squareSize: squareSize,
                                             position: SCNVector3(CGFloat(row) * squareSize, -CGFloat(col) * squareSize, 0),
                                             materials: materials)

                squareNode.position = SCNVector3(CGFloat(row) * squareSize, -squareSize / 2, CGFloat(col) * squareSize)

                addChildNode(squareNode)
            }
        }
    }
    
    
    func delete() {
        self.removeFromParentNode()
    }
}
