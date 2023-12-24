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
    @State private var selectedItem: PhotosPickerItem? = nil
    
    let postOptions: [String] = ["cat", "dog", "mouse"]
    private func postSelected(text: String) -> Bool {
        viewModel.user?.favorites?.contains(text) == true
    }

    var body: some View {
        VStack {
            Button("Back") {
                showProfileView = false
            }
            .padding()
            List {
                if let user = viewModel.user {
                    
                    // MARK: User ID
                    Text("User id: \(user.userId)")
                    
                    if let isAnonymous = user.isAnonymous {
                        Text("Is anonymous: \(isAnonymous.description.capitalized)")
                    }
                    
                    Button {
                        viewModel.togglePremiumStatus()
                    } label: {
                        Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
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
                    
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Text("Select a photo")
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
            .onChange(of: selectedItem, perform: { newValue in
                if let newValue {
                    viewModel.saveProfileImage(item: newValue)
                }
            })
        }
    }
}
