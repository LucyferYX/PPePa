//
//  ListDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/12/2023.
//

import SwiftUI

struct CellView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(Colors.walnut)
            Text("Placeholder")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .foregroundColor(Colors.walnut)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Colors.walnut)
        }
        .padding()
        .background(Colors.linen)
        .cornerRadius(40)
    }
}
