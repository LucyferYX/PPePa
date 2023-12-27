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
    @AppStorage("appTheme") private var appTheme: AppTheme = .light

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
                    
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(appTheme == .light ? .primary : .secondary)
                        Toggle(isOn: Binding(
                            get: { appTheme == .dark },
                            set: { newValue in appTheme = newValue ? .dark : .light }
                        )) {
                            Text("Dark Mode")
                        }
                        Image(systemName: "moon.fill")
                            .foregroundColor(appTheme == .dark ? .primary : .secondary)
                    }
                    
                }
            }
        }
        .onChange(of: appTheme) { newValue in
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                switch newValue {
                case .light:
                    scene.windows.first?.overrideUserInterfaceStyle = .light
                case .dark:
                    scene.windows.first?.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }
}

enum AppTheme: String {
    case light, dark
}
