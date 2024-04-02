//
//  SceneKitView.swift
//  Project Forefront
//
//  Created by user on 2/13/24.
//

import Foundation
import SwiftUI
import SceneKit

struct SceneKitView: UIViewControllerRepresentable {
    let scene: SCNScene
    let mainSceneViewModel: MainSceneViewModel

    
    func makeUIViewController(context: Context) -> GameViewController {
        let vc = GameViewController(scene: scene)
        if (scene == mainSceneViewModel.scene) {
            let main = mainSceneViewModel.scene
            main.scnView = vc.view as? SCNView
            
            //firing code ---
            //button position
            context.coordinator.setupFireButton(on: vc.view as! SCNView)
            context.coordinator.setupGestureRecognizers(on: vc.view as! SCNView)
            context.coordinator.setupPicker(on: vc.view as! SCNView)
        }
        return vc

    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // No updates needed
    }
    
    typealias UIViewControllerType = GameViewController
   
//    func makeUIView(context: Context) -> SCNView {
//        let scnView = SCNView(frame: .zero)
//        //scnView.scene = scene
//        scnView.scene = scene
//        
//        let main = mainSceneViewModel.scene
//         main.scnView = scnView
//        //firing code ---
//        //button position
//        context.coordinator.setupFireButton(on: scnView)
//        context.coordinator.setupGestureRecognizers(on: scnView)
//        
//        return scnView
//    }
//    
//    func updateUIView(_ scnView: SCNView, context: Context) {
//        // No updates needed
//    }
//    
    
    //Makes coordinator, sends an instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self, mainScene: mainSceneViewModel.scene)
    }
    //Coordinator class, needed to handle functions from MainScene
    //without coordinator functins from main scene would apply to another instance of main scene
    // which is not veiwable with the current view
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        
        // Scenekit View
        var parent: SceneKitView
        // Scnview
        var mainScene: MainScene
        // button var for changing its properties
        var toggleButton: UIButton?
        //toggle boolean for fire mode on/off
        var fireModeOn = false;
        // used for self reference to figure out who's turn it is
        var playerTurn: Int = 1
        // shot type used to alter launch projectile
        var shotType = 1
        // array with shot types
        let shotTypes = ["Lob","Laser", "Triple", "Царь-бомба"]
        
        init(_ parent: SceneKitView, mainScene: MainScene) {
            self.parent = parent
            self.mainScene = mainScene
            //Put this bad boy here to trigger as soon as MainScene is rendered, kind of bandaid fix honestly
            mainScene.toggleTurns()
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
            if let scnView = gesture.view as? SCNView, let scene = scnView.scene as? MainScene, fireModeOn {
                let location = gesture.location(in: scnView)
                // Convert the 2D touch point to a 3D point in the scene
                // The z value of this point and other points MUST match the same z plane as the tank otherwise
                // later on detetion will not trigger
                let projectedOrigin = scnView.projectPoint(SCNVector3(0, 0, 0))
                let touchPoint = scnView.unprojectPoint(SCNVector3(Float(location.x), Float(location.y), projectedOrigin.z))
                if gesture.state == .changed && fireModeOn {
                    // calling from MainScene
                    scene.createTrajectoryLine(from: scene.getTankPosition()!, to: touchPoint)
                    
                } else if gesture.state == .ended && fireModeOn {
                    // Carry on variable here
                    scene.launchProjectile(from: scene.getTankPosition()!, to: touchPoint, type: shotType)

                }
            }
        }
        
        func setupPicker(on view: SCNView) {
            let pickerView = UIPickerView(frame: CGRect(x: 20, y: 70, width: 100, height: 100))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.backgroundColor = .green
            view.addSubview(pickerView)
            
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 4
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return shotTypes[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            shotType = row + 1
            print("shot type: ", shotType)
        }
        

        
        // Creates fire button on screen view, so it remains on screen when panning
        func setupFireButton(on view: SCNView) {
            let button = UIButton(frame: CGRect(x: 20, y: 20, width: 100, height: 50))
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
                    //toggles fire mode off
                    fireModeOn = false
                    //removes line drawn, another safeguard to remove this artifact
                    mainScene.removeLine()
                    //toggle tank movement back on
                    mainScene.toggleTankMove(move: true)
                } else if button.title(for: .normal) == "Move Mode" {
                    button.setTitle("Fire Mode", for: .normal)
                    button.backgroundColor = .red
                    fireModeOn = true //toggles fire mode on
                    mainScene.toggleTankMove(move: false)
                }
            }
        }
        
        //Grabs function from main scene
        @objc func toggleFire() {
            fireModeText()
            //does not trigger toggle fire unless fireMode is on
            mainScene.toggleFire(isFireMode: fireModeOn)
        }
        // doesn't need to be used
        @objc func disableFireButton() {
            toggleButton?.isEnabled = false
        }
    }
    
}

