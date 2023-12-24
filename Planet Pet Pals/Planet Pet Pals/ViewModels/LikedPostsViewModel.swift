//
//  LikedPostsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/12/2023.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class LikedPostsViewModel: ObservableObject {
    static let shared = LikedPostsViewModel()
    @Published var userLikedPosts: [UserLikedPost] = []
    @Published var isLiked: [String: Bool] = [:]
        
    func updateUserLikedPosts(with posts: [UserLikedPost]) {
        self.userLikedPosts = posts
        self.isLiked = posts.reduce(into: [:]) { $0[$1.postId] = true }
    }
    
    func isPostLiked(postId: String) -> Bool {
        return isLiked[postId] ?? false
    }
    
    func getLikedPostId(postId: String) -> String? {
        return userLikedPosts.first(where: { $0.postId == postId })?.id
    }
    
    func addUserLikedPost(postId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.addUserLikedPost(userId: authDataResult.uid, postId: postId)
            try? await PostManager.shared.incrementLikes(postId: postId)
        }
    }
}
