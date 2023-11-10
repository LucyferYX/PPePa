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
        NavigationView {
            ZStack {
                
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
                    
                    Text("This is light text")
                        .font(.custom("Baloo2-ExtraBold", size: 40))

                    Text("This is regular text")
                        .font(.custom("Baloo2-Regular", size: 40))

                    Text("This is medium text")
                        .font(.custom("Baloo2-Medium", size: 40))

                    Text("This is semi-bold text")
                        .font(.custom("Baloo2-SemiBold", size: 40))

                    Text("This is bold text")
                        .font(.custom("Baloo2-Bold", size: 40))

                    
                    
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
                        //NavigationLink(destination: StatsView()) {
                        MainButton(imageName: "ImageC", buttonText: "C")
                            .padding()
                        //}
                    }
                }
                
//                // Closing etc
//                if showMeView {
//                    MeView(showMeView: $showMeView)
//                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
//                        .gesture(DragGesture().onEnded { value in
//                            if value.translation.width < -100 {
//                                withAnimation {
//                                    self.showMeView = false
//                                }
//                            }
//                        })
//                }
            }
        }
    }
}


#Preview {
    MainMenuView()
}
