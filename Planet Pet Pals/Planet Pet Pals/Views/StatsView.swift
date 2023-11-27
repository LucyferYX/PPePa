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
                MainNavigationBar(
                    title: "Stats",
                    leftButton: LeftNavigationButton(
                        action: { self.showStatsView = false },
                        imageName: "chevron.left",
                        buttonText: "Back",
                        imageColor: Color(hex: "F9EEE8"),
                        buttonColor: Color(hex: "FFFAF7"),
                        imageInvisible: false,
                        textInvisible: false
                    ),
                    rightButton: RightNavigationButton(
                        action: {},
                        imageName: "chevron.left",
                        buttonText: "Back",
                        imageColor: Color(hex: "F9EEE8"),
                        buttonColor: Color(hex: "FFFAF7"),
                        imageInvisible: false,
                        textInvisible: true
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
