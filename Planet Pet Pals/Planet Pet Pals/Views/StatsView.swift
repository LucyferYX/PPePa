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
                    leftButtonAction: { self.showStatsView = false },
                    rightButtonAction: {},
                    leftButtonSystemImage: "chevron.left",
                    rightButtonSystemImage: "chevron.left",
                    rightButtonInvisible: false
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
