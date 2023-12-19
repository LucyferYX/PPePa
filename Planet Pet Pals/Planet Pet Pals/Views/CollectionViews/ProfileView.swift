//
//  ProfileView.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DatabaseUser? = nil

    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserFavorites(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.addUserFavorites(userId: user.userId, favorite: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserFavorites(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeUserFavorites(userId: user.userId, favorite: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let postOptions: [String] = ["cat", "dog", "mouse"]
    private func postSelected(text: String) -> Bool {
        viewModel.user?.favorites?.contains(text) == true
    }

    var body: some View {
        VStack {
            Button("Back") {
                showSignInView = false
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
                }
            }
            .task {
                do {
                    try await viewModel.loadCurrentUser()
                } catch {
                    print("Failed to load user: \(error)")
                }
            }
        }
    }
}