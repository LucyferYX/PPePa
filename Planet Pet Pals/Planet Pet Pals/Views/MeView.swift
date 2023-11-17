//
//  MeView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 08/10/2023.
//

import SwiftUI

struct MeView: View {
    @Binding var show: Bool

    var body: some View {
        VStack (alignment: .leading) {
            Button (action: {
                withAnimation {
                    self.show = false
                }
            }) {
                HStack {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                    Text("close menu")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .padding(.leading, 15.0)
                }
            }.padding(.top, 20)
            Divider().foregroundColor(.white)
            Button(action: {
                // TODO: Add action for Button 1
            }) {
                Text("Button 1")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
            }.padding(.top, 30)
            Button(action: {
                // TODO: Add action for Button 2
            }) {
                Text("Button 2")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
            }.padding(.top, 30)
            // Add more buttons, labels, lists, etc. here
            Spacer()
        }.padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}
