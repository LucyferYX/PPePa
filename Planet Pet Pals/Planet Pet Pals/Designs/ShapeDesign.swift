//
//  ShapeDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 03/12/2023.
//

import SwiftUI

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Colors.linen)
            .frame(height: 2)
            .padding(.vertical)
    }
}

struct RoundedSquare: View {
    var color: Color
    var overlayContent: () -> AnyView

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(color)
            .frame(width: 300, height: 400)
            .overlay(overlayContent())
    }
}

struct AuthBackground: View {
    var color1: Color
    var color2: Color
    
    var body: some View {
        Colors.snow
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 1000, height: 500)
            .rotationEffect(.degrees(35))
            .offset(y: -350)
    }
}
