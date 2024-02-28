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
    let main: MainScene
    
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        //scnView.scene = scene
        scnView.scene = main
        //firing code ---
        //button position
        context.coordinator.setupFireButton(on: scnView)
    
                
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
                } else if button.title(for: .normal) == "Move Mode" {
                    button.setTitle("Fire Mode", for: .normal)
                    button.backgroundColor = .red
                }
            }
        }
        //Grabs function from main scene
        @objc func toggleFire() {
            fireModeText()
            mainScene.toggleFire()
        }
    }
    
}
//struct SceneKitView: UIViewRepresentable {
//    func makeUIView(context: Context) -> SCNView {
//        let sceneView = SCNView()
//
//        let scene = SCNScene(named: "MainScene.scn")!
//        sceneView.scene = scene
//
//        return sceneView
//    }
//
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // Update your SceneKit view if needed
//    }
//}
