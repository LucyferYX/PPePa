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

    var body: some View {
        NavigationView {
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
                        register()
                    }, buttonText: "Login", size: 30, color: Color.blue)
                    
                    SimpleButton(action: {
                        print(" Sign in pressed")
                    }, systemImage: "", buttonText: "Sign in", size: 30, color: Color.green)
                }
                .padding()
            }
        }
    }
    
    func register() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!)
            }
        }
    }
}
