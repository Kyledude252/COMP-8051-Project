//
//  GameViewController.swift
//  Project Forefront
//
//  Created by Nicky Cheng on 2024-03-30.
//

import Foundation
import SceneKit
import SwiftUI

class GameViewController: UIViewController {
    var scene: SCNScene?
    
    // Initializes view controller with scene
    init(scene: SCNScene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    // REQUIRED FOR VIEW CONTROLLER TO WORK
    @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("This class does not support NSCoder")
        }
    
    // Loads a SceneKit View
    override func loadView() {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene
        view = scnView
    }
}
