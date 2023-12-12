//
//  LoginView.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/12/2023.
//

import SwiftUI
import Firebase

@MainActor
class SignInEmailModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email or password not found.")
            return
        }
        
        try await AuthManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email or password not found.")
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
}

struct LoginView: View {
    @Binding var showSignInView: Bool
    //@ObservedObject var authManager = AuthManager()
    @StateObject private var viewModel = SignInEmailModel()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userIsLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                MainBackground()
                VStack {
                    Text("Login screen")
                        .frame(width: 220, height: 60)
                    
                    TextField("E-mail", text: $viewModel.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    
                    Line()
                    
                    SecureField("Password", text: $viewModel.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    
                    Line()
                    
                    ColorButton(action: {
                        print("Login pressed")
//                        login()
                    }, buttonText: "Login", color: Color.blue)
                    
//                    ColorButton(action: {
//                        print("Sign in pressed")
//                        try await viewModel.signIn()
//                    }, buttonText: "Sign in", color: Color.green)
                    Button {
                        Task {
                            do {
                                try await viewModel.signUp()
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                            
                            do {
                                try await viewModel.signIn()
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Sign in")
                            .font(.headline)
                            .frame(height: 55)
                            .background(Color.blue)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
    }
    
//    func login() {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//        }
//    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

//struct LoginPreview: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
