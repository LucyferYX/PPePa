//
//  ImageDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/11/2023.
//

import SwiftUI

struct SimpleImageView: View {
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

struct RoundImage: View {
    var systemName: String
    var size: CGFloat
    var color: Color

    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .foregroundColor(color)
    }
}

struct FadeOutImageView<Content: View>: View {
    let content: Content
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        content
            .frame(width: width, height: height)
            .mask(
                VStack {
                    LinearGradient(gradient: Gradient(colors: [.clear, .black, .black, .black, .black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom)
                }
                .mask(
                    HStack {
                        LinearGradient(gradient: Gradient(colors: [.clear, .black, .black, .black, .black, .black, .black, .black, .black, .clear]), startPoint: .leading, endPoint: .trailing)
                    }
                )
            )
    }
}
