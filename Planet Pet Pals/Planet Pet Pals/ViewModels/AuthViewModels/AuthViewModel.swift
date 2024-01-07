//
//  AuthViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authUser: AuthUserModel? = nil
    @Published var email: String = ""
    @Published var password: String = ""
    
    // Function for signing up
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email or password not found.")
            return
        }
        
        let authDataResult = try await AuthManager.shared.createUser(email: email, password: password)
        let user = DBUserModel(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    // Function for signing in with email and password method
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email or password not found.")
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
    
    // Function for signing in with Google method
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUserModel(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    // Function for signing up anonymously
    func signInAnonymous() async throws {
        let authDataResult = try await AuthManager.shared.signInAnonymous()
        let user = DBUserModel(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}
