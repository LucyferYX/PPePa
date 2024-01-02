//
//  PanelViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import Foundation
import FirebaseAuth

@MainActor
class PanelViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    @Published var isAdmin = false
    @Published private(set) var user: DatabaseUser? = nil

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
    
    func deleteAccount() async throws {
        try await AuthManager.shared.delete()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "hi@gmail.com"
        try await AuthManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hihello"
        try await AuthManager.shared.updatePassword(password: password)
    }
    
    @Published var errorMessage: String? = nil

    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        do {
            let tokens = try await helper.signIn()
            let authUser = try await AuthManager.shared.linkGoogle(tokens: tokens)
            self.authUser = authUser
            try await UserManager.shared.updateUserAnonymousStatusAndEmail(userId: authUser.uid, isAnonymous: authUser.isAnonymous, email: authUser.email)
        } catch let error as NSError where error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
        } catch {
            print("An error occurred: \(error.localizedDescription)")
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
    func linkEmailAccount() async throws {
        let email = "hello123@gmail.com"
        let password = "hello123"
        self.authUser = try await AuthManager.shared.linkEmail(email: email, password: password)
        try await UserManager.shared.updateUserAnonymousStatusAndEmail(userId: authUser!.uid, isAnonymous: authUser!.isAnonymous, email: authUser!.email)
    }
}
