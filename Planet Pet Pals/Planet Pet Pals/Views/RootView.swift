//
//  RootView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    @State private var showLaunchView: Bool = true
    
    var body: some View {
        ZStack {
            ZStack {
                if !showSignInView {
                    NavigationStack {
                        MainMenuView(showSignInView: $showSignInView)
                    }
                }
            }
            .onAppear {
                let authUser = try? AuthManager.shared.getAuthenticatedUser()
                self.showSignInView = authUser == nil
            }
            .fullScreenCover(isPresented: $showSignInView) {
                NavigationStack {
                    AuthView(showSignInView: $showSignInView)
                }
            }
            
            // Makes the view and animation always appear on top
            ZStack {
                if showLaunchView {
                    LaunchView(showLaunchView: $showLaunchView)
//                        .transition(.move(edge: .leading))
//                        .transition(.opacity)
                }
            }
            .zIndex(2.0)
        }
    }
}
