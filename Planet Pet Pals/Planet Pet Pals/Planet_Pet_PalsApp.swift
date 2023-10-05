//
//  Planet_Pet_PalsApp.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

//@main
//struct Planet_Pet_PalsApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

@main
struct Planet_Pet_PalsApp: App {
    @StateObject private var loadingState = LoadingState()

    var body: some Scene {
        WindowGroup {
            Group {
                if loadingState.isLoading {
                    LoadingView()
                } else {
                    ContentView()
                }
            }
            .onAppear {
                // Simulating a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        loadingState.isLoading = false
                    }
                }
            }
            .transition(.opacity)
            .animation(.easeIn(duration: 0.3), value: loadingState.isLoading)
        }
    }
}
