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
    
    var body: some View {
        ZStack {
            MainBackground()
            VStack {
                NavigationBar()
                
                List {
                    if viewModel.user != nil {
                        // Profile information
                        userInfoView(title: "Username", value: viewModel.user?.username ?? "User")
                        userInfoView(title: "Email", value: viewModel.user?.email ?? "no email")
                        userInfoView(title: "Is anonymous", value: viewModel.user?.isAnonymous != nil ? "false" : "true")
                        userInfoView(title: "Is admin", value: viewModel.user?.isAnonymous == false ? "false" : "true")
                        userFavoritesView(favorites: viewModel.user?.favorites ?? [])
                        
                    }
                }
                .listRowBackground(Color("Linen"))
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                // Loading user from firestore
                .task {
                    do {
                        try await viewModel.loadCurrentUser()
                    } catch {
                        print("Failed to load user: \(error)")
                    }
                }
                // Loading image from storage
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


// MARK: Preview
//struct ProfilePreview: PreviewProvider {
//    static var previews: some View {
//        ProfileView(showProfileView: .constant(true))
//    }
//}


// MARK: Extension
extension ProfileView {
    func userProfileImage(url: URL) -> some View {
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
                UIPasteboard.general.string = url.absoluteString
            }) {
                Label("Copy URL", systemImage: "doc.on.doc")
            }
        }
    }
    
    func userInfoView(title: String, value: String) -> some View {
        HStack {
            Text("\(title): ")
                .font(.custom("Baloo2-Regular", size: 20))
            Text(value)
                .font(.custom("Baloo2-SemiBold", size: 20))
        }
        .foregroundColor(Color("Gondola"))
    }
    
    func userFavoritesView(favorites: [String]) -> some View {
        VStack(alignment: .leading) {
            Text("Your current favorites: ")
                .font(.custom("Baloo2-Regular", size: 20))
            Text(favorites.joined(separator: ", "))
                .font(.custom("Baloo2-SemiBold", size: 20))
        }
        .foregroundColor(Color("Gondola"))
    }
    
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
