//
//  ProfileView.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import SwiftUI
//import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showProfileView: Bool
    @State private var profileImages: [String] = []
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    var postOptions: [String] = animals
    
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
                    
                    Text("Username: \(user.username ?? "User")")
                    
                    if let isAnonymous = user.isAnonymous {
                        Text("Is anonymous: \(isAnonymous.description.capitalized)")
                    }
                    
                    Text("User is admin: \((user.isAdmin ?? false).description.capitalized)")
                    
                    FlexibleView(
                        availableWidth: UIScreen.main.bounds.width,
                        data: animals,
                        spacing: 15,
                        alignment: .leading
                    ) { item in
                        Text(item)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)

                    Text("User favorites: \((user.favorites ?? []).joined(separator: ", "))")
                    
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
