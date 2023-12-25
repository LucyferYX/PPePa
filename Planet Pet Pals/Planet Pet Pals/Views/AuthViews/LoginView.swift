//
//  LoginView.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/12/2023.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = SignInEmailModel()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userIsLoggedIn: Bool = false
    @State private var showPassword = false
    
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
