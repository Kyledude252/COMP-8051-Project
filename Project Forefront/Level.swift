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
    var cubeGrid: [[SCNNode?]]?
    
    // COLORS
    let lightBrown = UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0)
    let darkBrown = UIColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 1.0)
    let slateBlueGray = UIColor(red: 112/255, green: 128/255, blue: 144/255, alpha: 1.0)
    let grassGreen = UIColor(red: 124/255, green: 252/255, blue: 0, alpha: 1.0)


    
    init(levelWidth: CGFloat, levelHeight: CGFloat) {
        self.numRows = Int(levelWidth / squareSize)
        self.numCols = Int(levelHeight / squareSize)
        self.cubeGrid = Array(repeating: Array(repeating: nil, count: numCols), count: numRows)
        super.init()
        
        setupLevel()
        /*
         //some hardcoded example explosions
         deleteCubes(row: 100, col: 30, radius: 20)
         deleteCubes(row: 150, col: 50, radius: 10)
         deleteCubes(row: 120, col: 20, radius: 15)
         deleteCubes(row: 200, col: 50, radius: 40)
         deleteCubes(row: 250, col: 30, radius: 5)
         */

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
                
                cubeGrid![row][col] = squareNode

                addChildNode(squareNode)
            }
        }
    }
    
    func deleteCubes(row: Int, col: Int, radius: Int){
        let rowMin = max(row - radius, 0)
        let rowMax = min(row + radius, numRows - 1)
        let colMin = max(col - radius, 0)
        let colMax = min(col + radius, numCols - 1)
        
        for x in rowMin...rowMax{
            for y in colMin...colMax{
                
                let circleRadius = sqrt(pow(Double(x - row), 2) + pow(Double(y - col), 2))
                if(circleRadius < Double(radius)){
                    cubeGrid![x][y]?.removeFromParentNode()
                }

            }
        }

        cubeGrid![row][col]?.removeFromParentNode()
    }
    
    func delete() {
        self.removeFromParentNode()
    }
}
