//
//  ButtonDesign.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 07/10/2023.
//

import SwiftUI

struct MainButton: View {
    let action: () -> Void
    let imageName: String
    let buttonText: String
    let imageColor: Color
    let buttonColor: Color
    
    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .foregroundColor(imageColor)
                    .background(Colors.snow)
                    .clipShape(Circle())
                    .frame(width: 85, height: 85)
                
                Text(buttonText)
                    .padding(-5)
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(buttonColor)
            }
        }
    }
}

struct SimpleButton: View {
    let action: () -> Void
    let systemImage: String?
    let buttonText: String
    let size: CGFloat
    let color: Color

    var body: some View {
        Button(action: action) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(color)
            }
            Text(buttonText)
                .padding(-5)
                .font(.custom("Baloo2-SemiBold", size: size))
                .foregroundColor(color)
                
        }
    }
}

struct ColorButton: View {
    let action: () -> Void
    let buttonText: String
    let color: Color

    let width: CGFloat = 150
    let height: CGFloat = 75

    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: width, height: height)
                .background(color)
                .cornerRadius(height / 2)
        }
        .padding(.bottom, 20)
    }
}

struct LeftNavigationButton: View {
    let action: () -> Void
    let imageName: String
    let buttonText: String
    let imageInvisible: Bool
    let textInvisible: Bool
    
    let buttonSize: CGFloat = 20

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundColor(imageInvisible ? Color.clear : Colors.snow)
                if !buttonText.isEmpty {
                    Text(buttonText)
                        .font(.custom("Baloo2-SemiBold", size: 20))
                        .foregroundColor(textInvisible ? Color.clear : Colors.snow)
                }
            }
        }
    }
}

struct RightNavigationButton: View {
    let action: () -> Void
    let imageName: String
    let buttonText: String
    let imageInvisible: Bool
    let textInvisible: Bool
    
    let buttonSize: CGFloat = 20

    var body: some View {
        Button(action: action) {
            HStack {
                if !buttonText.isEmpty {
                    Text(buttonText)
                        .font(.custom("Baloo2-SemiBold", size: 20))
                        .foregroundColor(textInvisible ? Color.clear : Colors.snow)
                }
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundColor(imageInvisible ? Color.clear : Colors.snow)
            }
        }
    }
}

//struct RightNavigationButton<Content: View>: View {
//    let action: () -> Void
//    let imageName: String
//    let buttonText: String
//    let imageInvisible: Bool
//    let textInvisible: Bool
//    let content: () -> Content
//
//    let buttonSize: CGFloat = 20
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                if !buttonText.isEmpty {
//                    Text(buttonText)
//                        .font(.custom("Baloo2-SemiBold", size: 20))
//                        .foregroundColor(textInvisible ? Color.clear : Colors.snow)
//                }
//                Image(systemName: imageName)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: buttonSize, height: buttonSize)
//                    .foregroundColor(imageInvisible ? Color.clear : Colors.snow)
//            }
//        }.popover(isPresented: .constant(true), content: content)
//    }
//}


struct PanelButton: View {
    let action: () -> Void
    let systemImage: String
    let color: Color

    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(color)
        }
        .padding(.top, 10)
        .padding(.leading, 30)
    }
}
