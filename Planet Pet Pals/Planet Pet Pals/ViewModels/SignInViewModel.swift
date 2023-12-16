//
//  SignInViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import Foundation

@MainActor
class SignInEmailModel: ObservableObject {
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
}
