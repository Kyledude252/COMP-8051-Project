//
//  MainScene.swift
//  Project Forefront
//
//  Created by user on 2/13/24.
//

import Foundation
import SceneKit

class MainScene: SCNScene, SCNPhysicsContactDelegate {
    var cameraNode = SCNNode()
    var cameraXOffset: Float = 0
    var cameraYOffset: Float = -3
    var cameraZOffset: Float = 35
    
    var player1Tank: Tank!
    var player2Tank: Tank!
    var activePlayer: Int = 1
    var tankMovingLeft = false
    var tankMovingRight = false
    var movementPlayerSteps = 1
    var maxMovementPlayerSteps = 10 //TODO /TURNS
    let levelWidth: CGFloat = 100
    let levelHeight: CGFloat = 30
    var playerBoostCount = 5;
    
    var toggleGameStarted: (() -> Void)? // callback for reset
    
    var groundPosition: CGFloat = 5
    
    var levelNode = Level(levelWidth: 1, levelHeight: 1)
    
    var projectileShot = false
    
    //grab view
    weak var scnView: SCNView?
    // holds line for redrawing it
    var lineNode: SCNNode?
    // throttle drawing line to prevent lag fest if needed, currently not used
    var isThrottling = false
    // Store projeciles to remove alter
    var projectileStore = SCNNode()
    // Adjusts how far the tank can shoot
    var maxProjectileX: Float = 15.0
    var maxProjectileY: Float = 15.0
    // used to determine whether player can fire or not
    var ammunition: Int = 1
    // used for ammo count
    var ammoNode: SCNNode?
    // used to check if player can move (is in move mode)
    var canMove: Bool = true
    // used for freezing movement during turn transition
    var moveFlag: Bool = true
    // used to check if turnEnd button is clicked
    var turnEnded: Bool = false
    // turn time
    var turnTime: Int = 20
    // check if projectile is in the air
    var projectileIsFlying: Bool = false
    // Semaphore for freezing projectile
    let semaphore = DispatchSemaphore(value: 0)
    // shot type use for semaphore, to stop waiting if firing laser
    var shotWhiff = 0
    
    var projectile: SCNNode?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var mainSceneViewModel: MainSceneViewModel?
    
    // Initializer
    override init() {
        super.init()
        
        

        physicsWorld.contactDelegate = self
        background.contents = UIColor.black
        
        setupCamera()
        setupBackgroundLayers()
        setupForegroundLevel()
        setupLights()
        //Used for projectile removal
        setupProjectileStore()
        //Used for firing once per turn
        setUpAmmo()
        
        player1Tank = Tank(position: SCNVector3(-20, groundPosition, 0), color: .red)
        player2Tank = Tank(position: SCNVector3(20, groundPosition, 0), color: .green)
        
        rootNode.addChildNode(player1Tank)
        rootNode.addChildNode(player2Tank)
        
        print("Position of player1Tank: \(player1Tank.position)")
        print("Position of player1Tank: \(player2Tank.position)")
        
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    func setupViewModel(viewModel: MainSceneViewModel){
        mainSceneViewModel = viewModel
    }
    
    func cleanup(){
        rootNode.childNodes.forEach { $0.removeFromParentNode() }
        NotificationCenter.default.removeObserver(self)
    }
    
    // GRAPHICS // //////
    @MainActor
    func firstUpdate() {
        setupAudio()
        tankMovement() // Call reanimate on the first graphics update frame
    }
    
    // CAMERA // ////////////
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
        //cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        
        rootNode.addChildNode(cameraNode)
    }
    
    func updateCameraPosition(cameraXOffset: Float, cameraYOffset: Float) {
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
    }
    
