//
//  AuthenticationView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    @State private var flipped = false
    
    @StateObject private var authManager = AuthManager.shared
    @State private var showResetPassword = false
    @State private var email = ""
    
    var body: some View {
        ZStack {
            AuthBackground(color1: Colors.orchid, color2: Colors.salmon)

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: -5) {
                    Text("welcome")
                        .foregroundColor(Colors.snow)
                        .font(.custom("Baloo2-SemiBold", size: 40))
                        
                    Text("sign in continue")
                        .foregroundColor(Colors.linen)
                        .font(.custom("Baloo2-SemiBold", size: 25))
                }
                .padding(.bottom)
                
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        // Login view
                        RoundedSquare(color: Colors.seashell)  {
                            AnyView(
                                VStack {
                                    HStack {
                                        Text("Login")
                                            .font(.custom("Baloo2-SemiBold", size: 40))
                                            .foregroundColor(Colors.gondola)
                                            .padding(.leading, 40)
                                            .padding(.top, 40)
                                        Spacer()
                                    }
                                    Spacer()
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
                                    
                                    Button(action: {
                                        self.showResetPassword = true
                                    }) {
                                        Text("Forgot password?")
                                            .foregroundColor(Colors.snow)
                                            .font(.custom("Baloo2-Regular", size: 20))
                                    }
                                    .sheet(isPresented: $showResetPassword) {
                                        ResetPasswordView(authManager: authManager, showResetPassword: $showResetPassword, email: $email)
                                    }
                                    .padding(.bottom, 20)
                                }
                            )
                        }
                        .opacity(flipped ? 0 : 1)
                        
                        // Sign up view
                        RoundedSquare(color: Colors.snow) {
                            AnyView(
                                VStack {
                                    HStack {
                                        Text("Sign up")
                                            .font(.custom("Baloo2-SemiBold", size: 40))
                                            .foregroundColor(Colors.snow)
                                            .padding(.leading, 40)
                                            .padding(.top, 40)
                                        Spacer()
                                    }
                                    Spacer()
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
                                    Text("Back").foregroundColor(.white)
                                }
                                .scaleEffect(x: -1, y: 1)
                            )
                        }
                        .opacity(flipped ? 1 : 0)
                    }
                    .rotation3DEffect(
                        .degrees(flipped ? 180 : 0),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            flipped.toggle()
                        }
                    }) {
                        Group {
                            if flipped {
                                Text("Don't have an account? ")
                                    .font(.custom("Baloo2-Regular", size: 20)) +
                                Text(" SIGN UP")
                                    .foregroundColor(Colors.salmon)
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                            } else {
                                Text("Already have an account? ")
                                    .font(.custom("Baloo2-Regular", size: 20)) +
                                Text(" LOG IN")
                                    .foregroundColor(Colors.salmon)
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                            }
                        }
                    }
                }
                .padding(.bottom)
                
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
                
                Spacer()
            }
            .padding()
        }
    }
}

struct AuthPreview: PreviewProvider {
    static var previews: some View {
        AuthView(showSignInView: .constant(false))
    }
}
