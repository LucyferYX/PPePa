//
//  DeletedPostsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI

@MainActor
final class DeletedUserPostsViewModel: ObservableObject {
    @Published var deletedUsersPosts: [Post] = []
    
    func deletePost(postId: String) async throws {
        try await PostManager.shared.deletePost(postId: postId)
    }
    
    func addListenerForDeletedUsersPosts() {
        PostManager.shared.addListenerForDeletedUsersPosts { [weak self] posts in
            self?.deletedUsersPosts = posts
        }
    }
    
    func removeListenerForDeletedUsersPosts() {
        PostManager.shared.removeListenerForDeletedUsersPosts()
    }
}