    func setupAudio(){
        
        guard let BGSource = SCNAudioSource(named: "BGSong.mp3") else {
                print("Failed to load BGSong.mp3")
                return
            }
        
        //let BGSource = SCNAudioSource(named: "BGSong.mp3")!
        BGSource.loops = true
        BGSource.volume = 1.0
        BGSource.isPositional = false
        BGSource.load()
        let BGSong = SCNAudioPlayer(source: BGSource)
        rootNode.addAudioPlayer(BGSong)
        print("ADDED SONG")
    }
    
    
    // BACKGROUND / ENVIORNMENT // ////////////
    func setupBackgroundLayers() {
        // For parallax perspective -
 
        //Example starter code
//        let backgroundNode1 = createBackgroundNode(imageName: "background-612x612.jpg", position: SCNVector3(0, 0, -10), size: CGSize(width: 100, height: 20))
        let backgroundNode2 = createBackgroundNode(imageName: "background-612x612.jpg", position: SCNVector3(0, 0, -20), size: CGSize(width: 260, height: 70))
//
        // Add the background nodes to the scene
//        rootNode.addChildNode(backgroundNode1)
        rootNode.addChildNode(backgroundNode2)
    }
    
    func createBackgroundNode(imageName: String, position: SCNVector3, size: CGSize) -> SCNNode {
        let geometry = SCNPlane(width: size.width, height: size.height)
        geometry.firstMaterial?.diffuse.contents = UIImage(named: imageName)
        
        let backgroundNode = SCNNode(geometry: geometry)
        backgroundNode.position = position

        return backgroundNode
    }
    
    
    func setupForegroundLevel() {
        
        levelNode.delete()
        levelNode = Level(levelWidth: levelWidth, levelHeight: levelHeight)
        
        levelNode.position = SCNVector3(-(levelWidth/2), groundPosition - (levelNode.squareSize / 2), 0)
        
        levelNode.eulerAngles = SCNVector3(x: .pi/2 , y: 0, z: 0)
        
        rootNode.addChildNode(levelNode)
        
        print("Position of levelNode after rotation: \(levelNode.position)")
    }
    
    func setupLights() {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = SCNLight.LightType.ambient
        ambientLight.light?.color = UIColor.white
        ambientLight.light?.intensity = 700
        rootNode.addChildNode(ambientLight)
        
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = SCNLight.LightType.directional
        let lDirVal = Int(Date().timeIntervalSince1970) % 5
        var lDirVec: SCNVector3
        switch lDirVal {
        case 0:
            lDirVec = SCNVector3(4, -0.5, 1)
        case 1:
            lDirVec = SCNVector3(2, -1, 1)
        case 2:
            lDirVec = SCNVector3(1, -1, 1)
        case 3:
            lDirVec = SCNVector3(-1.5, -1, 1)
        case 4:
            lDirVec = SCNVector3(-3, -1, 1)
        default:
            lDirVec = SCNVector3(0, -1, 0.2)
        }
        sunLight.look(at: lDirVec)
        sunLight.light?.intensity = 3000
        rootNode.addChildNode(sunLight)
        
        let uLight = SCNNode()
        uLight.light = SCNLight()
        uLight.light?.type = SCNLight.LightType.omni
        uLight.light?.attenuationStartDistance = 0
        uLight.light?.attenuationEndDistance = 150
        uLight.light?.attenuationFalloffExponent = 4
        uLight.light?.intensity = 10000
        uLight.light?.color = UIColor(red: 0, green: 0.1, blue: 0.7, alpha: 1)
        
        uLight.position = SCNVector3(cameraXOffset, cameraYOffset - 50, cameraZOffset)
        rootNode.addChildNode(uLight)
    }
    
    // PLAYER CONTROL & SWITCHING // ///////////
    
    func switchActivePlayer() {
        activePlayer = (activePlayer == 1) ? 2 : 1
    }
    
    
    func moveActivePlayerTankLeft() {
        // If player is not allowed to move, function is disabled
        if (canMove == false) {
            return
        }
        tankMovingLeft = true
        tankMovingRight = false
        movementPlayerSteps -= 1
        maxMovementPlayerSteps -= 1
    }
    
    func moveActivePlayerTankRight() {
        // If player is not allowed to move, function is disabled
        if (canMove == false) {
            return
        }
        tankMovingRight = true
        tankMovingLeft = false
        movementPlayerSteps -= 1
        maxMovementPlayerSteps -= 1
    }
    
    @MainActor
    func moveActivePlayerTankVertically(){
        // If player is not allowed to move, function is disabled
        if (canMove == false) {
            return
        }
        if activePlayer == 1  && player1Tank.getHealth() > 0 {
            if(playerBoostCount > 0){
                player1Tank.moveUpward()
                playerBoostCount -= 1
            }
        }else{
            if(playerBoostCount > 0){
                player2Tank.moveUpward()
                playerBoostCount -= 1
                }
        }
    }
    
