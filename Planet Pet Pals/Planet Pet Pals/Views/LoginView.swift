//
//  LoginView.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/12/2023.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userIsLoggedIn: Bool = false

    var body: some View {
        NavigationView {
            if userIsLoggedIn {
                //print("User is logged in, opened MainMenuView")
            } else {
                content
                //print("User is not logged in, opened LoginView")
            }
        }
    }
    
    var content: some View {
        ZStack {
            MainBackground()
            VStack {
                Text("Login screen")
                    .frame(width: 220, height: 60)
                
                TextField("E-mail", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                Line()
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                Line()
                
                ColorButton(action: {
                    print("Login pressed")
                    login()
                }, buttonText: "Login", color: Color.blue)
                
                ColorButton(action: {
                    print("Sign in pressed")
                    register()
                }, buttonText: "Sign in", color: Color.green)
            }
            .padding()
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    userIsLoggedIn.toggle()
                }
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
