//
//  LaunchView.swift
//  Planet Pet Pals
//
//  Created by Liene on 17/12/2023.
//

import SwiftUI

struct LaunchView: View {
    @State private var launchText: [String] = "Planet Pet Pals".map { String($0) }
    @State private var showLaunchText: Bool = false
    @State private var counter: Int = 0
    @State private var loops: Int = 0
    @Binding var showLaunchView: Bool
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Colors.walnut
                .ignoresSafeArea()
            Image("LogoSmall")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .padding(.top, 100)
                .padding(.bottom, 300)
            
            ZStack {
                if showLaunchText {
                    HStack(spacing: 0) {
                        ForEach(launchText.indices, id: \.self) { index in
                            Text(launchText[index])
                                .font(.custom("Baloo2-Bold", size: 40))
                                .foregroundColor(Colors.snow)
                                .offset(y: counter == index ? -20 : 0)
                        }
                    }
                    .transition(AnyTransition.scale.animation(.easeIn))
                }
            }
            .offset(y: 0)
        }
        .opacity(showLaunchView ? 1 : 0)
        .animation(.easeOut(duration: 1.0), value: showLaunchView)
        .onAppear {
            showLaunchText.toggle()
        }
        .onReceive(timer, perform: { _ in
            withAnimation(.spring()) {
                let lastIndex = launchText.count - 1
                if counter == lastIndex {
                    counter = 0
                    loops += 1
                    if loops >= 2 {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            showLaunchView = false
                        }
                    }
                } else {
                    counter += 1
                }
            }
        })
    }
}

//struct LaunchPreview: PreviewProvider {
//    static var previews: some View {
//        LaunchView(showLaunchView: .constant(true))
//    }
//}
