//
//  ResetPasswordView.swift
//  Planet Pet Pals
//
//  Created by Liene on 25/12/2023.
//

import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager: AuthManager
    @Binding var email: String
    @State private var showAlert = false
    @State private var alertMessage = "alert"

    var body: some View {
        ZStack {
            // Background design
            MainBackground3()
            
            VStack(spacing: 2) {
                // Closing view button
                PawButton(action: {
                    presentationMode.wrappedValue.dismiss()
                }, color: Color("Salmon"))

                
                Spacer()
                
                // Text to inform user
                Text("Input your email address linked to your account and we will send you password reset email.")
                    .font(.custom("Baloo2-Regular", size: 20))
                    .foregroundColor(Color("Gondola"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(0)
                    .padding()
                
                Spacer()
                
                // Field to input email to which recovery email will be sent,
                // if such email exists in authentication database
                HStack(spacing: 1) {
                    Image(systemName: "envelope")
                        .foregroundColor(Color("Salmon"))
                        .imageScale(.large)
                    TextField("Email", text: $email)
                        .padding(.leading, 20)
                        .font(.custom("Baloo2-SemiBold", size: 20))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(.plain)
                }
                .padding(.leading)
                
                Line2()
                
                // Button to send recovery email
                Button(action: {
                    Task {
                        // Handling of multiple errors
                        do {
                            guard !email.isEmpty else {
                                throw EmailError.emptyEmail
                            }
                            guard email.contains("@") else {
                                throw EmailError.invalidEmail
                            }
                            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
                            guard !(methods.isEmpty) else {
                                throw EmailError.emailNotFound
                            }
                            try await authManager.resetPassword(email: email)
                            presentationMode.wrappedValue.dismiss()
                            alertMessage = "Reset email sent!"
                            print("Password reset for email: \(email)")
                        } catch let error as EmailError {
                            print("Failed to reset password: \(error)")
                            alertMessage = error.localizedDescription
                            showAlert = true
                        } catch {
                            print("Unexpected error: \(error)")
                            alertMessage = "Encountered unknown issue."
                            showAlert = true
                        }
                    }
                }) {
                    // Button design
                    Text("Reset password")
                        .frame(width: 220, height: 60)
                        .font(.custom("Baloo2-SemiBold", size: 18))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                        )
                        .foregroundColor(Color("Snow"))
                }
                .padding()
                // Showing alert to user if something went wrong
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear() {
            CrashlyticsManager.shared.setValue(value: "ResetPasswordView", key: "currentView")
        }
    }
}


enum EmailError: LocalizedError {
    case emptyEmail
    case invalidEmail
    case emailNotFound

    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please enter an email."
        case .invalidEmail:
            return "Please input a valid email."
        case .emailNotFound:
            return "No such email address found."
        }
    }
}


//struct ResetPasswordViewPreview: PreviewProvider {
//    @State static var email = "laima@gmail.com"
//    static var previews: some View {
//        ResetPasswordView(authManager: AuthManager.shared, showResetPassword: .constant(true), email: $email)
//    }
//}
