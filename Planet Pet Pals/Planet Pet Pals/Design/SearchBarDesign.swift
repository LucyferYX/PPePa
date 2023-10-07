//
//  SearchBarDesign.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 07/10/2023.
//

import SwiftUI

struct MainSearchBar: View {
    @Binding var text: String
    var body: some View {
        TextField("Search", text: $text)
            // Height
            .padding(12)
            //.font(Font.custom("YourFontName", size: 18))
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.brown)
                        .padding(.horizontal, 10)
                }
            )
            .padding(.horizontal, 20)
    }
}


//var body: some View {
//    HStack {
//        TextField("Search", text: $text)
//            .padding(10)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//            .padding(.horizontal, 10)
//        Image(systemName: "magnifyingglass")
//            .foregroundColor(.brown)
//    }
//    .frame(height: 50)
//}
