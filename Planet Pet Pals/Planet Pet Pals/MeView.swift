//
//  MeView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 08/10/2023.
//

import SwiftUI

struct MeView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(hex: "FFAF97").edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            HStack {
                Image(systemName: "arrow.backward")
                Text("Back")
            }
        })
    }
}

#Preview {
    MeView()
}
