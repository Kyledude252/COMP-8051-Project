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
            context.coordinator.setupPause(on: vc.view as! SCNView)
            context.coordinator.createPause(on: vc.view as! SCNView)
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
        // picker view
        var weapons: UIPickerView?
        // button to return to main
        var returnButton: UIButton?
        // button to close menu
        var closeButton: UIButton?
        // button to induce pause
        var pauseButton: UIButton?
        //toggle boolean for fire mode on/off
        var fireModeOn = false;
        // used for self reference to figure out who's turn it is
        var playerTurn: Int = 1
        // shot type used to alter launch projectile
        var shotType = 1
        // array with shot types
        let shotTypes = ["Lob","Laser", "Triple"]
        
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
            let pickerView = UIPickerView(frame: CGRect(x: 20, y: 75, width: 100, height: 60))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.backgroundColor = UIColor(red: 0.30, green: 0.50, blue: 0.30, alpha: 1.0)
            pickerView.tintColor = UIColor.white
            pickerView.layer.cornerRadius = 10
            view.addSubview(pickerView)
            weapons = pickerView
            
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 3
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return shotTypes[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            shotType = row + 1
            print("shot type: ", shotType)
        }
        
        func setupPause(on view: SCNView) {
            let button = UIButton(frame: CGRect(x: 125, y: 20, width: 100, height: 50))
            //button color, tittle, action
            button.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.45, alpha: 1.0)
            button.layer.cornerRadius = 10
            button.setTitle("Pause", for: .normal)
            button.addTarget(self, action: #selector(pauseGame), for:.touchUpInside)
            view.addSubview(button)
            pauseButton = button
        }
        
        // Creates fire button on screen view, so it remains on screen when panning
        func setupFireButton(on view: SCNView) {
            let button = UIButton(frame: CGRect(x: 20, y: 20, width: 100, height: 50))
            //button color, tittle, action
            button.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.65, alpha: 1.0)
            button.layer.cornerRadius = 10
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
                    button.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.65, alpha: 1.0)
                    //toggles fire mode off
                    fireModeOn = false
                    //removes line drawn, another safeguard to remove this artifact
                    mainScene.removeLine()
                    //toggle tank movement back on
                    mainScene.toggleTankMove(move: true)
                } else if button.title(for: .normal) == "Move Mode" {
                    button.setTitle("Fire Mode", for: .normal)
                    button.backgroundColor = UIColor(red: 0.65, green: 0.20, blue: 0.20, alpha: 1.0)
                    fireModeOn = true //toggles fire mode on
                    mainScene.toggleTankMove(move: false)
                }
            }
        }
        // called when pause is pressed
        @objc func pauseGame() {
            print("Pause woohooo")
            mainScene.pauseTriggered()
            disableButtons()
            returnButton?.isHidden = false
            closeButton?.isHidden = false
            mainScene.isPaused = true
        }
        // buttons for pause menu
        @objc func createPause(on view: SCNView) {
            // Return to main
            let button1 = UIButton(frame: CGRect(x: 350, y: 100, width: 150, height: 50))
            //button color, tittle, action
            button1.backgroundColor = .red
            button1.setTitle("Return to Main", for: .normal)
            button1.addTarget(self, action: #selector(returnToMain), for:.touchUpInside)
            view.addSubview(button1)
            returnButton = button1
            returnButton?.isHidden = true
            // Exit
            let button2 = UIButton(frame: CGRect(x: 350, y: 150, width: 150, height: 50))
            //button color, tittle, action
            button2.backgroundColor = .blue
            button2.setTitle("Close Menu", for: .normal)
            button2.addTarget(self, action: #selector(unPause), for:.touchUpInside)
            view.addSubview(button2)
            closeButton = button2
            closeButton?.isHidden = true
        }
        
        @objc func unPause() {
            returnButton?.isHidden = true
            closeButton?.isHidden = true
            enableButtons()
            mainScene.returnFromMenu()
            mainScene.isPaused = false
        }
        
        //Grabs function from main scene
        @objc func toggleFire() {
            fireModeText()
            //does not trigger toggle fire unless fireMode is on
            mainScene.toggleFire(isFireMode: fireModeOn)
        }
        // doesn't need to be used
        @objc func disableButtons() {
            toggleButton?.isEnabled = false
            weapons?.isUserInteractionEnabled = false
            pauseButton?.isEnabled = false
        }
        
        @objc func enableButtons() {
            toggleButton?.isEnabled = true
            weapons?.isUserInteractionEnabled = true
            pauseButton?.isEnabled = true
        }
        
        @objc func returnToMain() {
            unPause()
            mainScene.resetToStartScreen()
        }
    }
    
}

