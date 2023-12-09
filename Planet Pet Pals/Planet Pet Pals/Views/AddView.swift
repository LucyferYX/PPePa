//
//  AddView.swift
//  Planet Pet Pals
//
//  Created by Liene on 09/12/2023.
//

import SwiftUI

struct AddView: View {
    @Binding var showAddView: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                MainNavigationBar(
                    title: "Add post",
                    leftButton: LeftNavigationButton(
                        action: { self.showAddView = false },
                        imageName: "chevron.left",
                        buttonText: "Back",
                        imageInvisible: false,
                        textInvisible: false
                    ),
                    rightButton: RightNavigationButton(
                        action: {},
                        imageName: "slider.horizontal.3",
                        buttonText: "Back",
                        imageInvisible: false,
                        textInvisible: true
                    )
                )

                ZStack {
                    MainBackground()
                }
            }
        }
    }
}
