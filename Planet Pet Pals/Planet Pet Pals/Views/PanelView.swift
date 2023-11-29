//
//  PanelView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 08/10/2023.
//

import SwiftUI

struct PanelContent: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button("My Profile") {
                    print("My Profile")
                }
                Button("Posts") {
                    print("Posts")
                }
                Button("Logout") {
                    print("Logout")
                }
            }
            .frame(height: geometry.size.height)
        }
    }
}


struct PanelView: View {
    let width: CGFloat
    let showPanelView: Bool
    let closePanelView: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                PanelContent()
                    .frame(width: self.width)
                    .background(Colors.walnut)
                    .offset(x: showPanelView ? 0 : -self.width)
                Spacer()
            }
            .background(Colors.walnut.opacity(showPanelView ? 0.5 : 0.0))
            // Closing view with tap or sliding from right side
            .onTapGesture {
                withAnimation(.easeIn.delay(0.1)) {
                    self.closePanelView()
                }
            }
            .gesture(DragGesture().onEnded { value in
                if value.translation.width < -self.width / 2 {
                    withAnimation {
                        self.closePanelView()
                    }
                }
            })
        }
    }
}
