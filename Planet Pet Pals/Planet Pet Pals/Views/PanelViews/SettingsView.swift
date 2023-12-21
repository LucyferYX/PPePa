//
//  SettingsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 20/12/2023.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectedRegion") var selectedRegion: String = "Europe"

    var body: some View {
        NavigationView {
            ZStack {
                MainBackground()
                VStack {
                    Picker("Select Region", selection: $selectedRegion) {
                        ForEach(regions.keys.sorted(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }
}
