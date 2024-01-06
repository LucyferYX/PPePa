//
//  ProfileViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/12/2023.
//

import SwiftUI
import FirebaseStorage

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DatabaseUser? = nil
    @Published var isLoading = false

    func loadCurrentUser() async throws {
        isLoading = true
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
