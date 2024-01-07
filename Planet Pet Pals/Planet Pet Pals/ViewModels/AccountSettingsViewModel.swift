//
//  AccountSettingsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class AccountSettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    @Published var errorMessage: String? = nil
    @Published var showDeleteErrorAlert: Bool = false
    @Published var showPasswordAlert: Bool = false
    @Published var currentAlert: AlertType? = nil
    @Published var showGoogleAlert = false
    
    @Published var email: String = ""
    @Published var password: String = ""
    
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
        do {
            let userId = Auth.auth().currentUser?.uid
            try await PostManager.shared.updatePostsForDeletedUser(userId: userId)
            try await AuthManager.shared.delete()
        } catch {
            print("Error: \(error)")
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
            self.currentAlert = .deleteError
        }
    }
    
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthManager.shared.resetPassword(email: email)
    }

    func updateEmail() async throws {
        try await AuthManager.shared.updateEmail(email: self.email)
    }

    func updatePassword() async throws {
        if self.password.count < 6 {
            self.errorMessage = "Password must be at least 6 characters long."
            self.showPasswordAlert = true
        } else {
            try await AuthManager.shared.updatePassword(password: self.password)
        }
    }
    
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
            self.showGoogleAlert = true
        } catch {
            print("An error occurred: \(error.localizedDescription)")
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
            self.showGoogleAlert = true
        }
    }

    
    func linkEmailAccount() async throws {
        guard !email.isEmpty else {
            throw LinkEmailError.emptyEmail
        }
        guard !password.isEmpty else {
            throw LinkEmailError.emptyPassword
        }
        guard email.contains("@"),
              let domain = email.split(separator: "@").last,
              domain.contains("."),
              domain.split(separator: ".").count > 1 else {
            throw LinkEmailError.invalidEmail
        }
        guard password.count >= 6 else {
            throw LinkEmailError.passwordTooShort
        }
        let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
        guard methods.isEmpty else {
            throw LinkEmailError.emailAlreadyExists
        }
        self.authUser = try await AuthManager.shared.linkEmail(email: self.email, password: self.password)
        try await UserManager.shared.updateUserAnonymousStatusAndEmail(userId: authUser!.uid, isAnonymous: authUser!.isAnonymous, email: authUser!.email)
    }
}
