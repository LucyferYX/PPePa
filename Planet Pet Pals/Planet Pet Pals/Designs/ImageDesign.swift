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
            .aspectRatio(contentMode: .fill)
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





    
//    var body: some View {
//        Image(imageName)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: width, height: height)
//            .mask(
//                    HStack {
//                        LinearGradient(gradient: Gradient(stops: [
//                            .init(color: .clear, location: 0),
//                            .init(color: .black, location: 0.2),
//                            .init(color: .black, location: 1)
//                        ]), startPoint: .leading, endPoint: .trailing)
//                        Spacer()
//                        LinearGradient(gradient: Gradient(stops: [
//                            .init(color: .clear, location: 0),
//                            .init(color: .black, location: 0.2),
//                            .init(color: .black, location: 1)
//                        ]), startPoint: .trailing, endPoint: .leading)
//                    }
//                HStack {
//                    LinearGradient(gradient: Gradient(stops: [
//                        .init(color: .clear, location: 0),
//                        .init(color: .black, location: 0.2),
//                        .init(color: .black, location: 1)
//                    ]), startPoint: .trailing, endPoint: .leading)
//                }
//
//                HStack {
//                    LinearGradient(gradient: Gradient(stops: [
//                        .init(color: .clear, location: 0),
//                        .init(color: .black, location: 0.2),
//                        .init(color: .black, location: 1)
//                    ]), startPoint: .leading, endPoint: .trailing)
//                }
//            )
//    }


