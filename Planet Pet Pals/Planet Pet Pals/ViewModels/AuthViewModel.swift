//
//  AuthViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import Foundation

@MainActor
class AuthenticationViewModel: ObservableObject {
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthManager.shared.signInAnonymous()
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
}
