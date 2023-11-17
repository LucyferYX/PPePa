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
    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .leading) {
                    
                    // Background
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "F9EEE8"), Color(hex: "FFAF97")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Image("LogoBig")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 100)
                            .padding(.top, 20)
                        
                        //Spacer()
                        
                        Image("MainDog")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                        
                        
                        //Spacer()
                        
                        MainSearchBar(text: $searchText)
                        // 3 buttons
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.showMeView.toggle()
                                }
                            }) {
                                MainButton(imageName: "ImageA", buttonText: "A")
                                    .padding()
                            }
                            MainButton(imageName: "ImageB", buttonText: "B")
                                .padding()
                            MainButton(imageName: "ImageC", buttonText: "C")
                                .padding()
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


struct Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
