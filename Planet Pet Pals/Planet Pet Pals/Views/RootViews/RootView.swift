//
//  RootView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI

// Root view of the app
struct RootView: View {
    @State private var showLaunchView: Bool = true
    @State private var showSignInView: Bool = false
    @StateObject var viewModel = RootViewModel()
    
    var body: some View {
        ZStack {
            // Shows maintenance view if maintenance is enabled
            if viewModel.showMaintenanceView {
                MaintenanceView()
            } else {
                ZStack {
                    // Shows main menu view if user is already authenticated
                    if !showSignInView {
                        NavigationStack {
                            MainMenuView(showSignInView: $showSignInView)
                        }
                    }
                }
                // Handles navigation and Firebase authentication
                .onAppear {
                    let authUser = try? AuthManager.shared.getAuthenticatedUser()
                    self.showSignInView = authUser == nil
                    if let user = authUser {
                        // Handles the data sent to Crashlytics if app crashes
                        CrashlyticsManager.shared.setUserId(userId: user.uid)
                        CrashlyticsManager.shared.setValue(value: user.email ?? "User has no email", key: "email")
                    } else {
                        CrashlyticsManager.shared.setUserId(userId: "User not authenticated")
                    }
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
                    }
                }
                .zIndex(2.0)
            }
        }
        .onAppear {
            Task.init {
                await viewModel.checkMaintenance()
            }
        }
        // If anything goes wrong in root view, user is shown an alert to restart the app (ERR01)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("App encountered an error"), message: Text("Please restart the app. If error persits, please contact our team!"))
        }
    }
}
