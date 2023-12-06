//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var searchText = ""
    @State private var showPanelView = false
    @State private var showMapView = false
    @State private var showStatsView = false
    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                
                ZStack(alignment: .topLeading) {
                    MainBackground()
                    
                    VStack {
                        SimpleImageView(imageName: "LogoBig", width: 250, height: 120)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        HStack {
                            SimpleButton(action: {
                                print("Left button pressed")
                            }, systemImage: "chevron.left", buttonText: "", size: 30, color: Colors.snow)
                            
                            // Pet Image
                            FadeOutImageView(imageName: "MainDog", width: 250, height: 250)
                            
                            SimpleButton(action: {
                                print("Right button pressed")
                            }, systemImage: "chevron.right", buttonText: "", size: 30, color: Colors.snow)
                        }
                        
                        Spacer()
                        
                        MainSearchBar(text: $searchText)
                        
                        Spacer()
                        
                        // Main buttons
                        HStack(spacing: -3) {
                            MainButton(action: { showPanelView.toggle() },
                                       imageName: "person.fill",
                                       buttonText: "Panel",
                                       imageColor: Colors.salmon,
                                       buttonColor: Colors.snow)
                            .padding()
                            
                            MainButton(action: { self.showMapView = true },
                                       imageName: "map.fill",
                                       buttonText: "Map",
                                       imageColor: Colors.walnut,
                                       buttonColor: Colors.snow)
                            .padding()
                            
                            MainButton(action: { self.showStatsView = true },
                                       imageName: "chart.bar.fill",
                                       buttonText: "Stats",
                                       imageColor: Colors.salmon,
                                       buttonColor: Colors.snow)
                            .padding()
                            
                        }
                        // Opens the view from bottom
                        .fullScreenCover(isPresented: $showMapView) {
                            MapView(showMapView: $showMapView, region: "Europe")
                        }
                    }
                    PanelView(width: geometry.size.width*0.7, showPanelView: self.showPanelView, closePanelView: { self.showPanelView = false })
                        .offset(x: self.showPanelView ? 0 : -geometry.size.width)
                        .transition(.move(edge: .leading))
                    StatsView(showStatsView: self.$showStatsView)
                        .offset(x: self.showStatsView ? 0 : geometry.size.width)
                        .transition(.move(edge: .trailing))
                }
            }
        }
    }
}
