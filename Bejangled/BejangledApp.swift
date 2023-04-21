//
//  BejangledApp.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import SwiftUI

@main
struct BejangledApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                } else if newPhase == .background {
                    print("Background")
                }
            }
        }
    }
}
