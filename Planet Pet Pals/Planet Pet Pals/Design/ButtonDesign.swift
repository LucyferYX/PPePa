//
//  ButtonDesign.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 07/10/2023.
//

import SwiftUI

struct MainButton: View {
    let imageName: String
    let buttonText: String
    let imageColor: Color
    let buttonColor: Color
    
    var body: some View {
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
