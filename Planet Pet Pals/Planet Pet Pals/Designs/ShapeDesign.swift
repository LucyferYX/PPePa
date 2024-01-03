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
            .fill(Color("Linen"))
            .frame(height: 2)
            .padding(.vertical)
    }
}

struct Line2: View {
    var body: some View {
        Rectangle()
            .frame(width: 325, height: 3)
            .foregroundColor(Color("Salmon"))
    }
}

struct Line3: View {
    var body: some View {
        Rectangle()
            .frame(width: 270, height: 3)
            .foregroundColor(Color("Salmon"))
    }
}

struct RoundedSquare: View {
    var color: Color
    var width: CGFloat
    var height: CGFloat
    var overlayContent: () -> AnyView

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(LinearGradient(gradient: Gradient(colors: [Color("Snow"), color]), startPoint: .top, endPoint: .bottom))
            .frame(width: width, height: height)
            .overlay(overlayContent())
    }
}

struct PostCircle: View {
    var overlayContent: () -> AnyView

    var body: some View {
        Circle()
            .fill(LinearGradient(gradient: Gradient(colors: [Color("Walnut"), Color("Gondola")]), startPoint: .top, endPoint: .trailing))
            .frame(width: 150, height: 150)
            .overlay(overlayContent())
    }
}

struct AuthBackground: View {
    var color1: Color
    var color2: Color
    
    var body: some View {
        Color("Snow")
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 1000, height: 500)
            .rotationEffect(.degrees(35))
            .offset(y: -350)
    }
}

struct TopRightRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
