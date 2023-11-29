//
//  SearchBarDesign.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 07/10/2023.
//

import SwiftUI

struct MainSearchBar: View {
    @Binding var text: String
    var body: some View {
        TextField("Search", text: $text)
            .padding(12)
            .padding(.leading, 10)
            .font(.custom("Baloo2-Regular", size: 20))
            .frame(height: 60)
            .background(Color(.systemGray6))
            .cornerRadius(30)
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Colors.salmon)
                        .rotationEffect(.degrees(45))
                        .padding(.horizontal, 20)
                }
            )
            // The higher the value, the smaller the width
            .padding(.horizontal, 40)
            .autocapitalization(.none)
    }
}
