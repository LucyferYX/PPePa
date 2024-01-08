//
//  TransitionExtension.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI

struct SlideInTransition: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .animation(.easeInOut)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            .zIndex(isActive ? 1 : 0)
    }
}

extension AnyTransition {
    static var slideIn: AnyTransition {
        .modifier(active: SlideInTransition(isActive: true), identity: SlideInTransition(isActive: false))
    }
}
