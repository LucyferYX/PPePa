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
        ScrollView {
            ZStack {
                // Background design
                AuthBackground(color1: Color("Orchid"), color2: Color("Salmon"))
                
                // Welcoming user text
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: -5) {
                        Text("Welcome")
                            .foregroundColor(Color("Snow"))
                            .font(.custom("Baloo2-SemiBold", size: 40))
                        
                        Text("Sign in continue")
                            .foregroundColor(Color("Linen"))
                            .font(.custom("Baloo2-SemiBold", size: 25))
                    }
                    .padding(.bottom)
                    
                    
                    VStack {
                        Spacer()
                        
                        ZStack {
                            // MARK: Login view
                            RoundedSquare(color: Color("Seashell"), width: 300, height: 550) {
                                AnyView(
                                    VStack {
                                        HStack {
                                            AuthText(text: "Login")
                                            Spacer()
                                        }
                                        
                                        // Email input field
                                        SignTextField(placeholder: "Email", text: $viewModel.email)
                                        
                                        Line3()
                                            .padding(.bottom)
                                        
                                        // Password input field
                                        if showPassword {
                                            SignTextField(placeholder: "Password", text: $viewModel.password)
                                        } else {
                                            SignSecureField(placeholder: "Password", text: $viewModel.password)
                                        }
                                        
                                        Line3()
                                        
                                        // Show or hide password input
                                        ShowPasswordButton()
                                        
                                        // Button to login
                                        LoginButton()
                                        
                                        Rectangle()
                                            .fill(Color("Snow"))
                                            .frame(height: 2)
                                            .padding(.top)
                                        
                                        // Button to sign in with Google
                                        GoogleButton()
                                            .padding(.vertical)
                                        
                                        // Button to open reset password view
                                        LabelButton(action: {
                                            self.showResetPasswordView = true
                                        }, title: "Forgot password?", color: Color("Gondola"), fontSize: 18)
                                        .sheet(isPresented: $showResetPasswordView) {
                                            ResetPasswordView(authManager: authManager, email: $email)
                                        }
                                        .padding(.bottom, 20)
                                    }
                                )
                            }
                            .opacity(flipped ? 0 : 1)
                            
                            // MARK: Sign up view
                            RoundedSquare(color: Color("Seashell"), width: 300, height: 550) {
                                AnyView(
                                    VStack {
                                        HStack {
                                            AuthText(text: "Sign up")
                                            Spacer()
                                        }
                                        
                                        // Email input field
                                        SignTextField(placeholder: "Email", text: $viewModel.email)
                                        
                                        Line3()
                                            .padding(.bottom)
                                        
                                        // Password input field
                                        if showPassword {
                                            SignTextField(placeholder: "Password", text: $viewModel.password)
                                        } else {
                                            SignSecureField(placeholder: "Password", text: $viewModel.password)
                                        }
                                        
                                        Line3()
                                        
                                        // Show or hide password
                                        ShowPasswordButton()
                                        
                                        // Button to sign up
                                        SignUpButton()
                                        
                                        Rectangle()
                                            .fill(Color("Snow"))
                                            .frame(height: 2)
                                            .padding(.vertical)
                                        
                                        // Button to sign in with Google
                                        GoogleButton()
                                        
                                        // Button to sign up anymously
                                        guestButton(viewModel: viewModel, showSignInView: $showSignInView)

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
        .onAppear() {
            CrashlyticsManager.shared.setValue(value: "AuthView", key: "currentView")
        }
    }
}


// MARK: Extension
extension AuthView {
    func guestButton(viewModel: AuthViewModel, showSignInView: Binding<Bool>) -> some View {
        Button(action: {
            Task {
                do {
                    try await viewModel.signInAnonymous()
                    showSignInView.wrappedValue = false
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
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.linearGradient(colors: [Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                    .opacity(0.3)
            )
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
        })
        .padding(.bottom, 30)
        .padding(.top, 20)
    }
    
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
                    // Error for not filling email field (ERR04)
                    guard !viewModel.email.isEmpty else {
                        throw LoginError.emptyEmail
                    }
                    // Error for not filling password field (ERR05)
                    guard !viewModel.password.isEmpty else {
                        throw LoginError.emptyPassword
                    }
                    // Error for not filling email field with valid email (ERR06)
                    guard viewModel.email.contains("@") else {
                        throw LoginError.invalidEmail
                    }
                    // Error if no account with such email exists in authentication database (ERR07)
                    let methods = try await Auth.auth().fetchSignInMethods(forEmail: viewModel.email)
                    guard !(methods.isEmpty) else {
                        throw LoginError.emailNotFound
                    }
                    try await viewModel.signIn()
                    print("Logged in succesfully.")
                    showSignInView = false
                // Appropriate alerts are shown to user
                } catch let error as LoginError {
                    print("Failed to log in: \(error)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                    // Error if no accounts match the email and password in authentication database,
                    // handled internally by Firebase (ERR03)
                } catch let nsError as NSError {
                    print("Failed to log in due to Firebase error: \(nsError)")
                    if nsError.code == AuthErrorCode.wrongPassword.rawValue {
                        alertMessage = NSLocalizedString("Email or password do not match.", comment: "")
                    } else {
                        alertMessage = nsError.localizedDescription
                    }
                    showAlert = true
                } catch {
                    // Error caused by unknown issue (ERR02)
                    print("Failed to log in: \(error)")
                    alertMessage = "Encountered unknown issue."
                    showAlert = true
                }
            }
        }) {
            Text("Login")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .font(.headline)
                .frame(width: 125, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                )
                .foregroundColor(Color("Gondola"))
        }
        // Alert shown for error in process of logging in
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error logging in"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func SignUpButton() -> some View {
        Button(action: {
            Task {
                do {
                    // Error for not filling email field (ERR04)
                    guard !viewModel.email.isEmpty else {
                        throw SignUpError.emptyEmail
                    }
                    // Error for not filling password field (ERR05)
                    guard !viewModel.password.isEmpty else {
                        throw SignUpError.emptyPassword
                    }
                    // Error for not filling email field with valid email (ERR06)
                    guard viewModel.email.contains("@") else {
                        throw SignUpError.invalidEmail
                    }
                    // Error for not password field having less than 6 symbols (ERR08)
                    guard viewModel.password.count >= 6 else {
                        throw SignUpError.passwordTooShort
                    }
                    // Error if account with such email already exists in authentication database (ERR09)
                    let methods = try await Auth.auth().fetchSignInMethods(forEmail: viewModel.email)
                    guard methods.isEmpty else {
                        throw SignUpError.emailAlreadyExists
                    }
                    try await viewModel.signUp()
                    print("Signed up succesfully.")
                    showSignInView = false
                // Appropriate alerts are shown to user
                } catch let error as SignUpError {
                    print("Failed to sign up: \(error)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                } catch {
                    // Error caused by unknown issue (ERR02)
                    print("Unexpected error: \(error)")
                    alertMessage = "Encountered unknown issue."
                    showAlert = true
                }
            }
        }) {
            Text("Sign up")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .font(.headline)
                .frame(width: 125, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                )
                .foregroundColor(Color("Gondola"))
        }
        // Alert shown for error in process of signing up
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error signing up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func ShowPasswordButton() -> some View {
        PasswordButton(isPasswordShown: $showPassword, action: {
            showPassword.toggle()
        })
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


// MARK: Enum
// Errors for login
enum LoginError: LocalizedError {
    case emptyEmail
    case emptyPassword
    case invalidEmail
    case emailNotFound
    case wrongPassword
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return NSLocalizedString("Please enter an email.", comment: "")
        case .emptyPassword:
            return NSLocalizedString("Please enter a password.", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Please input a valid email.", comment: "")
        case .emailNotFound:
            return NSLocalizedString("No such account found.", comment: "")
        case .wrongPassword:
            return NSLocalizedString("Email or password do not match.", comment: "")
        }
    }
}

// Errors for signing up
enum SignUpError: LocalizedError {
    case emptyEmail
    case emptyPassword
    case invalidEmail
    case passwordTooShort
    case emailAlreadyExists
        
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return NSLocalizedString("Please enter an email.", comment: "")
        case .emptyPassword:
            return NSLocalizedString("Please enter a password.", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Please input a valid email.", comment: "")
        case .passwordTooShort:
            return NSLocalizedString("Password must be at least 6 characters long.", comment: "")
        case .emailAlreadyExists:
            return NSLocalizedString("An account with this email already exists.", comment: "")
        }
    }
}
