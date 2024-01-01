//
//  ProfileSettingsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 01/01/2024.
//

import SwiftUI
import FirebaseAuth


@MainActor
class ProfileSettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() {
        if let providers = try? AuthManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthManager.shared.delete()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "hi@gmail.com"
        try await AuthManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hihello"
        try await AuthManager.shared.updatePassword(password: password)
    }
    
    @Published var errorMessage: String? = nil

    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        do {
            let tokens = try await helper.signIn()
            let authUser = try await AuthManager.shared.linkGoogle(tokens: tokens)
            self.authUser = authUser
            try await UserManager.shared.updateUserAnonymousStatusAndEmail(userId: authUser.uid, isAnonymous: authUser.isAnonymous, email: authUser.email)
        } catch let error as NSError where error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
        } catch {
            print("An error occurred: \(error.localizedDescription)")
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    func linkEmailAccount() async throws {
        let email = "hello123@gmail.com"
        let password = "hello123"
        self.authUser = try await AuthManager.shared.linkEmail(email: email, password: password)
        try await UserManager.shared.updateUserAnonymousStatusAndEmail(userId: authUser!.uid, isAnonymous: authUser!.isAnonymous, email: authUser!.email)
    }
}


struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @Binding var showSignInView: Bool
    
    @State private var showDeleteAlert = false
    @State private var showEmailAlert = false
    @State private var emailAlertMessage = ""
    
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
                        // MARK: Registered accounts
                        if viewModel.authProviders.contains(.email) {
                            // create section, name it emailsection
                            
                            Button("Reset password") {
                                Task {
                                    do {
                                        try await viewModel.resetPassword()
                                        print("Password reset")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            Button("Update email") {
                                Task {
                                    do {
                                        try await viewModel.updateEmail()
                                        print("Email updated")
                                    } catch {
                                        print("Error: \(error)")
                                        emailAlertMessage = error.localizedDescription
                                        showEmailAlert = true
                                    }
                                }
                            }
                            
                            Button("Update password") {
                                Task {
                                    do {
                                        try await viewModel.updatePassword()
                                        print("Password updated")
                                    } catch {
                                        print("Error: \(error)")
                                        emailAlertMessage = error.localizedDescription
                                        showEmailAlert = true
                                    }
                                }
                            }
                        }
                        
                        // MARK: Create account
                        // perhaps dont have the if, just output errors if user tries to link account to google if account already exists
                        if viewModel.authUser?.isAnonymous == true {
                            Button("Create Google account") {
                                Task {
                                    do {
                                        try await viewModel.linkGoogleAccount()
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            Button("Create e-mail account") {
                                Task {
                                    do {
                                        try await viewModel.linkEmailAccount()
                                        print("E-mail linked")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                        }
                        
                        
                        // MARK: All accounts
                        Button("Sign out") {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    showSignInView = true
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete Account")
                        }
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(title: Text("Delete Account"),
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
                                secondaryButton: .cancel())
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
                viewModel.loadAuthUser()
            }
            .alert(isPresented: $showEmailAlert) {
                Alert(title: Text("Error"), message: Text(emailAlertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
