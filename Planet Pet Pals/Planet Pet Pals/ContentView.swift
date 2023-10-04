//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "F9EEE8"), Color(hex: "FFAF97")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Image("LogoBig")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .padding(.all, 20)
                    Spacer()
                }
                
                //Spacer()
                
                Image("MainDog")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                
                Spacer()
            }
            
        }
    }
}

#Preview {
    ContentView()
}
