//
//  PanelViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import Foundation
import FirebaseAuth

@MainActor
final class PanelViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthUserModel? = nil
    @Published private(set) var user: DBUserModel? = nil
    @Published var isAdmin = false
    
    @Published var showReportedPostsView = false
    @Published var showDeletedUserPostsView = false
    
    @Published var showMyPostsView = false
    @Published var showLikesView = false
    
    @Published var showProfileSettingsView = false
    @Published var showAccountSettingsView = false
    @Published var showSettingsView = false
    @Published var showAboutView = false

    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }

    func checkIfUserIsAdmin() {
        Task {
            do {
                try await loadCurrentUser()
                isAdmin = user?.isAdmin ?? false
            } catch {
                print("Failed to load current user: \(error)")
            }
        }
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func addListenerForUser() {
        guard let authDataResult = try? AuthManager.shared.getAuthenticatedUser() else { return }
        UserManager.shared.addListenerForUserProfile(userId: authDataResult.uid) { [weak self] user in
            self?.user = user
        }
    }
    
    func removeListenerForUser() {
        UserManager.shared.removeListenerForUserProfile()
    }
}
