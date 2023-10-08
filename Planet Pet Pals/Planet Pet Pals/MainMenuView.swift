//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

struct MainMenuView: View {
    @State private var searchText = ""
    
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
                    
                    
                    //Spacer()
                    
                    MainSearchBar(text: $searchText)
                        HStack {
                            //NavigationLink(destination: MeView()) {
                                MainButton(imageName: "ImageA", buttonText: "A")
                                    .padding()
                            //}
                            MainButton(imageName: "ImageB", buttonText: "B")
                                .padding()
                            NavigationLink(destination: MeView()) {
                                MainButton(imageName: "ImageC", buttonText: "C")
                                    .padding()
                            }
                        }
                    //.padding()
                }
            }
        }
    }
}


//#Preview {
//    MainMenuView()
//}
