//
//  AuthenticationView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var authManager = AuthManager.shared
    
    @Binding var showSignInView: Bool
    @State private var showResetPasswordView = false
    
    @State private var userIsLoggedIn: Bool = false
    @State private var showPassword = false
    @State private var flipped = false
    @State private var showAlert = false
    
    @State private var alertMessage = "alert"
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            AuthBackground(color1: Color("Orchid"), color2: Color("Salmon"))

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: -5) {
                    Text("welcome")
                        .foregroundColor(Color("Snow"))
                        .font(.custom("Baloo2-SemiBold", size: 40))
                        
                    Text("sign in continue")
                        .foregroundColor(Color("Linen"))
                        .font(.custom("Baloo2-SemiBold", size: 25))
                }
                .padding(.bottom)
                
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        // MARK: Login view
                        RoundedSquare(color: Color("Seashell")) {
                            AnyView(
                                VStack {
                                    HStack {
                                        AuthText(text: "Login")
                                        Spacer()
                                    }
                                    
                                    SignTextField(placeholder: "Email", text: $viewModel.email)
                                    
                                    Line3()
                                        .padding(.bottom)
                                    
                                    if showPassword {
                                        SignTextField(placeholder: "Password", text: $viewModel.password)
                                    } else {
                                        SignSecureField(placeholder: "Password", text: $viewModel.password)
                                    }
                                    
                                    Line3()
                                    
                                    ShowPasswordButton()
                                    
                                    LoginButton()
                                    
                                    Rectangle()
                                        .fill(Color("Snow"))
                                        .frame(height: 2)
                                        .padding(.top)
                                    
                                    GoogleButton()
                                        .padding(.vertical)
                                                                        
                                    LabelButton(action: {
                                        self.showResetPasswordView = true
                                    }, title: "forgot password", color: Color("Gondola"), fontSize: 18)
                                    .sheet(isPresented: $showResetPasswordView) {
                                        ResetPasswordView(authManager: authManager, email: $email)
                                    }
                                    .padding(.bottom, 20)
                                }
                            )
                        }
                        .opacity(flipped ? 0 : 1)
                        
                        // MARK: Sign up view
                        RoundedSquare(color: Color("Seashell")) {
                            AnyView(
                                VStack {
                                    HStack {
                                        AuthText(text: "Sign up")
                                        Spacer()
                                    }
                                                                        
                                    SignTextField(placeholder: "Email", text: $viewModel.email)
                                    
                                    Line3()
                                        .padding(.bottom)
                                    
                                    if showPassword {
                                        SignTextField(placeholder: "Password", text: $viewModel.password)
                                    } else {
                                        SignSecureField(placeholder: "Password", text: $viewModel.password)
                                    }
                                    
                                    Line3()
                                    
                                    ShowPasswordButton()
                                    
                                    SignUpButton()

                                    Rectangle()
                                        .fill(Color("Snow"))
                                        .frame(height: 2)
                                        .padding(.vertical)
                                    
                                    GoogleButton()
                                    
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
                                        VStack(spacing: 0) {
                                            Text("Continue as guest?")
                                                .font(.custom("Baloo2-SemiBold", size: 18))
                                                .font(.headline)
                                                .foregroundColor(Color("Gondola"))
                                            Text("Account can be binded later")
                                                .font(.custom("Baloo2-Regular", size: 15))
                                                .lineSpacing(0)
                                                .opacity(0.6)
                                        }
                                        .padding(.leading)
                                        .padding(.trailing)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.linearGradient(colors: [Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                                                .opacity(0.3)
                                        )
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.leading)
                                        .padding(.trailing)
                                    })
                                    .padding(.bottom, 30)
                                    .padding(.top, 20)
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
                    
                    FlipTextButton()
                        .padding(.top)
                }
                .padding(.bottom)
                
                Spacer()
            }
            .padding()
        }
    }
}


