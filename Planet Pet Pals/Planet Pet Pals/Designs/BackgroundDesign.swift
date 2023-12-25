//
//  BackgroundDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/11/2023.
//

import SwiftUI

struct MainBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Colors.linen, Colors.salmon]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct MainBackground2: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Colors.salmon, Colors.walnut]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct MainBackground3: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Colors.snow, Colors.linen]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

//struct SimpleBackground: View {
//    var body: some View {
//        .background(Colors.walnut)
//        .edgesIgnoringSafeArea(.all)
//    }
//}
