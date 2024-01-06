//
//  ReportedPostsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI

@MainActor
final class ReportedPostsViewModel: ObservableObject {
    @Published var reportedPosts: [Post] = []
    
    func deletePost(postId: String) async throws {
        try await PostManager.shared.deletePost(postId: postId)
    }

    func addListenerForReportedPosts() {
        PostManager.shared.addListenerForReportedPosts { [weak self] posts in
            self?.reportedPosts = posts
        }
    }

    func removeListenerForReportedPosts() {
        PostManager.shared.removeListenerForReportedPosts()
    }
    
    func undoReportPost(postId: String) async throws {
        try await PostManager.shared.updatePostReportStatus(postId: postId, isReported: false)
    }
}
