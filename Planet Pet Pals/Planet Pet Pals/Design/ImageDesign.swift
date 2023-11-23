//
//  ImageDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/11/2023.
//

import SwiftUI

struct MainImageView: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
    }
}

struct FadeOutImageView: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .overlay(
                RadialGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                               center: .center, startRadius: 0, endRadius: 500)
            )
    }
}

