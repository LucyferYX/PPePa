//
//  AuthenticationView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    func signInAnonymous() async throws {
        try await AuthManager.shared.signInAnonymous()
    }
}

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign in anonymously")
                    .padding()
                    .frame(height: 55)
                    .font(.headline)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            
            NavigationLink {
                LoginView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with email")
                    .padding()
                    .frame(height: 55)
                    .font(.headline)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Signing in")
    }
}

//struct AuthPreview: PreviewProvider {
//    static var previews: some View {
//        AuthenticationView(showSignInView: .constant(false))
//    }
//}