// MARK: Enum
enum LoginError: LocalizedError {
    case emptyEmail
    case emptyPassword
    case invalidEmail
    case emailNotFound
    case wrongPassword
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please enter an email."
        case .emptyPassword:
            return "Please enter a password."
        case .invalidEmail:
            return "Please input a valid email."
        case .emailNotFound:
            return "No such email address found."
        case .wrongPassword:
            return "Incorrect password."
        }
    }
}

enum SignUpError: LocalizedError {
    case emptyEmail
    case emptyPassword
    case invalidEmail
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please enter an email."
        case .emptyPassword:
            return "Please enter a password."
        case .invalidEmail:
            return "Please input a valid email."
        }
    }
}


// MARK: Extension
extension AuthView {
    func GoogleButton() -> some View {
        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
            Task {
                do {
                    try await viewModel.signInGoogle()
                    showSignInView = false
                } catch {
                    print(error)
                }
            }
        }
        .padding(.leading, 60)
        .padding(.trailing, 60)
    }
    
    func LoginButton() -> some View {
        Button(action: {
            Task {
                do {
                    guard !viewModel.email.isEmpty else {
                        throw LoginError.emptyEmail
                    }
                    guard !viewModel.password.isEmpty else {
                        throw LoginError.emptyPassword
                    }
                    guard viewModel.email.contains("@") else {
                        throw LoginError.invalidEmail
                    }
                    let methods = try await Auth.auth().fetchSignInMethods(forEmail: viewModel.email)
                    guard !(methods.isEmpty) else {
                        throw LoginError.emailNotFound
                    }
                    try await viewModel.signIn()
                    print("Logged in succesfully.")
                    showSignInView = false
                } catch let error as LoginError {
                    print("Failed to log in: \(error)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                } catch {
                    print("Unexpected error: \(error)")
                    alertMessage = "Email or password do not match."
                    showAlert = true
                }
            }
        }) {
            Text("Login")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .font(.headline)
                .frame(width: 100, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                )
                .foregroundColor(Color("Gondola"))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func SignUpButton() -> some View {
        Button(action: {
            Task {
                do {
                    guard !viewModel.email.isEmpty else {
                        throw SignUpError.emptyEmail
                    }
                    guard !viewModel.password.isEmpty else {
                        throw SignUpError.emptyPassword
                    }
                    guard viewModel.email.contains("@") else {
                        throw SignUpError.invalidEmail
                    }
                    try await viewModel.signUp()
                    print("Signed up succesfully.")
                    showSignInView = false
                } catch let error as LoginError {
                    print("Failed to sign up: \(error)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                } catch {
                    print("Unexpected error: \(error)")
                    alertMessage = "Encountered unknown issue."
                    showAlert = true
                }
            }
        }) {
            Text("Sign up")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .font(.headline)
                .frame(width: 100, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                )
                .foregroundColor(Color("Gondola"))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func ShowPasswordButton() -> some View {
        Button(action: {
            showPassword.toggle()
        }) {
            HStack {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                Text(showPassword ? "Hide Password" : "Show Password")
                    .font(.custom("Baloo2-Regular", size: 15))
            }
        }
    }
    
    func FlipTextButton() -> some View {
        Button(action: {
            withAnimation(.spring()) {
                flipped.toggle()
            }
        }) {
            Group {
                if !flipped {
                    Text("Don't have an account? ")
                        .foregroundColor(Color("Salmon"))
                        .font(.custom("Baloo2-Regular", size: 20)) +
                    Text(" SIGN UP")
                        .foregroundColor(Color("Salmon"))
                        .font(.custom("Baloo2-SemiBold", size: 20))
                } else {
                    Text("Already have an account? ")
                        .foregroundColor(Color("Salmon"))
                        .font(.custom("Baloo2-Regular", size: 20)) +
                    Text(" LOG IN")
                        .foregroundColor(Color("Salmon"))
                        .font(.custom("Baloo2-SemiBold", size: 20))
                }
            }
        }
    }
}

