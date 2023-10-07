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
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .background(Color.white)
                .clipShape(Circle())
            
            Text(buttonText)
        }
    }
}
