//
//  SearchBarDesign.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 07/10/2023.
//

import SwiftUI

struct MainSearchBar: View {
    @Binding var text: String
    // Pressing paw will search
    var onCommit: () -> Void = {}
    
    var body: some View {
        HStack {
            TextField("Search", text: $text, onCommit: onCommit)
                .padding(12)
                .padding(.leading, 10)
                .padding(.trailing, 40)
                .font(.custom("Baloo2-Regular", size: 20))
                .frame(height: 60)
                .background(Colors.snow)
                .cornerRadius(30)
                .overlay(
                    Button(action: onCommit) {
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Colors.salmon)
                            .rotationEffect(.degrees(45))
                            .padding(.horizontal, 20)
                    },
                    alignment: .trailing
                )
                .autocapitalization(.none)
        }
        .padding(.horizontal, 40)
    }
}
