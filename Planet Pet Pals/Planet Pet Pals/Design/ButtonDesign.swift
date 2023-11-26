//
//  ButtonDesign.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 07/10/2023.
//

import SwiftUI

struct MainButton: View {
    let action: () -> Void
    let imageName: String
    let buttonText: String
    let imageColor: Color
    let buttonColor: Color
    
    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .foregroundColor(imageColor)
                    .background(Color.white)
                    .clipShape(Circle())
                    .frame(width: 85, height: 85)
                
                Text(buttonText)
                    .padding(-5)
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(buttonColor)
            }
        }
    }
}

struct NavigationButton: View {
    let action: () -> Void
    let imageName: String
    let buttonText: String
    let imageColor: Color
    let buttonColor: Color
    let buttonInvisible: Bool
    
    let buttonSize: CGFloat = 20

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundColor(buttonInvisible ? Color.clear : imageColor)
                if !buttonText.isEmpty {
                    Text(buttonText)
                        .font(.custom("Baloo2-SemiBold", size: 25))
                        .foregroundColor(buttonColor)
                }
            }
        }
    }
}
