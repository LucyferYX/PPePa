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
                    VStack {
                        PawButton(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, color: Color("Salmon"))
                        .padding(.bottom, 30)
                    }
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            VStack {
                                // MARK: Agreement
                                Text("As a user I agree to:")
                                    .font(.custom("Baloo2-Bold", size: 30))
                                    .padding(.top)
                                HStack {
                                    CheckmarkButton()
                                    Text("Be respectful")
                                        .font(.custom("Baloo2-SemiBold", size: 25))
                                }
                                HStack {
                                    CheckmarkButton()
                                    Text("Follow the rules")
                                        .font(.custom("Baloo2-SemiBold", size: 25))
                                }
                                HStack {
                                    CheckmarkButton()
                                    Text("Enjoy the app")
                                        .font(.custom("Baloo2-SemiBold", size: 25))
                                }
                            }
                            
                            Line()
                                .padding()
                            
                            //MARK: Credits
                            VStack(spacing: 0) {
                                Text("Credits")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                
                                HStack {
                                    Text("Font:")
                                        .font(.custom("Baloo2-SemiBold", size: 20))
                                    Button(action: {
                                        if let url = URL(string: "https://fonts.google.com/specimen/Baloo+2") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("Baloo 2 by Ek Type")
                                            .font(.custom("Baloo2-Regular", size: 20))
                                            .foregroundColor(Color("Gondola"))
                                            .underline()
                                    }
                                }
                                
                                HStack {
                                    Text("Profile images:")
                                        .font(.custom("Baloo2-SemiBold", size: 20))
                                    Button(action: {
                                        if let url = URL(string: "https://www.freepik.com/free-vector/people-avatars-cartoon-style_7149994.htm?query=round%20pet%20profile#from_view=detail_alsolike") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("Freepik")
                                            .font(.custom("Baloo2-Regular", size: 20))
                                            .foregroundColor(Color("Gondola"))
                                            .underline()
                                    }
                                }
                            }
                            
                            Line()
                                .padding()
                            
                            // MARK: Policies
                            VStack(spacing: 0) {
                                Text("Privacy Policy")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                Text("We value Your privacy and safety.\nYour email address is stored for authentication purposes.\nPlease refrain from uploading sensitive personal information.")
                                    .font(.custom("Baloo2-Regular", size: 20))
                                    .padding(.bottom)
                                
                                Text("Terms of Service")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                Text("Users are expected to behave respectfully and not upload any.\nThe app developers reserve the right to suspend or terminate accounts that are found to be in violation of our community guidelines.")
                                    .font(.custom("Baloo2-Regular", size: 20))
                            }
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            
                            Line()
                                .padding()
                            
                            //MARK: Development
                            VStack(spacing: 0) {
                                Text("Development")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                HStack {
                                    Text("Developer:")
                                        .font(.custom("Baloo2-SemiBold", size: 20))
                                    Text("Liene Krista Neimane.")
                                        .font(.custom("Baloo2-Regular", size: 20))
                                }
                                .padding(.bottom)
                                Text("This app was developed as a part of the ‘Qualification Project’ course.")
                                    .font(.custom("Baloo2-Regular", size: 20))
                            }
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            
                            Line()
                                .padding()
                            
                            //MARK: Version
                            Text("App Version: \(getAppVersion())")
                                .font(.custom("Baloo2-Regular", size: 20))
                        }
                        .foregroundColor(Color("Gondola"))
                    }
                }
            }
        }
        .onAppear() {
            CrashlyticsManager.shared.setValue(value: "AboutView", key: "currentView")
        }
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unable to fetch for now"
    }
}
