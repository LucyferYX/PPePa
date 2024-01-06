//
//  AccountSettingsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 01/01/2024.
//

import SwiftUI
import FirebaseAuth

struct AccountSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AccountSettingsViewModel()
    @Binding var showSignInView: Bool
    
    @State private var isButtonClickedOnce: Bool = true
    @State private var showDeleteAlert = false
    @State private var showPassword = false
    
    @State private var showEmailAlert = false
    @State private var emailAlertMessage = ""
    @State private var showGoogleAlert = false
    @State private var passwordAlertMessage = ""
//    @State private var showPasswordAlert = false
    
    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing: 0) {
                VStack {
                    PawButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, color: Color("Salmon"))
                    .padding(.bottom, 30)
                }
                ScrollView() {
                    VStack(spacing: 0) {
                        
                        if viewModel.authProviders.contains(.email) {
                            RoundedSquare(color: Color("Seashell"), width: 300, height: 300) {
                                AnyView(
                                    VStack {
                                        Text("Update password")
                                            .foregroundColor(Color("Gondola"))
                                            .font(.custom("Baloo2-SemiBold", size: 25))
                                            .padding()
                                        
                                        if showPassword {
                                            SignTextField(placeholder: "Password", text: $viewModel.password)
                                        } else {
                                            SignSecureField(placeholder: "Password", text: $viewModel.password)
                                        }
                                        
                                        Line3()

                                        ShowPasswordButton()
                                        
                                        Button(action: {
                                            Task {
                                                do {
                                                    try await viewModel.updatePassword()
                                                    print("Password updated")
                                                } catch {
                                                    print("Error: \(error)")
                                                    passwordAlertMessage = error.localizedDescription
                                                }
                                            }
                                        }) {
                                            Text("Update password")
                                                .foregroundColor(Color("Gondola"))
                                                .font(.custom("Baloo2-Regular", size: 20))
                                                .frame(width: 200, height: 50)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color("Linen"))
                                                )
                                        }
                                        .alert(isPresented: $viewModel.showPasswordAlert) {
                                            Alert(title: Text("Error"),
                                                  message: Text(viewModel.errorMessage ?? ""),
                                                  dismissButton: .default(Text("OK")))
                                        }
                                    }
                                )
                            }
                            
                            Text("or")
                                .foregroundColor(Color("Gondola"))
                                .font(.custom("Baloo2-Regular", size: 20))
                            
                            Button(action: {
                                Task {
                                    do {
                                        try await viewModel.resetPassword()
                                        print("Password reset")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }) {
                                Text("Send a password reset to email")
                                    .foregroundColor(Color("Gondola"))
                                    .font(.custom("Baloo2-Regular", size: 20))
                            }
                        }

                        // MARK: Create account
                        if viewModel.authUser?.isAnonymous == true {
                            Text("Link your account")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                                .foregroundColor(Color("Gondola"))
                                .padding()

                            RoundedSquare(color: Color("Seashell"), width: 300, height: 300) {
                                AnyView(
                                    VStack {

                                        SignTextField(placeholder: "Email", text: $viewModel.email)
                                        
                                        Line3()

                                        if showPassword {
                                            SignTextField(placeholder: "Password", text: $viewModel.password)
                                        } else {
                                            SignSecureField(placeholder: "Password", text: $viewModel.password)
                                        }
                                        
                                        Line3()

                                        ShowPasswordButton()

                                        LinkEmailButton(showEmailAlert: $showEmailAlert, emailAlertMessage: $emailAlertMessage)

                                    }
                                )
                            }

                            Spacer()
                            
                            Text("or")
                                .foregroundColor(Color("Gondola"))
                                .font(.custom("Baloo2-Regular", size: 20))

                            linkGoogleAccountButton(viewModel: viewModel)

                        }
                        
                        Line()
                            .padding()
                        
                        
                        // MARK: All accounts
                        signOutButton
                        
                        deleteAccountButton
                    }
                }
            }
            .onAppear {
                CrashlyticsManager.shared.setValue(value: "AccountSettingsView", key: "currentView")
                viewModel.loadAuthProviders()
                viewModel.loadAuthUser()
                if viewModel.authProviders.contains(.google) {
                    print("User is signed in with Google.")
                } else if viewModel.authProviders.contains(.email) {
                    print("User is signed in with email.")
                } else {
                    print("User is signed in anonymously.")
                }
            }
        }
    }
}


