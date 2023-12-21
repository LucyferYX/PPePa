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
                    
                    Text("App Version: \(getAppVersion())")
                }
            }
        }
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
}
