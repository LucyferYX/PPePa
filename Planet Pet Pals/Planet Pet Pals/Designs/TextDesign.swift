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
            .disableAutocorrection(true)
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

struct LimitedTextField: View {
    @Binding var text: String
    var maxLength: Int
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(title, text: $text, axis: .vertical)
                .font(.custom("Baloo2-Regular", size: 20))
                .lineLimit(...10)
                .disableAutocorrection(true)
                .onChange(of: text) { newValue in
                    if text.count > maxLength {
                        text = String(text.prefix(maxLength))
                    }
                }
            if text.count >= maxLength {
                Text("Character limit of \(maxLength) has been reached!")
                    .font(.custom("Baloo2-Regular", size: 15))
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}
