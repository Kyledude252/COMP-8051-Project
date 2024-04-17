import Foundation
import SwiftUI
import SceneKit


/**
 Struct containing a scene and a MainSceneViewModel.
 
 SceneKitView inherits from UIViewControllerRepresentable.
 */
struct SceneKitView: UIViewControllerRepresentable {
    let scene: SCNScene
    let mainSceneViewModel: MainSceneViewModel

    
    /**
     Function for making a UIViewController.
     
     - parameter context: the Context of the app.
     - returns: a GameViewController.
     */
    func makeUIViewController(context: Context) -> GameViewController {
        let vc = GameViewController(scene: scene)
        if (scene == mainSceneViewModel.scene) {
            let main = mainSceneViewModel.scene
            main.scnView = vc.view as? SCNView
            
            //firing code ---
            //button position
            //context.coordinator.setupFireButton(on: vc.view as! SCNView)
            context.coordinator.setupGestureRecognizers(on: vc.view as! SCNView)
            context.coordinator.setupPicker(on: vc.view as! SCNView)
            context.coordinator.setupPause(on: vc.view as! SCNView)
            context.coordinator.createPause(on: vc.view as! SCNView)
        }
        return vc
    }
    
    
    /**
     Function for updating the UIViewController.
     
     - parameter uiViewController: a GameViewController for the app.
     - parameter context: the Context object for the UI/game.
     
     This function is necessary but unused.
     */
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // No updates needed
    }
    
    typealias UIViewControllerType = GameViewController
   
    
    /**
     Function that makes an instance of a Coordinator for the scene.
     
     - returns: the Coordinator of the scene.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self, mainScene: mainSceneViewModel.scene)
    }
    
    
    /**
     Class representing a Coordinator.
     
     Coordinator inherits from NSObject, UIPickerViewDelegate, UIPickerViewDataSource.
     
     The coordinator is needed to handle certain functions in the main scene. Without it, the functions may apply to the wrong view.
     */
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
        
        
        /**
         Function for setting up the pan gesture.
         
         - parameter view: the view in which to create the gesture.
         
         Called by:
         
         SceneKitView.makeUIViewController()
         */
        func setupGestureRecognizers(on view: SCNView) {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            view.addGestureRecognizer(panGesture)
        }
        
        
        /**
         Function for handling the pan gesture for aiming and firing the weapons.
         
         - parameter gesture: a UIPanGestureRecognizer that returns the actual gesture data.
         */
        @objc func handlePan(gesture: UIPanGestureRecognizer) {
            //set scene from MainScene
            //Does not allow gesture to handle if fire mode is not toggled
            if let scnView = gesture.view as? SCNView, let scene = scnView.scene as? MainScene/*, fireModeOn*/ {
                let location = gesture.location(in: scnView)
                // Convert the 2D touch point to a 3D point in the scene
                // The z value of this point and other points MUST match the same z plane as the tank otherwise
                // later on detetion will not trigger
                let projectedOrigin = scnView.projectPoint(SCNVector3(0, 0, 0))
                let touchPoint = scnView.unprojectPoint(SCNVector3(Float(location.x), Float(location.y), projectedOrigin.z))
                if gesture.state == .changed /*&& fireModeOn*/ {
                    // calling from MainScene
                    scene.createTrajectoryLine(from: scene.getTankPosition()!, to: touchPoint)
                    
                } else if gesture.state == .ended /*&& fireModeOn*/ {
                    // Carry on variable here
                    scene.launchProjectile(from: scene.getTankPosition()!, to: touchPoint, type: shotType)

                }
            }
        }
        
        
        /**
         Function for setting up a picker view for the weapon select.
         
         - parameter view: the view in which to create the UIPickerView
         
         Called by:
         
         SceneKitView.makeUIViewController()
         */
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
        
        
        /**
         Function for returning the number of components in a PickerView.
         
         - parameter pickerView: pickerview to ask for number of components in.
         - returns: 1, as this is a static PickerView with 1 component.
         */
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        
        /**
         Asks the data source for the number of rows for a specified component.
         
         - parameter pickerView: UIPickerView to ask.
         - parameter component: component to ask the number of rows for.
         - returns: 3, as this is a static UIPickerView with 1 component and 3 rows.
         */
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 3
        }
        
        
        /**
         Function that returns the String in the pickerview for a specific component and specific row.
         
         - parameter pickerView: UIPickerView to ask.
         - parameter row: Int representing a row in the component.
         - parameter component: Int representing a component in the UIPickerView
         - returns: the string in the requested row of the asked component.
         */
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return shotTypes[row]
        }
        
        
        /**
         Function that prints the selected row of a component's item, formatted to display weapon type.
         
         - parameter pickerView: UIPickerView to ask.
         - parameter row: Int representing a row in the component.
         - parameter component: Int representing a component in the UIPickerView
         */
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            shotType = row + 1
            print("shot type: ", shotType)
        }
        
        
        /**
         Function for setting up the pause button.
         
         - parameter view: the view in which to create the pause menu.
         
         Called by:
         
         SceneKitView.makeUIViewController()
         */
        func setupPause(on view: SCNView) {
            let button = UIButton(frame: CGRect(x: 20, y: 20, width: 100, height: 50))
            //button color, tittle, action
            button.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.45, alpha: 1.0)
            button.layer.cornerRadius = 10
            button.setTitle("Pause", for: .normal)
            button.addTarget(self, action: #selector(pauseGame), for:.touchUpInside)
            view.addSubview(button)
            pauseButton = button
        }
        

        /**
         Function for handling pausing the game.
         */
        @objc func pauseGame() {
            print("Pause woohooo")
            mainScene.pauseTriggered()
            disableButtons()
            returnButton?.isHidden = false
            closeButton?.isHidden = false
            mainScene.isPaused = true
        }
        
        
        /**
         Function for creating the pause menu.
         
         - parameter view: the view in which to create the pause menu.
         
         Called by:
         
         SceneKitView.makeUIViewController()
         */
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
        
        
        /**
         Function to handle unpausing of the game.
         
         Called by:
         
         SceneKitView.Coordinator.returnToMain()
         */
        @objc func unPause() {
            returnButton?.isHidden = true
            closeButton?.isHidden = true
            enableButtons()
            mainScene.returnFromMenu()
            mainScene.isPaused = false
        }
        
        
        /**
         Function to handle disabling control of the buttons.
         
         Called by:
         
         SceneKitView.Coordinator.pauseGame()
         */
        @objc func disableButtons() {
            toggleButton?.isEnabled = false
            weapons?.isUserInteractionEnabled = false
            pauseButton?.isEnabled = false
        }
        
        
        /**
         Function to handle enabling control of the buttons.
         
         Called by:
         
         SceneKitView.Coordinator.upPause()
         */
        @objc func enableButtons() {
            toggleButton?.isEnabled = true
            weapons?.isUserInteractionEnabled = true
            pauseButton?.isEnabled = true
        }
        
        
        /**
         Function to handle returning to the main menu from the pause screen.
         */
        @objc func returnToMain() {
            unPause()
            mainScene.resetToStartScreen()
        }
    }
    
}

