//
//  ProfileView.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showProfileView: Bool
//    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImages: [String] = []
    
    let postOptions: [String] = ["cat", "dog", "mouse"]
    private func postSelected(text: String) -> Bool {
        viewModel.user?.favorites?.contains(text) == true
    }

    var body: some View {
        VStack {
            NavigationBar()
            
            List {
                if let user = viewModel.user {
                    
                    
                    if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = photoUrl
                            }) {
                                Label("Copy URL", systemImage: "doc.on.doc")
                            }
                        }
                        Text(photoUrl)
                    }
                    
                    // MARK: User ID
                    Text("User id: \(user.userId)")
                    
                    if let isAnonymous = user.isAnonymous {
                        Text("Is anonymous: \(isAnonymous.description.capitalized)")
                    }
                    
                    Button {
                        viewModel.togglePremiumStatus()
                    } label: {
                        Text("User is premium: \((user.isAdmin ?? false).description.capitalized)")
                    }
                    
                    VStack {
                        HStack {
                            ForEach(postOptions, id: \.self) { string in
                                Button(string) {
                                    if postSelected(text: string) {
                                        viewModel.removeUserFavorites(text: string)
                                    } else {
                                        viewModel.addUserFavorites(text: string)
                                    }
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                                .tint(postSelected(text: string) ? .green : .red)
                            }
                        }
                    }
                    Text("User favorites: \((user.favorites ?? []).joined(separator: ", "))")
                    
//                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
//                        Text("Select a photo")
//                    }
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
                            Text(imageName)
                        }
                    }
                }
            }
            .task {
                do {
                    try await viewModel.loadCurrentUser()
                } catch {
                    print("Failed to load user: \(error)")
                }
            }
//            .onChange(of: selectedItem, perform: { newValue in
//                if let newValue {
//                    viewModel.saveProfileImage(item: newValue)
//                }
//            })
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

extension ProfileView {
    func NavigationBar() -> some View {
        MainNavigationBar(
            title: "Profile",
            leftButton: LeftNavigationButton(
                action: { self.showProfileView = false },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: false
            ),
            rightButton: RightNavigationButton(
                action: {  },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: true,
                textInvisible: true
            )
        )
    }
}
