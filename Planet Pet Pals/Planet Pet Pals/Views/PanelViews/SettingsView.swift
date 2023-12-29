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
                    
                    regionPicker
                    
                    themeToggle
                    
                    Button("Crash 1!") {
                        let myString: String? = nil
                        let string2 = myString!
                    }
                    
                    Button("Crash 2!") {
                        fatalError("This was fatal crash")
                    }
                    
                    
                }
            }
        }
        .onChange(of: appTheme) { newValue in
            applyTheme(appTheme: newValue)
        }
    }
}


struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


extension SettingsView {
    private var themeToggle: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(appTheme == .light ? .primary : .secondary)
            
            Spacer()
            
            Toggle(isOn: Binding(
                get: { appTheme == .dark },
                set: { newValue in appTheme = newValue ? .dark : .light }
            )) {
                Text("Dark Mode")
            }
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            
            Spacer()
            
            Image(systemName: "moon.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(appTheme == .dark ? .primary : .secondary)
        }
        .padding()
    }

//    private var themeToggle: some View {
//        HStack {
//            Image(systemName: "sun.max.fill")
//                .foregroundColor(appTheme == .light ? .primary : .secondary)
//            Toggle(isOn: Binding(
//                get: { appTheme == .dark },
//                set: { newValue in appTheme = newValue ? .dark : .light }
//            )) {
//                Text("Dark Mode")
//            }
//            Image(systemName: "moon.fill")
//                .foregroundColor(appTheme == .dark ? .primary : .secondary)
//        }
//    }

    private var regionPicker: some View {
        Picker("Select Region", selection: $selectedRegion) {
            ForEach(regions.keys.sorted(), id: \.self) { key in
                Text(key).tag(key)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    func applyTheme(appTheme: AppTheme) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            switch appTheme {
            case .light:
                scene.windows.first?.overrideUserInterfaceStyle = .light
            case .dark:
                scene.windows.first?.overrideUserInterfaceStyle = .dark
            }
        }
    }
}



enum AppTheme: String {
    case light, dark
}
