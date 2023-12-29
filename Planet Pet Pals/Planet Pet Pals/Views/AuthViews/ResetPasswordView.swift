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
//    @Binding var showResetPassword: Bool
    @Binding var email: String
    @State private var showAlert = false
    @State private var alertMessage = "alert"

    var body: some View {
        ZStack {
            MainBackground3()
            VStack(spacing: 2) {
                PawButton(action: {
                    presentationMode.wrappedValue.dismiss()
//                    showResetPassword = false
                }, color: Color("Salmon"))

                
                Spacer()
                
                Text("Input your email address linked to your account and we will send you passowrd reset email.")
                    .font(.custom("Baloo2-Regular", size: 20))
                    .foregroundColor(Color("Gondola"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(0)
                    .padding()
                
                Spacer()
                
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
                
                Button(action: {
                    Task {
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
//                            showResetPassword = false
                            presentationMode.wrappedValue.dismiss()
                            alertMessage = "Reset email sent!"
                            print("Password reset for email: \(email)")
                        } catch let error as EmailError {
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
                                .fill(.linearGradient(colors: [Color("Orchid"), Color("Salmon")], startPoint: .leading, endPoint: .trailing))
                        )
                        .foregroundColor(Color("Snow"))
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
//    @State static var email = "laima@gmail.comAAAAAAAAAAAAAAAAAAA"
//    static var previews: some View {
//        ResetPasswordView(authManager: AuthManager.shared, showResetPassword: .constant(true), email: $email)
//    }
//}
