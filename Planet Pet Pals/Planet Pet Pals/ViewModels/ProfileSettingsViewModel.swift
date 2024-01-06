//
//  ProfileSettingsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI
import FirebaseStorage

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    @Published var authUser: AuthDataResultModel? = nil
    @Published private(set) var user: DatabaseUser? = nil
    
    @Published var username: String = ""
    
    func changeUsername() async {
        guard let userId = authUser?.uid else { return }
        do {
            try await UserManager.shared.updateUsername(userId: userId, newUsername: username)
        } catch {
            print("Failed to update username: \(error)")
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthManager.shared.getAuthenticatedUser()
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    private func postSelected(text: String) -> Bool {
        user?.favorites?.contains(text) == true
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
    
    func updateProfileImage(imageName: String) async throws {
        guard let user = user else { return }
        let imageRef = Storage.storage().reference().child("Profile/\(imageName)")
        let newPhotoUrl = await self.getDownloadUrl(from: imageRef)
        try await UserManager.shared.updateUserPhotoUrl(userId: user.userId, photoUrl: newPhotoUrl)
        self.user = try await UserManager.shared.getUser(userId: user.userId)
    }
    
    private func getDownloadUrl(from reference: StorageReference) async -> String {
        return await withCheckedContinuation { continuation in
            reference.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error as! Never)
                } else if let url = url {
                    continuation.resume(returning: url.absoluteString)
                }
            }
        }
    }
}