    func stopMovingTank() {
        tankMovingLeft = false
        tankMovingRight = false
    }
    
    
    // used in sceneKitView to match with firemode button
    func toggleTankMove(move: Bool) {
        canMove = move
    }
    
    @MainActor
    func tankMovement (){
        if maxMovementPlayerSteps > 0 {
            
            if activePlayer == 1  && player1Tank.getHealth() > 0 { // Player 1
                if tankMovingLeft {
                    player1Tank.moveLeft()
                    stopMovingTank()
                } else if tankMovingRight {
                    player1Tank.moveRight()
                    stopMovingTank()
                    
                }
            } else if activePlayer == 2 && player2Tank.getHealth() > 0 { // Player 2
                if tankMovingLeft {
                    player2Tank.moveLeft()
                    stopMovingTank()
                } else if tankMovingRight {
                    player2Tank.moveRight()
                    stopMovingTank()
                }
            }
            movementPlayerSteps -= 1
            if movementPlayerSteps == 0 {
                stopMovingTank()
            } else {
                
            }
        }
        
        Task { try! await Task.sleep(nanoseconds: 1000000)
            tankMovement()
        }
    }
    
    // Temp function to debug damage
//    func takeDamage() {
//        if activePlayer == 1 {
//            player1Tank.decreaseHealth(damage: 10)
//            checkDeadCondition()
//        } else if activePlayer == 2 {
//            player2Tank.decreaseHealth(damage: 10)
//            checkDeadCondition()
//        }
//    }
    
    func checkForReset() -> Bool {
        if (player1Tank.getHealth() <= 0 || player2Tank.getHealth() <= 0) {
            return true
        } else {
            return false
        }
    }
    
    func checkDeadCondition () {
        // a little duplicacated but fine for now
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.green

        if (player1Tank.getHealth() <= 0) {
            let winNode = SCNNode()
            var winText = SCNText()
            var player2Wins = UserDefaults.standard.integer(forKey: "Player2Wins")
            player2Wins += 1
            UserDefaults.standard.set(player2Wins, forKey: "Player2Wins")

            winText = SCNText(string: "Player 2 Wins!", extrusionDepth: 0.0)
            winText.firstMaterial = textMaterial
            winNode.geometry = winText
            rootNode.addChildNode(winNode)
            winNode.position = SCNVector3(-35, -6, 1)
            Task { try! await Task.sleep(nanoseconds: 5000000000)
                await winNode.removeFromParentNode()
                resetToStartScreen()
            }
        } else if (player2Tank.getHealth() <= 0) {
            let winNode = SCNNode()
            var winText = SCNText()
            var player1Wins = UserDefaults.standard.integer(forKey: "Player1Wins")
            player1Wins += 1
            UserDefaults.standard.setValue(player1Wins, forKey: "Player1Wins")
            winText = SCNText(string: "Player 1 Wins!", extrusionDepth: 0.0)
            winText.firstMaterial = textMaterial
            winNode.geometry = winText
            rootNode.addChildNode(winNode)
            winNode.position = SCNVector3(-35, -6, 1)
            Task { try! await Task.sleep(nanoseconds: 5000000000)
                await winNode.removeFromParentNode()
                resetToStartScreen()
            }
        }
    }
    
    func resetToStartScreen() {
        toggleGameStarted?()
    }
    
    //-------------------------------------------------------------------------------------------------------------------
    //Firing Code
    //-------------------------------------------------------------------------------------------------------------------
    //function that's sent to coordinator
    @objc
    func toggleFire(isFireMode: Bool){
        print(player1Tank.position)
        if !isFireMode {
            lineNode?.removeFromParentNode()
            lineNode = nil
        }
        //tank firing object funciton
    }
    
