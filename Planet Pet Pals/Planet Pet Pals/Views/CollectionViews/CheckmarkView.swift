//
//  CheckmarkView.swift
//  Planet Pet Pals
//
//  Created by Liene on 29/12/2023.
//

import SwiftUI

struct CheckmarkButton: View {
    @State private var isChecked = true
    @State private var animate = false

    var body: some View {
        Button(action: {
            isChecked.toggle()
            if !isChecked {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        animate = false
                        isChecked = true
                    }
                }
            }
        }) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .rotationEffect(.degrees(animate ? 20 : -20))
        }
    }
}
