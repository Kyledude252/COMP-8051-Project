import Foundation
import SceneKit
import SwiftUI


/**
 Class representing a GameViewController.
 
 GameViewController inherits from UIViewController.
 */
class GameViewController: UIViewController {
    var scene: SCNScene?
    

    /**
     Constructor for the GameViewController.
     
     - parameter scene: the scene to initialize.
     */
    init(scene: SCNScene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    
    /**
     NSCoding Initializer - Unused
     
     - parameter coder: NSCoder used for serialization of the class.
     
     Required.
     */
    @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("This class does not support NSCoder")
        }
    
    
    /**
     Function for loading an SCNView of the GameViewController scene.
     */
    override func loadView() {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene
        view = scnView
    }
}