    //Takes in a start and end point of 3d Vectors and draws a custom line based on vertices between points
    func createTrajectoryLine(from startPoint: SCNVector3, to endPoint: SCNVector3) {
        //array containing start and end point of the line
        let vertices: [SCNVector3] = [startPoint, endPoint]
        //A container for vertex data forming part of the definition for a three-dimensional object, or geometry. <- check documentation
        let vertexSource = SCNGeometrySource(vertices: vertices)
        //defines 0 as start point and 1 as end point of hte line
        let indices: [Int32] = [0, 1]
        //conversion required
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        //Set primative type to .line, connects points vertexSource with just one line line
        //Ironically this means the line width requires other solutions to increase the thickness
        let element = SCNGeometryElement(data: indexData, primitiveType: .line, primitiveCount: 1, bytesPerIndex: MemoryLayout<Int32>.size)
        
        //Actually creating a line
        let lineGeometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let lineNode = SCNNode(geometry: lineGeometry)
        
        //this color can be changed later based on player color based on active player
        lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        // Remove the old line node
        removeLine()
        
        // Set the new line node
        self.lineNode = lineNode
        self.rootNode.addChildNode(lineNode)
    }

    // type:
    // 1. regular shot (lob)
    // 2. laser
    func launchProjectile(from startPoint: SCNVector3, to endPoint: SCNVector3, type: Int) {
        // cannot fire if ammo = 0
        if (ammunition == 0) {
            return
        }
        if (!projectileShot){
            projectile = Projectile(from: startPoint)
            
            let pTrail = SCNParticleSystem()
            pTrail.emitterShape = SCNSphere(radius: 0.1)
            pTrail.emissionDuration = 1.0
            pTrail.loops = true
            pTrail.idleDuration = 0
            pTrail.birthLocation = SCNParticleBirthLocation.volume
            pTrail.birthRate = 100
            pTrail.particleSize = 0.0
            
            
            projectile?.addParticleSystem(pTrail)
            
            // use for laser
            let anim1 = CABasicAnimation()
            anim1.fromValue = 0.5
            anim1.toValue = 0.0
            anim1.duration = 1.6
            anim1.repeatCount = 0
            anim1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            let shrinkCtrl = SCNParticlePropertyController(animation: anim1)            
            
            pTrail.propertyControllers = [ SCNParticleSystem.ParticleProperty.size: shrinkCtrl ]
            
            //Get direction of vector
            let direction = SCNVector3(endPoint.x - startPoint.x, endPoint.y - startPoint.y, 0)//endPoint.z - startPoint.z)
            
            // need offset to avoid physics
            // might need to edit this value later to change interactions
            let offsetFactor: Float = 0.02
            let offsetStartingPosition = SCNVector3(startPoint.x + (direction.x * offsetFactor), startPoint.y + (direction.y * offsetFactor), startPoint.z + direction.z * offsetFactor)
            
            let lightOffsetFactor: Float = 0.01
            let lightOffsetPos = SCNVector3(startPoint.x + (direction.x * lightOffsetFactor), startPoint.y + (direction.y * lightOffsetFactor), startPoint.z + direction.z * lightOffsetFactor)
            
            let shotLightNode = SCNNode()
            shotLightNode.position = offsetStartingPosition
            shotLightNode.light = SCNLight()
            shotLightNode.light?.type = SCNLight.LightType.omni
            shotLightNode.light?.intensity = 100000
            shotLightNode.light?.attenuationStartDistance = 3
            shotLightNode.light?.attenuationFalloffExponent = 4
            shotLightNode.light?.attenuationEndDistance = 15
            shotLightNode.light?.color = UIColor(red: 0.95, green: 0.9, blue: 0.5, alpha: 1)
            rootNode.addChildNode(shotLightNode)
            
            shotLightNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.1), SCNAction.removeFromParentNode()]))
            
            projectile?.position = offsetStartingPosition

            //Use to remove later
            projectileStore.addChildNode(projectile!)
            
            //Add scalar, edit as needed, maybe add to paramter later for different shots
            let forceVector = SCNVector3(direction.x*3, direction.y*3, direction.z)
            
            // Normal shot ------------------------------------------------------------
            if(type == 1 ) {
                // used to dampen if going to far
                var dampingFactor: Float = 0.1
                
                if(forceVector.x >= maxProjectileX || forceVector.y >= maxProjectileY) {
                    if (forceVector.x > forceVector.y) {
                        dampingFactor = 15/forceVector.x
                    } else {
                        dampingFactor = 15/forceVector.y
                    }
                }
                //Dampen if going to far
                let dampenedForceVector = SCNVector3(forceVector.x * dampingFactor, forceVector.y * dampingFactor, forceVector.z)

    //            print("\nForce vector: \(forceVector) ")
    //            print("\ndampened: \(dampenedForceVector) ")
                
                //Apply force to node, dampen if too much force is applied
                if(forceVector.x >= 15 || forceVector.y >= 15) {
                    projectile?.physicsBody?.applyForce(dampenedForceVector, asImpulse: true)
                } else {
                    projectile?.physicsBody?.applyForce(forceVector, asImpulse: true)
                }
            } else if (type == 2) {
                let laserForceVector = SCNVector3(forceVector.x * 10, forceVector.y * 10, forceVector.z)
                projectile?.physicsBody?.applyForce(laserForceVector, asImpulse: true)
            } else {
                //just fires basic shot if no inptu for some reason
                projectile?.physicsBody?.applyForce(forceVector, asImpulse: true)
            }
            
            playShootSound()

            
            // For freezing turn
            projectileIsFlying = true
            
            // Remove line again
            removeLine()
            // fired shot, therefore used ammo
            removeAmmo()
            projectileShot = true
            playerBoostCount=10
        }
    }
    
    // removes line drawn for trajectory
    func removeLine() {
        self.lineNode?.removeFromParentNode()
    }
    // used to remove all projectile nodes later
    func setupProjectileStore() {
        self.rootNode.addChildNode(projectileStore)
    }
    // same as above
    func deleteProjectiles() {
        for childNode in projectileStore.childNodes {
            childNode.removeFromParentNode()
        }
    }
    
    func playShootSound(){
        let shootSource = SCNAudioSource(named: "Shoot.mp3")
        shootSource?.loops = false
        shootSource?.volume = 0.2
        shootSource?.isPositional = false
        shootSource?.load()
        let shootFX = SCNAudioPlayer(source: shootSource!)
        rootNode.addAudioPlayer(shootFX)
    }
    
    ///------------------------------------------------
    // used to set-up text for ammunition
    func setUpAmmo() {
        let ammoText = SCNText(string: "shots: \(ammunition)", extrusionDepth: 0.0)
        ammoText.font = UIFont.systemFont(ofSize: 3)
        ammoNode = SCNNode(geometry: ammoText)
        ammoNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        ammoNode!.position = SCNVector3(-45, 8, 1)
        self.rootNode.addChildNode(ammoNode!)
    }
    // sets ammo to one, can be changed later to add different ammo for different weapon types
    func giveAmmo() {
        ammunition = 1
        //update screen display
        if let textGeo = ammoNode?.geometry as? SCNText {
            textGeo.string = "shots: \(ammunition)"
        }
    }
    // sets ammo to 0, can be changed later
    func removeAmmo() {
        ammunition = 0
        // update screen display
        if let textGeo = ammoNode?.geometry as? SCNText {
            textGeo.string = "shots: \(ammunition)"
        }
    }

    //------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------

    
    func physicsWorld(_ world:SCNPhysicsWorld, didBegin contact: SCNPhysicsContact){
        
        let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        if contactMask == (PhysicsCategory.levelSquare | PhysicsCategory.projectile) {

            //Check flag for freezing timer
            projectileIsFlying = false
            semaphore.signal()

            doExpLight(contact: contact)
            
            levelNode.explode(pos: contact.nodeA.position)

            let dx1 = contact.contactPoint.x - player1Tank.presentation.worldPosition.x
            let dz1 = contact.contactPoint.z - player1Tank.presentation.worldPosition.z
            let dx2 = contact.contactPoint.x - player2Tank.presentation.worldPosition.x
            let dz2 = contact.contactPoint.z - player2Tank.presentation.worldPosition.z

            if(sqrt(dx1*dx1+dz1+dz1) < 5 && contact.nodeB.parent != nil){
                //NOTE distance is set to 5 to line up with explosion side of 10, since the level blocks are 0.5 scale. If we have different explosion sizes or change the scale of the cubes the distance here should be explosionSize*LevelCubeScale. Something to change later when we make different explosives with different sizes and figure out that system.
                player1Tank.decreaseHealth(damage: 10)
                let forceMagnitude: Float = 60
                player1Tank.physicsBody?.applyForce(SCNVector3(0, -forceMagnitude, 0), asImpulse: false)
            }
            if(sqrt(dx2*dx2+dz2+dz2) < 5 && contact.nodeB.parent != nil){
                player2Tank.decreaseHealth(damage: 10)
                let forceMagnitude: Float = 60
                player2Tank.physicsBody?.applyForce(SCNVector3(0, -forceMagnitude, 0), asImpulse: false)
            }
            contact.nodeB.removeFromParentNode()
            
            guard let explodeSource = SCNAudioSource(named: "explosion.wav") else {
                    print("Failed to load explosion.mp3")
                    return
                }
            
            explodeSource.loops = false
            explodeSource.volume = 0.3
            explodeSource.isPositional = false
            explodeSource.load()
            let explodeFX = SCNAudioPlayer(source: explodeSource)
            rootNode.addAudioPlayer(explodeFX)
            print("ADDED EXPLOSION")
            
        }else if contactMask == (PhysicsCategory.tank | PhysicsCategory.projectile){
            //Tank specific collision if we do that

        }

    }
    
    func doExpLight(contact: SCNPhysicsContact) {
        let expLightNode = SCNNode()
        expLightNode.position = SCNVector3(x: contact.contactPoint.x, y: contact.contactPoint.y + 0.1, z: contact.contactPoint.z + 2)
        expLightNode.light = SCNLight()
        expLightNode.light?.type = SCNLight.LightType.omni
        expLightNode.light?.intensity = 0
        expLightNode.light?.attenuationStartDistance = 5
        expLightNode.light?.attenuationFalloffExponent = 3
        expLightNode.light?.attenuationEndDistance = 15
        expLightNode.light?.color = UIColor(red: 0.96, green: 0.61, blue: 0.98, alpha: 1)
        rootNode.addChildNode(expLightNode)
        
        let anim = CABasicAnimation(keyPath: "intensity")
        anim.fromValue = 300000
        anim.toValue = 0
        anim.duration = 0.3
        anim.repeatCount = 0
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let expFlatNode = SCNNode()
        expFlatNode.geometry = SCNCylinder(radius: 5.5, height: 1)
        expFlatNode.rotation = SCNVector4(1, 0, 0, Float.pi/2)
        expFlatNode.position = SCNVector3(contact.contactPoint.x, contact.contactPoint.y, contact.contactPoint.z)
        expFlatNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        expFlatNode.geometry?.firstMaterial?.transparency = 0.0
        rootNode.addChildNode(expFlatNode)
        
        let anim2 = CABasicAnimation(keyPath: "transparency")
        anim2.fromValue = 1.0
        anim2.toValue = 0.0
        anim2.duration = 0.2
        anim2.repeatCount = 0
        anim2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        expLightNode.light?.addAnimation(anim, forKey: "dim")
        expFlatNode.geometry?.firstMaterial?.addAnimation(anim2, forKey: "fade")
        expLightNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.5), SCNAction.removeFromParentNode()]))
        expFlatNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.3), SCNAction.removeFromParentNode()]))
    }
    
    func getTankPosition() -> SCNVector3? {
        if activePlayer == 1 {
            return player1Tank.presentation.position
        } else if activePlayer == 2 {
            return player2Tank.presentation.position
        }
        return nil
    }

    func turnEndedPressed() {
        turnEnded = true
    }
    var count = 0
    func toggleTurns() {
        let player: Int
        if (activePlayer == 1){
            player = 1
        } else {
            player = 2
        }
        

        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.blue
        
        //Stuf that happens
        //deleteProjectiles()
        

        // Declare countdownNode and winNode outside the closure
        var countdownNode: SCNNode?
        var winNode: SCNNode?
        var swapNode: SCNNode?
        
        // Countdown
        DispatchQueue.global().async {
            for i in (1...self.turnTime).reversed() {
                if (self.turnEnded == true) {
                    break
                }
                DispatchQueue.main.async {
                    let countdownText = SCNText(string: "\(i)", extrusionDepth: 0.0)
                    countdownText.firstMaterial = textMaterial
                    countdownNode = SCNNode(geometry: countdownText)
                    countdownNode!.position = SCNVector3(-35, -10, 1)
                    self.rootNode.addChildNode(countdownNode!)
                    //print("Countdown: \(i)")
                    //player stuff to determine who's turn it is
                    let winText = SCNText(string: "Player \(player) turn", extrusionDepth: 0.0)
                    winText.font = UIFont.systemFont(ofSize: 5)
                    winNode = SCNNode(geometry: winText)
                    self.rootNode.addChildNode(winNode!)
                    winNode!.position = SCNVector3(-35, 1, 1)
                    //print("Player \(player) turn")
                }
                // Wait for projectile
                while (self.projectileIsFlying)  {
                    
                    if (self.semaphore.wait(timeout: .now() + 0.1) == .timedOut) {
                        //Keep checking if projectile is still flying (go down to physics body for contact)
                        // checks if projectile completely whiffed and is fyling through the air
                        self.count+=1
                        if (self.count == 20){
                            self.shotWhiff = 1
                        }
                        
                        if (self.shotWhiff == 1) {
                            print("\n shot whiffed")
                            self.shotWhiff = 0
                            self.count = 0
                            self.projectileIsFlying = false
                            self.semaphore.signal()
                            break
                        }
                        
                        print("\n waiting \(self.count)")
                    } else {
                        self.count = 0
                        break
                    }
                }
                
                sleep(1) // Sleep for 1 second
                DispatchQueue.main.async {
                    countdownNode?.removeFromParentNode()
                    winNode?.removeFromParentNode()

                }
            }

            // Extra check in case palyer releases 1 second before firing due to how turn timer is coded
            while (self.projectileIsFlying)  {
                if (self.semaphore.wait(timeout: .now() + 0.1) == .timedOut) {
                    //Keep checking if projectile is still flying (go down to physics body for contact)
                    print("\n waiting")
                } else {
                    //
                    break
                }

            }
            
            //Stuf that happens to be processed between turn----------------------------------------------
            self.turnEnded = false
            // delete projectile nodes
            self.deleteProjectiles()
            //toggle player control
            if (player == 1){
                self.activePlayer = 2
            } else {
                self.activePlayer = 1
            }
            // removes line, just in case
            self.removeLine()

            self.projectileShot = false
          



            //recursive call to pass turn to other palyer on turn end
            // may cause issues with manually triggering turn change
            
            
            // Add buffer of time before passing control to avoid troll situations
            for i in (1...3).reversed() {
                
                DispatchQueue.main.async {
                    //store whether player is allowed to move or not
                    self.moveFlag = self.canMove
                    // cannot move during turn transition
                    self.canMove = false
                    
                    let swapText = SCNText(string: "Passing Control to Player \(self.activePlayer) in \(i)", extrusionDepth: 0.0)
                    swapText.font = UIFont.systemFont(ofSize: 5)
                    swapNode = SCNNode(geometry: swapText)
                    self.rootNode.addChildNode(swapNode!)
                    swapNode!.position = SCNVector3(-35, 1, 1)
                }
                sleep(1) // Sleep for 1 second
                DispatchQueue.main.async {
                    // re-enable movement assuming player is in movement mode
                    if(self.moveFlag == true) {
                        self.canMove = true
                    }
                    swapNode?.removeFromParentNode()
                }
            }

            // reset ammo to 1 for next turn, put here so player can't fire shots when turn is changing
            self.giveAmmo()

            self.toggleTurns()
            self.stopMovingTank()
            self.maxMovementPlayerSteps = 10
            self.playerBoostCount = 5
            self.mainSceneViewModel?.resetUIVariablesOnTurnChange()


        }
    }


    // PHYSICS // /////////////
    
    func handleTankLevelSquareCollision(tank: Tank, levelSquare: LevelSquare) {
        // Enum to represent collision sides
       
    }


    func handleTankProjectileCollision(tank: Tank, projectile: Projectile) {
        print("Tank collided with projectile")
        // Implement collision handling logic here
        tank.decreaseHealth(damage: 20);
        checkDeadCondition()
    }

    func handleLevelSquareProjectileCollision(levelSquare: LevelSquare, projectile: Projectile) {
        print("Level square collided with projectile")
        // Implement collision handling logic here
       
    }
}




//extension MainScene: SCNPhysicsContactDelegate {
//    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        // Handle physics contact beginning
//    }
//
//    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
//        // Handle physics contact update
//    }
//
//    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
//        // Handle physics contact ending
//    }
//}
