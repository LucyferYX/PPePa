//
//  NavigationBarDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/11/2023.
//

import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let leftButtonAction: () -> Void
    let rightButtonAction: () -> Void
    let leftButtonSystemImage: String
    let rightButtonSystemImage: String
    let rightButtonInvisible: Bool
    
    let buttonSize: CGFloat = 12

    var body: some View {
        HStack {
            Button(action: leftButtonAction) {
                Image(systemName: leftButtonSystemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize)
                    .foregroundColor(Color(hex: "F9EEE8"))
            }
            .padding(.leading)
            Spacer()
            Text(title)
                .font(.custom("Baloo2-SemiBold", size: 25))
                .foregroundColor(Color(hex: "F9EEE8"))
            Spacer()
            Button(action: rightButtonAction) {
                Image(systemName: rightButtonSystemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize)
                    .foregroundColor(rightButtonInvisible ? Color.clear : Color(hex: "F9EEE8"))
            }
            .padding(.trailing)
        }
        .padding()
        .background(Color(hex:"763626"))
    }
}

