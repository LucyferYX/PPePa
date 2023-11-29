//
//  MeView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 08/10/2023.
//

import SwiftUI

struct MenuContent: View {
    var body: some View {
        List {
            Text("My Profile").onTapGesture {
                print("My Profile")
            }
            Text("Posts").onTapGesture {
                print("Posts")
            }
            Text("Logout").onTapGesture {
                print("Logout")
            }
        }
    }
}

struct MeView: View {
    let width: CGFloat
    let showMeView: Bool
    let closeMeView: () -> Void
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.gray.opacity(showMeView ? 0.3 : 0.0))
            .onTapGesture {
                withAnimation(.easeIn.delay(0.25)) {
                    self.closeMeView()
                }
            }
            
            HStack {
                MenuContent()
                    .frame(width: self.width)
                    .background(Color.white)
                    .offset(x: showMeView ? 0 : -self.width)
                
                Spacer()
            }
        }
    }
}
