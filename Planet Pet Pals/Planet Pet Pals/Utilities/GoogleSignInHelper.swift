//
//  GoogleUtility.swift
//  Planet Pet Pals
//
//  Created by Liene on 05/01/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignInGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInModel {
        guard let topVC = TopViewController.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        
        let tokens = GoogleSignInModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
        return tokens
    }
}

