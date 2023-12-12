//
//  AuthenticationView.swift
//  Planet Pet Pals
//
//  Created by Liene on 12/12/2023.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            NavigationLink {
                LoginView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with email")
                    .padding()
                    .frame(height: 55)
            }
        }
    }
}