struct ProfileSettingsPreviews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(showSignInView: .constant(false))
    }
}


enum AlertType: Identifiable {
    case deleteAccount, deleteError

    var id: Int {
        switch self {
        case .deleteAccount:
            return 1
        case .deleteError:
            return 2
        }
    }
}



extension AccountSettingsView {
    func LinkEmailButton(showEmailAlert: Binding<Bool>, emailAlertMessage: Binding<String>) -> some View {
        Button(action: {
            Task {
                do {
                    try await viewModel.linkEmailAccount()
                    print("E-mail linked")
                } catch let error as LinkEmailError {
                    print("Failed to link email: \(error)")
                    emailAlertMessage.wrappedValue = error.localizedDescription
                    showEmailAlert.wrappedValue = true
                } catch {
                    print("Unexpected error: \(error)")
                    emailAlertMessage.wrappedValue = "An unexpected error occurred."
                    showEmailAlert.wrappedValue = true
                }
            }
        }) {
            Text("Link e-mail account")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .frame(width: 220, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                )
                .foregroundColor(Color("Gondola"))
        }
        .alert(isPresented: $showEmailAlert) {
            Alert(title: Text("Error"),
                  message: Text(emailAlertMessage.wrappedValue),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func linkGoogleAccountButton(viewModel: AccountSettingsViewModel) -> some View {
        Button(action: {
            Task {
                do {
                    try await viewModel.linkGoogleAccount()
                } catch {
                    print("Error: \(error)")
                }
            }
        }) {
            HStack {
                Image(systemName: "g.circle.fill")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
                Text("Link Google account")
                    .font(.custom("Baloo2-Regular", size: 20))
                    .foregroundColor(Color("Gondola"))
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 7)
            .background(Color("Snow"))
            .cornerRadius(10)
        }
        .alert(isPresented: $showGoogleAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
    }
    
    func ShowPasswordButton() -> some View {
        PasswordButton(isPasswordShown: $showPassword, action: {
            showPassword.toggle()
        })
        .padding(.bottom)
    }
    
    private var signOutButton: some View {
        Button(action: {
            Task {
                do {
                    try viewModel.signOut()
                    showSignInView = true
                } catch {
                    print("Error: \(error)")
                }
            }
        } ) {
            Text("Sign out")
                .font(.custom("Baloo2-Regular", size: 20))
                .foregroundColor(Color("Gondola"))
        }
    }
    
    private var deleteAccountButton: some View {
        Button(role: .destructive) {
            if isButtonClickedOnce {
                isButtonClickedOnce = false
            } else {
                isButtonClickedOnce = true
                viewModel.currentAlert = .deleteAccount
            }
        } label: {
            Text(isButtonClickedOnce ? "Delete account" : "Confirm account deletion")
                .font(.custom("Baloo2-Regular", size: 20))
        }
        .padding(.bottom)
        .alert(item: $viewModel.currentAlert) { alertType in
            switch alertType {
            case .deleteAccount:
                return Alert(
                    title: Text("Delete account"),
                    message: Text("Would you like to delete account? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete").foregroundColor(.red)) {
                        Task {
                            do {
                                let userId = Auth.auth().currentUser?.uid
                                try await UserManager.shared.deleteUser(userId: userId!)
                                try await viewModel.deleteAccount()
                                showSignInView = true
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .deleteError:
                return Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
                    }
                )
            }
        }
    }
}

enum LinkEmailError: LocalizedError {
    case emptyEmail
    case emptyPassword
    case invalidEmail
    case emailAlreadyExists
    case passwordTooShort
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please enter an email."
        case .emptyPassword:
            return "Please enter a password."
        case .invalidEmail:
            return "Please input a valid email."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .passwordTooShort:
            return "Password must be at least 6 characters long."
        }
    }
}
