import SwiftUI
import SceneKit
import SpriteKit


private var moveLeft = false
private var moveRight = false
private var aimRotateLeft = false
private var aimRotateRight = false


/**
 Struct containing the structure of the views for the app.
 
 ContentView inherits from View.
 */
struct ContentView: View {
    @StateObject var mainSceneViewModel = MainSceneViewModel()
    @StateObject var statsSceneViewModel = StatsSceneViewModel()
    @State private var isGameStarted = false
    @State private var statsScreenOpen = false
    @State private var sliderValue: Double = 0.5
    @State private var isMovingLeft = false
    @State private var isMovingRight = false

    @State private var totalBoosts = 5
    @State private var totalMovement = 10


    
    var body: some View {
        
        if isGameStarted {
            SceneKitView(scene: mainSceneViewModel.scene, mainSceneViewModel: mainSceneViewModel)
                .gesture(DragGesture().onChanged { value in
                    let sensitivity: Float = 0.01 // Adjust the sensitivity of the drag
                    let cameraXOffset = Float(value.translation.width) * sensitivity
                    let cameraYOffset = -Float(value.translation.height) * sensitivity
                    
                    mainSceneViewModel.scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraYOffset)
                })
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    mainSceneViewModel.scene.toggleGameStarted = {
                        // reset - don't return
                        
                        mainSceneViewModel.resetScene()
                        isGameStarted = false
                        isMovingLeft = false
                        isMovingRight = false
                        sliderValue = 0.5
                        
                    }
                    
                }
            
            HStack(spacing:1) {
                Button(action: {
                    if (!isMovingLeft) {
                        if (isMovingRight){
                            isMovingRight = false
                            mainSceneViewModel.stopMoving()
                        }
                        mainSceneViewModel.moveTankLeft()
                        isMovingLeft = true
                        
                        Timer.scheduledTimer(withTimeInterval: 0.00001, repeats: false) { _ in
                            isMovingLeft = false
                        }
                    }
                }) {
                    Text("Move Left").frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(ButtonTap())
                
                Button(action: {
                    if (!isMovingRight) {
                        if (isMovingLeft){
                            isMovingLeft = false
                            mainSceneViewModel.stopMoving()
                        }
                        mainSceneViewModel.moveTankRight()
                        isMovingRight = true
                        
                        // Reset flag - releasing button won't work
                        Timer.scheduledTimer(withTimeInterval: 0.00001, repeats: false) { _ in
                            isMovingRight = false
                        }
                    }
                }) {
                    Text("Move Right").frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(ButtonTap())
                
                Spacer(minLength: 5)
                
                HStack(spacing: 5) {
                    ForEach(0..<2, id: \.self) { row in
                        VStack(spacing: 2) {
                            ForEach((0..<5).reversed(), id: \.self) { column in
                                let index = row * 5 + column
                                Circle()
                                    .fill(index < mainSceneViewModel.playerMovementCount ? Color.green : Color.red)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                }
 
                Spacer(minLength: 200)
                
                VStack(spacing: 2) {
                    ForEach((0..<totalBoosts).reversed(), id: \.self) { index in
                        Circle()
                            .fill(index < mainSceneViewModel.playerBoostCount ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                    }
                }
                
                Spacer(minLength: 5)

                Button(action: mainSceneViewModel.rocketBoost) {
                    Text("Rocket\nBoost").frame(maxWidth: .infinity, minHeight: 60)
                }.buttonStyle(ButtonTap())
                
                Button(action: mainSceneViewModel.endTurn) {
                    Text("End Turn").frame(maxWidth: .infinity, minHeight: 60)
                }.buttonStyle(ButtonTap())
            }

            .opacity(1)
            .transition(.opacity)
        } else if (statsScreenOpen) {
            SceneKitView(scene: statsSceneViewModel.scene, mainSceneViewModel: mainSceneViewModel)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Button(action: {
                statsScreenOpen = false
            }) {
                Text("Back to Main Menu")
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .padding()
            .edgesIgnoringSafeArea(.all)
        } else {
            StartScreenView(startAction: {
                isGameStarted = true
                //yolo start toggling
                mainSceneViewModel.scene.toggleTurns()
                
                mainSceneViewModel.scene.setupAudio()
            }, statsAction: {
                statsSceneViewModel.updateStats()
                statsScreenOpen = true
            })
            .edgesIgnoringSafeArea(.all)
        }
    }
}


/**
 A struct containing the structure of the main menu.
 */
struct StartScreenView: View {
    var startAction: () -> Void
    var statsAction: () -> Void
    
    @State private var isShowing = false
    @StateObject private var statsSceneViewModel = StatsSceneViewModel()
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Project: Forefront")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .opacity(isShowing ? 1 : 0)
                    .animation(.easeInOut(duration: 3))
                Button("Start Game") {
                    print("Start Game button pressed")
                    startAction()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .padding()
                .opacity(isShowing ? 1 : 0)
                .animation(.easeInOut(duration: 5))
                
                Button("Show Stats") {
                    statsAction()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .padding()
                .opacity(isShowing ? 1: 0)
                .animation(.easeInOut(duration: 5))
                
                Spacer()
            }
        }
        .onAppear {
            if (UserDefaults.standard.value(forKey: "Player1Wins") == nil) {
                UserDefaults.standard.set(0, forKey: "Player1Wins")
            }
            if (UserDefaults.standard.value(forKey: "Player2Wins") == nil) {
                UserDefaults.standard.set(0, forKey: "Player2Wins")
            }
            withAnimation {
                self.isShowing = true
            }
        }
    }
}


/**
 Struct for styling the tap buttons.
 
 ButtonTap inherits from ButtonStyle.
 */
struct ButtonTap: ButtonStyle {
    typealias Body = Button
    
    func makeBody(configuration: Self.Configuration)
    -> some View {
        if configuration.isPressed {
            return configuration
                .label
                .background(Color(red: 0.35, green: 0.35, blue: 0.55))
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            return configuration
                .label
                .background(Color(red: 0.25, green: 0.25, blue: 0.45))
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}


/**
 Struct for styling the toggle button.
 
 ButtonToggle inherits from ButtonStyle.
 */
struct ButtonToggle: ButtonStyle {
    @State var which: Int
    typealias Body = Button
    
    func makeBody(configuration: Self.Configuration) -> some View {
        if configuration.isPressed {
            switch which {
            case 1:
                moveLeft = !moveLeft
            case 2:
                moveRight = !moveRight
            case 3:
                aimRotateLeft = !aimRotateLeft
            default:
                aimRotateRight = !aimRotateRight
            }
        }
        switch which {
        case 1:
            if moveLeft {
                return configuration
                    .label
                    .background(Color(red: 0.35, green: 0.35, blue: 0.55))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                return configuration
                    .label
                    .background(Color(red: 0.25, green: 0.25, blue: 0.45))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        case 2:
            if moveRight {
                return configuration
                    .label
                    .background(Color(red: 0.35, green: 0.35, blue: 0.55))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                return configuration
                    .label
                    .background(Color(red: 0.25, green: 0.25, blue: 0.45))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        case 3:
            if aimRotateLeft {
                return configuration
                    .label
                    .background(Color(red: 0.35, green: 0.35, blue: 0.55))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                return configuration
                    .label
                    .background(Color(red: 0.25, green: 0.25, blue: 0.45))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        default:
            if aimRotateRight {
                return configuration
                    .label
                    .background(Color(red: 0.35, green: 0.35, blue: 0.55))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                return configuration
                    .label
                    .background(Color(red: 0.25, green: 0.25, blue: 0.45))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
