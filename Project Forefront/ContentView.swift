//
//  ContentView.swift
//  Project Forefront
//
//  Created by Kyle Alexander on 2024-01-31.
//

import SwiftUI
import SceneKit
import SpriteKit

// THIS PAGE CONTAINS:
// CONTENT VIEW
// START SCREEN UI
// GESTURE CONFIG
// BUTTON STYLING AND CONFIG

private var moveLeft = false
private var moveRight = false
private var aimRotateLeft = false
private var aimRotateRight = false

struct ContentView: View {
    @StateObject var mainSceneViewModel = MainSceneViewModel()
    @State private var isGameStarted = false
    @State private var sliderValue: Double = 0.5
    @State private var isMovingLeft = false
    @State private var isMovingRight = false
    
    var body: some View {
        if isGameStarted {

            SceneKitView(scene: mainSceneViewModel.scene)
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
            
            HStack(spacing: 1) {
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
                    Text("Move Left").frame(maxWidth: .infinity, minHeight: 80)
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
                    Text("Move Right").frame(maxWidth: .infinity, minHeight: 80)
                }
                .buttonStyle(ButtonTap())
                
                Button(action: mainSceneViewModel.handleAimRotateLeft) {
                    Text("AimRotateLeft").frame(maxWidth: .infinity, minHeight: 80)
                }.buttonStyle(ButtonToggle(which: 2))
                
                Button(action: mainSceneViewModel.handleAimRotateRight) {
                    Text("AimRotateRight").frame(maxWidth: .infinity, minHeight: 80)
                }.buttonStyle(ButtonToggle(which: 3))
                
                VStack {
                    Text("POWER: \(sliderValue, specifier: "%.2f")")
                        .padding()
                    
                    Slider(value: $sliderValue, in: 0...1, step: 0.1)
                        .onChange(of: sliderValue) { newValue in
                            mainSceneViewModel.handleAdjustPower(powerLevel: newValue)
                        }
                }
                
                Button(action: mainSceneViewModel.handleFire) {
                    Text("Fire!").frame(maxWidth: .infinity, minHeight: 80)
                }.buttonStyle(ButtonToggle(which: 3))
                
                // Temporary button to debug damage
                Button(action: mainSceneViewModel.takeDamage) {
                    Text("Take Damage").frame(maxWidth: .infinity, minHeight: 80)
                }.buttonStyle(ButtonToggle(which: 3))
            }
            .opacity(1)
            .transition(.opacity)
        
            
        } else {
            StartScreenView {
                isGameStarted = true
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// Main menu // /////////////
//- good enough for now
// Brainstorm (perhaps):
// -- Allow player name entry
// -- Add cool art or animation
// -- See high scores
// * Add tank models from game art class

struct StartScreenView: View {
    var startAction: () -> Void
    
    @State private var isShowing = false
    
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
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                self.isShowing = true
            }
        }
    }
}

// BUTTONS // ////////////
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
                //            case 4:
                //                aimRotateRight = !aimRotateRight
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

