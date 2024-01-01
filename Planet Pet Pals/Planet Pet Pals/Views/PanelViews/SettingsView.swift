//
//  SettingsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 20/12/2023.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("appTheme") private var appTheme: AppTheme = .light
    @AppStorage("selectedRegion") var selectedRegion: String = "Europe"
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    
    @State private var showProfileSettingsView: Bool = false
    @State private var showSignInView = false

    var body: some View {
        NavigationView {
            ZStack {
                MainBackground()
                VStack(spacing: 0) {
                    VStack {
                        PawButton(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, color: Color("Salmon"))
                        .padding(.bottom, 30)
                    }
                    
                    ScrollView() {
                        VStack(spacing: 0) {
                            themeToggle
                            
                            Line()
                                .padding(.horizontal)
                            
                            regionPicker

                            Line()
                                .padding(.horizontal)
                            
                            languagePicker
                            
                            Line()
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showProfileSettingsView = true
                                }
                            }) {
                                Text("Open Profile Settings")
                            }
                            .sheet(isPresented: $showProfileSettingsView) {
                                ProfileSettingsView(showSignInView: $showSignInView)
                            }
                            
                            Button("Press to fatal crash!") {
                                fatalError("This was fatal crash")
                            }
                            .accentColor(.red)
                            .padding()
                        }
                    }
                }
                .environment(\.locale, .init(identifier: selectedLanguage))
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
        VStack(spacing: 0) {
            Text(appTheme == .dark ? "Dark mode" : "Light mode")
                .font(.custom("Baloo2-SemiBold", size: 25))
            HStack {
                Toggle(isOn: Binding(
                    get: { self.appTheme == .dark },
                    set: { newValue in self.appTheme = newValue ? .dark : .light }
                )) {
                    Image(systemName: "sun.max.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(appTheme == .light ? .orange : .secondary.opacity(0.5))
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .frame(width: 100)
                .padding(.trailing)
                
                Image(systemName: "moon.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(appTheme == .dark ? .yellow : .secondary.opacity(0.5))
            }
            .padding()
        }
    }
    
    private var regionPicker: some View {
        VStack(spacing: 0) {
            Text("Preferred region")
                .font(.custom("Baloo2-SemiBold", size: 25))
            Menu {
                Picker("Select Region", selection: $selectedRegion) {
                    ForEach(regions.keys.sorted(), id: \.self) { key in
                        Text(key)
                            .tag(key)
                    }
                }
            } label: {
                HStack {
                    Text(selectedRegion)
                        .font(.custom("Baloo2-Regular", size: 25))
                        .foregroundColor(Color("Gondola"))
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(Color("Gondola"))
                }
            }
        }
    }
    
    private var languagePicker: some View {
        VStack(spacing: 0) {
            Text("App language")
                .font(.custom("Baloo2-SemiBold", size: 25))
            Menu {
                Picker("Select Language", selection: $selectedLanguage) {
                    Text("English").tag("en")
                    Text("Latvian").tag("lv")
                }
            } label: {
                HStack {
                    Text(selectedLanguage)
                        .font(.custom("Baloo2-Regular", size: 25))
                        .foregroundColor(Color("Gondola"))
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(Color("Gondola"))
                }
            }
        }
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
