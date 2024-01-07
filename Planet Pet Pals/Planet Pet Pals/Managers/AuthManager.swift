//
//  AuthManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI
import FirebaseAuth

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    init() {}
    
    func getAuthenticatedUser() throws -> AuthUserModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthUserModel(user: user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}

// MARK: Sign in email
extension AuthManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthUserModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUserModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthUserModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUserModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
}

// MARK: Sign in SSO
extension AuthManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthUserModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthUserModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthUserModel(user: authDataResult.user)
    }
}

// MARK: Sign in anonymously
extension AuthManager {
    @discardableResult
    func signInAnonymous() async throws -> AuthUserModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthUserModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthUserModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthUserModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthUserModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        do {
            let authDataResult = try await user.link(with: credential)
            return AuthUserModel(user: authDataResult.user)
        } catch let error as NSError where error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
            print("An account already exists with the same email address but different sign-in credentials.")
            throw NSError(domain: "AuthManager", code: AuthErrorCode.accountExistsWithDifferentCredential.rawValue, userInfo: [NSLocalizedDescriptionKey: "An account already exists with the same email address but different sign-in credentials."])
        } catch {
            throw error
        }
    }
}
