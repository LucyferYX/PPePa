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
                ScrollView {
                    VStack(spacing: 0) {
                        PawButton(action: {
//                            showAboutView = false
                            presentationMode.wrappedValue.dismiss()
                        }, color: Color("Salmon"))
                        
                        Text("As a user I agree to:")
                            .font(.custom("Baloo2-Bold", size: 30))
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Be respectful")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Follow the rules")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Enjoy the app")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                        }
                        
                        Line()
                            .padding()
                        
                        VStack(spacing: 0) {
                            Text("Privacy Policy")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                            Text("We collect and store your email address for authentication purposes.\nWe do not share your data with third parties.")
                                .font(.custom("Baloo2-Regular", size: 20))
                                .padding(.bottom)
                            
                            Text("Terms of Service")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                            Text("Users are expected to behave respectfully. Any form of harassment will result in account suspension.")
                                .font(.custom("Baloo2-Regular", size: 20))
                        }
                        .padding(.horizontal)
                        
                        Line()
                            .padding()
                        
                        Text("App Version: \(getAppVersion())")
                            .font(.custom("Baloo2-Regular", size: 20))
                    }
                    .foregroundColor(Color("Gondola"))
                }
            }
        }
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unable to fetch for now"
    }
}


struct AboutViewPreviews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
