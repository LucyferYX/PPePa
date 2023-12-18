//
//  ExtraPanelView.swift
//  Planet Pet Pals
//
//  Created by Liene on 04/12/2023.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                MainBackground()
                VStack {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding()
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

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

