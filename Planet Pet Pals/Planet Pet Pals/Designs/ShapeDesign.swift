//
//  ShapeDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 03/12/2023.
//

import SwiftUI

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Colors.linen)
            .frame(height: 2)
            .padding(.vertical)
    }
}
