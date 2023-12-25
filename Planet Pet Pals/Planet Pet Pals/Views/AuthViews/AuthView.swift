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
    
    var body: some View {
        ZStack {
            Colors.snow
            
//            RoundedRectangle(cornerRadius: 30, style: .continuous)
//                .fill(LinearGradient(gradient: Gradient(colors: [Colors.snow, Colors.salmon]), startPoint: .topLeading, endPoint: .bottomTrailing))
//                .frame(width: 1000, height: 500)
//                .rotationEffect(.degrees(35))
//                .offset(y: -350)

            VStack {
                
                // Text
                HStack {
                    Text("Welcome")
                        .font(.custom("Baloo2-SemiBold", size: 50))
                        .foregroundColor(.primary)
                    Spacer()
                }
                HStack {
                    Text("Sign in to continue")
                        .font(.custom("Baloo2-SemiBold", size: 30))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        // Front view
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .frame(width: 280, height: 280)
                            .overlay(Text("Front").foregroundColor(.white))
                            .opacity(flipped ? 0 : 1)
                        
                        // Back view
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.red)
                            .frame(width: 280, height: 280)
                            .overlay(Text("Back").foregroundColor(.white)).scaleEffect(x: -1, y: 1)
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
                        Text("Flip")
                    }
                }
                
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
        .ignoresSafeArea()
    }
}

struct AuthPreview: PreviewProvider {
    static var previews: some View {
        AuthView(showSignInView: .constant(false))
    }
}
