//
//  ContentView.swift
//  Project Forefront
//
//  Created by Kyle Alexander on 2024-01-31.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var mainSceneViewModel = MainSceneViewModel()
    @State private var isGameStarted = false // State to track if the game has started
    
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
            } else {
                StartScreenView {
                    isGameStarted = true
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
}

// Main menu - good enough for now
// Brainstorm (perhaps):
// -- Allow player name entry
// -- Add cool art or animation
// -- See high scores

struct StartScreenView: View {
    var startAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Project: Forefront")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(5)
                .padding()
            
            Button("Start Game") {
                print("Start Game button pressed")
                startAction()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
        }
    }
}

