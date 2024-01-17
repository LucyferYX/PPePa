//
//  ProfileSettingsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 05/01/2024.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ProfileSettingsViewModel()
    
    @State private var profileImages: [String] = []
    
    private func postSelected(text: String) -> Bool {
        viewModel.user?.favorites?.contains(text) == true
    }
    
    var body: some View {
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
                        if let user = viewModel.user {
                            
                            // Changing user's username
                            VStack {
                                Text("Change username")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                    .foregroundColor(Color("Gondola"))
                                
                                LimitedTextField(text: $viewModel.username, maxLength: 20, title: "Username")
                                    .padding(.horizontal, 50)
                                
                                Line3()
                                
                                Button(action: {
                                    Task {
                                        await viewModel.changeUsername()
                                        print("Changed username to: \(viewModel.username)")
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    Text("Set new username")
                                        .font(.custom("Baloo2-SemiBold", size: 20))
                                        .foregroundColor(Color("Gondola"))
                                }
                            }
                            
                            Line()
                                .padding()
                            
                            // Changing user's profile picture
                            Text("Change profile picture")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                                .foregroundColor(Color("Gondola"))
                                .padding(.bottom)
                            
                            if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .shadow(radius: 10)
                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(.bottom)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = photoUrl
                                    }) {
                                        Label("Copy URL", systemImage: "doc.on.doc")
                                    }
                                }
                            }
                            
                            ForEach(profileImages, id: \.self) { imageName in
                                Button(action: {
                                    Task {
                                        do {
                                            try await viewModel.updateProfileImage(imageName: imageName)
                                        } catch {
                                            print("Failed to update profile image: \(error)")
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Change to: ")
                                        Text("\(imageName)")
                                    }
                                    .font(.custom("Baloo2-Regular", size: 20))
                                    .foregroundColor(Color("Gondola"))
                                }
                            }
                            
                            Line()
                                .padding()
                            
                            // Changing user's favorites
                            Text("Change favorites")
                                .font(.custom("Baloo2-SemiBold", size: 25))
                                .foregroundColor(Color("Gondola"))
                                .padding(.bottom)
                            
                            FlexibleView(
                                availableWidth: UIScreen.main.bounds.width,
                                data: animals,
                                spacing: 15,
                                alignment: .leading
                            ) { item in
                                Button(action: {
                                    if postSelected(text: item) {
                                        viewModel.removeUserFavorites(text: item)
                                    } else {
                                        viewModel.addUserFavorites(text: item)
                                    }
                                }) {
                                    Text(item)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(postSelected(text: item) ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                                        )
                                }
                            }
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            
                            Text("Your current favorites: ")
                                .padding(.top)
                                .foregroundColor(Color("Gondola"))
                                .font(.custom("Baloo2-Regular", size: 20))
                            Text("\((user.favorites ?? []).joined(separator: ", "))")
                                .font(.custom("Baloo2-SemiBold", size: 20))
                                .foregroundColor(Color("Gondola"))
                        }
                    }
                }
                .onAppear {
                    CrashlyticsManager.shared.setValue(value: "ProfileSettingsView", key: "currentView")
                    viewModel.loadAuthUser()
                }
                .task {
                    do {
                        try await viewModel.loadCurrentUser()
                    } catch {
                        print("Failed to load user: \(error)")
                    }
                }
                .task {
                    do {
                        try await viewModel.loadCurrentUser()
                        profileImages = try await StorageManager.shared.getProfileImages()
                    } catch {
                        print("Failed to load user or profile images: \(error)")
                    }
                }
            }
        }
    }
}
