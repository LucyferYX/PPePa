//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

struct MainMenuView: View {
    @State private var searchText = ""
    @State private var showMeView = false
    @State private var showMapView = false
    @State private var showStatsView = false
    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                
                ZStack(alignment: .leading) {
                    MainBackground()
                    
                    VStack {
                        Spacer()
                        
                        // Logo
                        MainImageView(imageName: "LogoBig", width: 200, height: 100)
                            .padding(.top, 20)
                        
                        HStack {
                            Button(action: {
                                // Image to left
                            }) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(hex: "FFFAF7"))
                            }
                            .padding(.trailing, 20)
                            
                            // Pet Image
                            FadeOutImageView(imageName: "MainDog", width: 200, height: 300)
                            
                            Button(action: {
                                // Image to right
                            }) {
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(hex: "FFFAF7"))
                            }
                            .padding(.leading, 20)
                        }
                        
                        Spacer()
                        
                        MainSearchBar(text: $searchText)
                        
                        Spacer()
                        
                        // Main buttons
                        HStack(spacing: -3) {
                            MainButton(action: { self.showMeView.toggle() },
                                       imageName: "person.fill",
                                       buttonText: "Post",
                                       imageColor: Color(hex: "FFAF97"),
                                       buttonColor: Color(hex: "FFFAF7"))
                                .padding()

                            MainButton(action: { self.showMapView = true },
                                       imageName: "map.fill",
                                       buttonText: "Map",
                                       imageColor: Color(hex: "763626"),
                                       buttonColor: Color(hex: "FFFAF7"))
                                .padding()

                            MainButton(action: { self.showStatsView = true },
                                       imageName: "chart.bar.fill",
                                       buttonText: "Stats",
                                       imageColor: Color(hex: "FFAF97"),
                                       buttonColor: Color(hex: "FFFAF7"))
                                .padding()

                        }
                        // Opens the view from bottom
                        .fullScreenCover(isPresented: $showMapView) {
                            MapView(showMapView: $showMapView)
                        }
                    }

                // Creates illusion with view sliding to right
                }.frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: self.showMeView ? geometry.size.width / 2 : 0)
                    // Allows to close it by sliding from right to left
                    .gesture(DragGesture().onEnded { value in
                        if value.translation.width < -100 {
                            withAnimation {
                                self.showMeView = false
                            }
                        }
                    })
                
                // Checks whether showMeView is true, then displays MeView
                if self.showMeView {
                    MeView(show: self.$showMeView)
                        .frame(width: geometry.size.width / 2)
                        .transition(.move(edge: .leading))
                }
            }
        }
    }
}


//struct MainPreviews: PreviewProvider {
//    static var previews: some View {
//        MainMenuView()
//    }
//}
