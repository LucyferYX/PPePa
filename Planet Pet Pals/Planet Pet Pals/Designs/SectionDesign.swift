//
//  SectionDesign.swift
//  Planet Pet Pals
//
//  Created by Liene on 31/12/2023.
//

import SwiftUI

struct FormSection<Content: View>: View {
    var headerText: String
    var content: Content

    init(headerText: String, @ViewBuilder content: () -> Content) {
        self.headerText = headerText
        self.content = content()
    }

    var body: some View {
        Section(header: Text(LocalizedStringKey(headerText))
            .font(.custom("Baloo2-SemiBold", size: 20))
            .foregroundColor(Color("Walnut"))
            .textCase(nil)
        ) {
            content
        }
    }
}

