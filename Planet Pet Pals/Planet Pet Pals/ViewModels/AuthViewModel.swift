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
class AuthViewModel: ObservableObject {
    @Published var authUser: AuthDataResultModel? = nil
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email or password not found.")
            return
        }
        
        let authDataResult = try await AuthManager.shared.createUser(email: email, password: password)
        let user = DatabaseUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email or password not found.")
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
        let user = DatabaseUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthManager.shared.signInAnonymous()
        let user = DatabaseUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}


// MARK: SignInGoogleHelper
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

struct SignInGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
        return tokens
    }
}
