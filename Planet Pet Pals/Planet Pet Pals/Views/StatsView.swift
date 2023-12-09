//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI
import Firebase

struct StatsView: View {
    @Binding var showStatsView: Bool
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack {
                MainNavigationBar(
                    title: "Stats",
                    leftButton: LeftNavigationButton(
                        action: { self.showStatsView = false },
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
                    VStack {
                        Text("Stats View test")
                        List(dataManager.posts, id: \.id) { post in
                            Text(post.type)
                        }
                        Text("Names displayed above")
                    }
                    .onAppear {
                        print("StatsView appeared with post count: \(dataManager.posts.count)")
                    }
                }
            }
        }
        .transition(.move(edge: .trailing))
    }
}

struct StatsPreview: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager()
        StatsView(showStatsView: .constant(true)).environmentObject(dataManager)
    }
}
