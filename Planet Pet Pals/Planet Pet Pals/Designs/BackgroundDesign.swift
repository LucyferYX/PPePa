//
//  BackgroundDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/11/2023.
//

import SwiftUI

struct MainBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color("Linen"), Color("Salmon")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct MainBackground2: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color("Salmon"), Color("Walnut")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct MainBackground3: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color("Snow"), Color("Linen")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

//struct SimpleBackground: View {
//    var body: some View {
//        .background(Color("Walnut"))
//        .edgesIgnoringSafeArea(.all)
//    }
//}
