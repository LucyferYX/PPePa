//
//  LikesViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/12/2023.
//

import SwiftUI

@MainActor
final class LikesViewModel: ObservableObject {
    @ObservedObject var likedPostsViewModel = LikedPostsViewModel.shared

    func addListenerForLikes() {
        guard let authDataResult = try? AuthManager.shared.getAuthenticatedUser() else { return }
        UserManager.shared.addListenerForPostsLiked(userId: authDataResult.uid) { [weak self] posts in
            self?.likedPostsViewModel.userLikedPosts = posts
        }
    }

    func getLikes() {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let likes = try await UserManager.shared.getAllUserLikes(userId: authDataResult.uid)
            self.likedPostsViewModel.updateUserLikedPosts(with: likes)
        }
    }
    
    func removeFromLikes(likedPostId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let postId = likedPostsViewModel.userLikedPosts.first(where: { $0.id == likedPostId })?.postId
            try await UserManager.shared.removeUserLikedPost(userId: authDataResult.uid, likedPostId: likedPostId)
            if let postId = postId {
                try? await PostManager.shared.decrementLikes(postId: postId)
            }
            getLikes()
        }
    }
    
    func userLikedPostCount() async throws -> Int {
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        let likes = try await UserManager.shared.getAllUserLikes(userId: authDataResult.uid)
        return likes.count
    }
}
