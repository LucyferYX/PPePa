//
//  ProfileViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/12/2023.
//

import SwiftUI
import PhotosUI

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
    
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else {return}
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("Success \(path) and \(name)")
//            try await UserManager.shared.update
        }
    }
}
