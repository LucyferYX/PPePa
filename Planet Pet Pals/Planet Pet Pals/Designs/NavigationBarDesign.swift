//
//  NavigationBarDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/11/2023.
//

import SwiftUI

struct MainNavigationBar: View {
    let title: String
    let leftButton: LeftNavigationButton
    let rightButton: RightNavigationButton

    var body: some View {
        HStack {
            leftButton
                .padding(.leading)
            Spacer()
            Text(title)
                .font(.custom("Baloo2-SemiBold", size: 25))
                .foregroundColor(Color(hex: "F9EEE8"))
            Spacer()
            rightButton
                .padding(.trailing)
        }
        .padding()
        .background(Color(hex:"763626"))
    }
}
