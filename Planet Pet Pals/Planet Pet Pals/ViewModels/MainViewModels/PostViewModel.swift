//
//  PostViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 05/01/2024.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class PostViewModel: ObservableObject {
    @Published private(set) var post: Post? = nil
    @Published private(set) var user: DBUserModel? = nil
    private var postListener: ListenerRegistration?
    @Published var isLoading = false

    func loadPost(postId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        self.post = try await PostManager.shared.getPost(postId: postId)
        if let userId = post?.userId {
            do {
                self.user = try await UserManager.shared.getUser(userId: userId)
                print("Gotten user: \(user?.username ?? "Unknown name")")
            } catch {
                print("Failed to load user: \(error)")
            }
        }
    }
    
    func addListenerForPost(postId: String) {
        PostManager.shared.addListenerForPost(postId: postId) { [weak self] post in
            DispatchQueue.main.async {
                self?.post = post
            }
        }
    }

    func removeListenerForPost() {
        PostManager.shared.removeListenerForPost()
    }
}
