//
//  RootView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI
//import FirebaseFirestore

struct RootView: View {
    @State private var showLaunchView: Bool = true
    @State private var showSignInView: Bool = false
    @StateObject var viewModel = RootViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.showMaintenanceView {
                MaintenanceView()
            } else {
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
                    if let user = authUser {
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
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("App encountered an error"), message: Text("Please restart the app. If error persits, please contact our team!"))
        }
    }
}


class RootViewModel: ObservableObject {
    @Published var showMaintenanceView: Bool = false
    @Published var documentExists: Bool = true
    @Published var showAlert: Bool = false
    
    func checkMaintenance() async {
        do {
            let isUnderMaintenance = try await MaintenanceManager.shared.getMaintenanceFlag(docId: "1")
            DispatchQueue.main.async {
                self.showMaintenanceView = isUnderMaintenance
                print("Maintenance is set to: \(isUnderMaintenance ? "true" : "false")")
            }
        } catch {
            print("Error in checkMaintenance: \(error)")
            DispatchQueue.main.async {
                self.documentExists = false
                self.showAlert = !self.documentExists
            }
        }
    }
}

//final class MaintenanceManager {
//    static let shared = MaintenanceManager()
//    private init() {}
//    private let maintenanceCollection = Firestore.firestore().collection("Maintenance")
//
//    private func maintenanceDocument(docId: String) -> DocumentReference {
//        maintenanceCollection.document(docId)
//    }
//
//    func getMaintenanceFlag(docId: String) async throws -> Bool {
//        let document = try await maintenanceDocument(docId: docId).getDocument(source: .server)
//        let flag = document.get("flag") as? Bool ?? false
//        return flag
//    }
//}
//
