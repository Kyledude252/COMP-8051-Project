//
//  SceneKitView.swift
//  Project Forefront
//
//  Created by user on 2/13/24.
//

import Foundation
import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene
    //Reference main to grab functions
    let main = MainScene()
    
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        //scnView.scene = scene
        scnView.scene = main
        
        main.scnView = scnView
        //firing code ---
        //button position
        context.coordinator.setupFireButton(on: scnView)
        context.coordinator.setupGestureRecognizers(on: scnView)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // No updates needed
    }
    
    
    //Makes coordinator, sends an instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self, mainScene: main)
    }
    //Coordinator class, needed to handle functions from MainScene
    //without coordinator functins from main scene would apply to another instance of main scene
    // which is not veiwable with the current view
    class Coordinator: NSObject {
        // Scenekit View
        var parent: SceneKitView
        // Scnview
        var mainScene: MainScene
        // button var for changing its properties
        var toggleButton: UIButton?
        //toggle boolean for fire mode on/off
        var toggleFireMode = false;
        
        init(_ parent: SceneKitView, mainScene: MainScene) {
            self.parent = parent
            self.mainScene = mainScene
        }
        
        //sets up gesture
        func setupGestureRecognizers(on view: SCNView) {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            view.addGestureRecognizer(panGesture)
        }
        //handles pan, gets location on screen (2D) and translate it to 3D
        @objc func handlePan(gesture: UIPanGestureRecognizer) {
            //set scene from MainScene
            //Does not allow gesture to handle if fire mode is not toggled
            if let scnView = gesture.view as? SCNView, let scene = scnView.scene as? MainScene, toggleFireMode {
                let location = gesture.location(in: scnView)
                // Convert the 2D touch point to a 3D point in the scene
                // The z value of this point and other points MUST match the same z plane as the tank otherwise
                // later on detetion will not trigger
                let projectedOrigin = scnView.projectPoint(SCNVector3(0, 0, 0))
                let touchPoint = scnView.unprojectPoint(SCNVector3(Float(location.x), Float(location.y), projectedOrigin.z))
                if gesture.state == .changed && toggleFireMode {
                    // calling from MainScene
                    scene.createTrajectoryLine(from: scene.player1Tank.position, to: touchPoint)
                } else if gesture.state == .ended && toggleFireMode {
                    scene.launchProjectile(from: scene.player1Tank.position, to: touchPoint)
                }
            }
        }
        
        // Creates fire button on screen view, so it remains on screen when panning
        func setupFireButton(on view: SCNView) {
            let button = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
            //button color, tittle, action
            button.backgroundColor = .blue
            button.setTitle("Move Mode", for: .normal)
            button.addTarget(self, action: #selector(toggleFire), for:.touchUpInside)
            view.addSubview(button)
            self.toggleButton = button
        }
        //swap text of UIButton,
        func fireModeText() {
            if let button = toggleButton {
                if button.title(for: .normal) == "Fire Mode" {
                    button.setTitle("Move Mode", for: .normal)
                    button.backgroundColor = .blue
                    toggleFireMode = false //toggles fire mode off
                } else if button.title(for: .normal) == "Move Mode" {
                    button.setTitle("Fire Mode", for: .normal)
                    button.backgroundColor = .red
                    toggleFireMode = true //toggles fire mode on
                }
            }
        }
        
        //Grabs function from main scene
        @objc func toggleFire() {
            fireModeText()
            //does not trigger toggle fire unless fireMode is on
            mainScene.toggleFire(isFireMode: toggleFireMode)
        }
    }
    
}

