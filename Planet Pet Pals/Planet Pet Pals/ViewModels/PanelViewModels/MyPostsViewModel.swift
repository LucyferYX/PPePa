//
//  MyPostsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI

@MainActor
final class MyPostsViewModel: ObservableObject {
    @Published var panelViewModel = PanelViewModel()
    @Published var myPosts: [Post] = []

    func addListenerForMyPosts() {
        let userId = panelViewModel.authUser?.uid ?? ""
        PostManager.shared.addListenerForMyPosts(userId: userId) { [weak self] posts in
            self?.myPosts = posts
        }
    }

    func removeListenerForMyPosts() {
        PostManager.shared.removeListenerForMyPosts()
    }
    
    func deletePost(postId: String) async throws {
        try await PostManager.shared.deletePost(postId: postId)
    }
}
