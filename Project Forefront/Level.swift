import Foundation
import SceneKit


/**
 Class representing a Level.
 
 Level inherits from SCNNode.
 */
class Level: SCNNode {
    let squareSize: CGFloat = 0.5
    
    let numRows: Int
    let numCols: Int
    var cubeGrid: [[SCNNode?]]?
    
    //Level gen values
    let slopeAmplifier = 0.7
    let slopeDampening = 1.8
    let slopeDampeningThreshold = 0.2
    let maxSlope = 2.0
    var currentCol = -1
    var slope = Double.random(in: -2...2)
    var currentHeight = 0.0
    
    // COLORS
    let lightBrown = UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0)
    let darkBrown = UIColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 1.0)
    let blockColourTealGrey = UIColor(red: 27/255, green: 55/255, blue: 70/255, alpha: 1.0)

    let blockColourTealSurface = UIColor(red: 100/255, green: 125/255, blue: 150/255, alpha: 1.0)
    let blockColourTealSurface2 = UIColor(red: 40/255, green: 65/255, blue: 90/255, alpha: 1.0)
    let blockColourTealSurface3 = UIColor(red: 60/255, green: 85/255, blue: 110/255, alpha: 1.0)


    /**
     Constructor for a Level.
     
     - parameter levelWidth: a CGFloat for the level width.
     - parameter levelHeight: a CGFloat for the level height.
     */
    init(levelWidth: CGFloat, levelHeight: CGFloat) {
        self.numCols = Int(levelWidth / squareSize)
        self.numRows = Int(levelHeight / squareSize)
        self.currentHeight = Double(numRows/2)
        self.cubeGrid = Array(repeating: Array(repeating: nil, count: numRows), count: numCols)
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
    
    
    /**
     NSCoding Initializer - Unused
     
     - parameter aDecoder: NSCoder used for decoding a serialized Levelobject.
     
     Required
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     Function for setting up the Level geometry.
     
     Level.init()
     */
    private func setupLevel() {
        let material1 = SCNMaterial()
        let material2 = SCNMaterial()
        let material3 = SCNMaterial()
        material1.diffuse.contents = blockColourTealGrey
        material2.diffuse.contents = blockColourTealSurface2
        material3.diffuse.contents = blockColourTealSurface3

        for col in 0..<numCols {
            for row in 0..<numRows {
                if(levelGenerator(row: row, col: col)){
                    var materials = [SCNMaterial]()
                    var rand = Float.random(in: 0...100)
                    if rand <= 1 {
                        materials = [material1, material1,material1,material1,material2,material1]
                    } else if rand > 1 && rand <= 2 {
                        materials = [material1, material1,material1,material1,material3,material1]
                        }else{
                        materials = [material1, material1,material1, material1,material1,material1]
                    }
                    
                    // true height is actually on z axis (length)
                    // giving 3d effect
                    let trueHeight = currentHeight * 0.004 * CGFloat(row)/6*5
                    let squareNode = LevelSquare(squareWidth: squareSize, squareHeight: trueHeight, squareLength: squareSize,
                                                 position: SCNVector3(CGFloat(col) * squareSize, -CGFloat(row) * squareSize, 0),
                                                 materials: materials)
                    
                    squareNode.position = SCNVector3(CGFloat(col) * squareSize, -squareSize / 2, CGFloat(row) * squareSize)
                    
                    cubeGrid![col][row] = squareNode
                    
                    addChildNode(squareNode)
                }
            }
        }
    }
    
    
    /**
     Function to handle the instancing of tiles.
     
     - parameter row: row in cubeGrid
     - parameter col: column in cubeGrid
     - returns: a Bool representing whether the LevelSquare is to be constructed.
     
     Called by:
     
     Level.setupLevel()
     */
    func levelGenerator(row: Int, col: Int) -> Bool{
        if(col > currentCol){
            currentCol = col
            var slopeIncrease = slopeAmplifier*(1-(currentHeight/Double(numRows)))
            var slopeDecrease = -slopeAmplifier*(1-((Double(numRows)-currentHeight)/Double(numRows)))
            if(slope > slopeDampeningThreshold && currentHeight > Double(numRows)/2){
                slopeIncrease /= slopeDampening
            }
            if(slope < -slopeDampeningThreshold && currentHeight < Double(numRows)/2){
                slopeDecrease /= slopeDampening
            }
            slope += Double.random(in: slopeDecrease...slopeIncrease)
            slope = min(max(slope, -maxSlope), maxSlope)
            currentHeight += slope
            currentHeight = min(max(currentHeight, 0), Double(numRows))
        }
        
        return Double(row) > currentHeight
    }
    
    
    /**
     Function to handle the deletion of LevelSquares.
     
     - parameter col: Int of col in the cubeGrid.
     - parameter row: Int of row in the cubeGrid.
     - parameter radius: Int of radius around point in grid to delete.
     
     Called by:
     
     Level.explode(),
     Level.randomExplosion()
     */
    func deleteCubes(col: Int, row: Int, radius: Int){
        let rowMin = max(row - radius, 0)
        let rowMax = min(row + radius, numRows - 2)
        let colMin = max(col - radius, 0)
        let colMax = min(col + radius, numCols - 1)
        
        for x in colMin...colMax{
            for y in rowMin...rowMax{
                let circleRadius = sqrt(pow(Double(x - col), 2) + pow(Double(y - row), 2))
                if(circleRadius < Double(radius)){
                    cubeGrid![x][y]?.removeFromParentNode()
                }
            }
        }

        //cubeGrid![col][row]?.removeFromParentNode()
    }
    
    
    /**
     Debug function that performs a randomly positioned and sized explosion.
     */
    func randomExplosion() {
        let size = Int.random(in: 3...20)
        let posY = Int.random(in: 1...numRows-1)
        let posX = Int.random(in: 1...numCols-1)
        deleteCubes(col: posX, row: posY, radius: size)
    }
    
    
    /**
     Function to delete a Level.
     
     Called by:
     
     MainScene.setupForegroundLevel()
     */
    func delete() {
        self.removeFromParentNode()
    }
    
    
    /**
     Function to handle LevelSquare deletion location for the explosion.
     
     - parameter pos: SCNVector3 of the position relative to the parent node.
     - parameter rad: Int radius of explosion.
     
     Called by:
     
     MainScene.physicsWorld()
     */
    func explode(pos: SCNVector3, rad: Int){
        var x = 0
        var y = numRows-1
        var node = cubeGrid![x][y]
        while((node?.position.x)! < pos.x){
            x += 1
            node = cubeGrid![x][y]
        }
        while(node != nil && (node?.position.z)! > pos.z){
            y -= 1
            node = cubeGrid![x][y]
        }
        deleteCubes(col: x, row: y, radius: rad)
    }
}
