//
//  ResetPasswordView.swift
//  Planet Pet Pals
//
//  Created by Liene on 25/12/2023.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var showResetPassword: Bool
    @Binding var email: String
    @State private var showAlert = false
    @State private var alertMessage = "No such email"

    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing: 2) {
                Button(action: {
                    showResetPassword = false
                }) {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Colors.salmon)
                }
                
                Spacer()
                
                Text("Input your email address linked to your account and we will send you passowrd reset email.")
                    .font(.custom("Baloo2-Regular", size: 20))
                    .foregroundColor(Colors.gondola)
                    .multilineTextAlignment(.center)
                    .lineSpacing(0)
                    .padding()
                
                Spacer()
                
                TextField("Email", text: $email)
                    .padding(.leading, 20)
                    .font(.custom("Baloo2-SemiBold", size: 20))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                
                Rectangle()
                    .frame(width: 320, height: 3)
                    .foregroundColor(Colors.salmon)
                
                Button(action: {
                    Task {
                        do {
                            guard !email.isEmpty else {
                                throw PasswordResetError.emptyEmail
                            }
                            guard email.contains("@") else {
                                throw PasswordResetError.invalidEmail
                            }
                            try await authManager.resetPassword(email: email)
                            showResetPassword = false
                            alertMessage = "Reset email sent!"
                            print("Password reset for email: \(email)")
                        } catch let error as PasswordResetError {
                            print("Failed to reset password: \(error)")
                            alertMessage = error.localizedDescription
                            showAlert = true
                        } catch {
                            print("Unexpected error: \(error)")
                            alertMessage = "An unexpected error occurred."
                            showAlert = true
                        }
                    }
                }) {
                    Text("Reset password")
                        .frame(width: 220, height: 60)
                        .font(.custom("Baloo2-SemiBold", size: 18))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.linearGradient(colors: [Colors.orchid, Colors.salmon], startPoint: .leading, endPoint: .trailing))
                        )
                        .foregroundColor(Colors.snow)
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding()
        }
    }
}


enum PasswordResetError: LocalizedError {
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


struct ResetPasswordViewPreview: PreviewProvider {
    @State static var email = "laima@gmail.com"
    static var previews: some View {
        ResetPasswordView(authManager: AuthManager.shared, showResetPassword: .constant(true), email: $email)
    }
}
