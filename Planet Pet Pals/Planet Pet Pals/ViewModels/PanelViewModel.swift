//
//  PanelViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import Foundation

@MainActor
class PanelViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
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
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthManager.shared.linkGoogle(tokens: tokens)
    }
    
    // needs separate screen
    func linkEmailAccount() async throws {
        let email = "hello123@gmail.com"
        let password = "hello123"
        self.authUser = try await AuthManager.shared.linkEmail(email: email, password: password)
    }
}
