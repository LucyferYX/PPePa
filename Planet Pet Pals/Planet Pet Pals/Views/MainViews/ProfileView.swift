//
//  ProfileView.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import SwiftUI

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
        ZStack {
            MainBackground()
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
                        }
                        
                        HStack {
                            Text("Username: ")
                                .font(.custom("Baloo2-Regular", size: 20))
                            Text("\(user.username ?? "User")")
                                .font(.custom("Baloo2-SemiBold", size: 20))
                        }
                        .foregroundColor(Color("Gondola"))
                        
                        HStack {
                            Text("Your email: ")
                                .font(.custom("Baloo2-Regular", size: 20))
                            Text("\(user.email ?? "no email")")
                                .font(.custom("Baloo2-SemiBold", size: 20))
                        }
                        .foregroundColor(Color("Gondola"))
                        
                        HStack {
                            Text("Is anonymous: ")
                                .font(.custom("Baloo2-Regular", size: 20))
                            if user.isAnonymous != nil {
                                Text("false")
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                            } else {
                                Text("true")
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                            }
                        }
                        .foregroundColor(Color("Gondola"))
                        
                        HStack {
                            Text("Your current favorites: ")
                                .font(.custom("Baloo2-Regular", size: 20))
                            Text("\((user.favorites ?? []).joined(separator: ", "))")
                                .font(.custom("Baloo2-SemiBold", size: 20))
                        }
                        .foregroundColor(Color("Gondola"))
                        
                    }
                }
                .listRowBackground(Color("Linen"))
                .background(Color.clear)
                .scrollContentBackground(.hidden)
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
        .onAppear() {
            CrashlyticsManager.shared.setValue(value: "ProfileView", key: "currentView")
        }
    }
}


struct ProfilePreview: PreviewProvider {
    static var previews: some View {
        ProfileView(showProfileView: .constant(true))
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
