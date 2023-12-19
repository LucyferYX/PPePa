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
                .foregroundColor(Colors.linen)
            Spacer()
            rightButton
                .padding(.trailing)
        }
        .padding()
        .background(Colors.walnut)
    }
}

struct MainToolbar: ToolbarContent {
    let title: String
    let leftButton: LeftNavigationButton
    let rightButton: RightNavigationButton

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            leftButton
        }
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.custom("Baloo2-SemiBold", size: 25))
                .foregroundColor(Colors.linen)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            rightButton
        }
    }
}
