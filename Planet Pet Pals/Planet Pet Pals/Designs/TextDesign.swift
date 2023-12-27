//
//  TextDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 26/12/2023.
//

import SwiftUI

struct AuthText: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.custom("Baloo2-SemiBold", size: 40))
            .foregroundColor(Color("Gondola"))
            .padding(.leading, 40)
            .padding(.top, 30)
    }
}

struct SignTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.custom("Baloo2-Regular", size: 20))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.leading)
            .padding(.trailing)
            .textSelection(.enabled)
    }
}

struct SignSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .font(.custom("Baloo2-Regular", size: 20))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.leading)
            .padding(.trailing)
    }
}
