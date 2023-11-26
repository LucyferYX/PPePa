//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI

struct StatsView: View {
    @Binding var showStatsView: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                CustomNavigationBar(
                    title: "Stats",
                    leftButton: NavigationButton(
                        action: { self.showStatsView = false },
                        imageName: "chevron.left",
                        buttonText: "",
                        imageColor: Color(hex: "F9EEE8"),
                        buttonColor: Color(hex: "FFFAF7"),
                        buttonInvisible: false
                    ),
                    rightButton: NavigationButton(
                        action: {},
                        imageName: "chevron.left",
                        buttonText: "",
                        imageColor: Color(hex: "F9EEE8"),
                        buttonColor: Color(hex: "FFFAF7"),
                        buttonInvisible: false
                    )
                )

                ZStack {
                    MainBackground()
                    Text("Stats View test")
                }
            }
        }
        //.transition(.move(edge: .left))
    }
}
