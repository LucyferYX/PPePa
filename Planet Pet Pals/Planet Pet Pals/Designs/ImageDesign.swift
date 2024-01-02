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

struct FadeOutImageView: View {
    let isLoading: Bool
    let url: URL?

    var body: some View {
        GeometryReader { geometry in
            HStack {
                if isLoading {
                    ProgressView()
                } else if let url = url {
                    Color.clear.overlay(
                        AsyncImage(url: url) { image in
                            image.resizable()
                                 .scaledToFill()
                                 .frame(width: 250, height: 250)
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
                        } placeholder: {
                            ProgressView()
                        }
                    )
                }
            }
        }
    }
}

