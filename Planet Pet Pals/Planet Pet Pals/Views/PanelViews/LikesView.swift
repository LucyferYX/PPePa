//
//  LikesView.swift
//  Planet Pet Pals
//
//  Created by Liene on 20/12/2023.
//

import SwiftUI

@MainActor
final class LikesViewModel: ObservableObject {
    @Published private(set) var userLikedPosts: [UserLikedPost] = []
    
    func getLikes() {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            self.userLikedPosts = try await UserManager.shared.getAllUserLikes(userId: authDataResult.uid)
        }
    }
    
    func removeFromLikes(likedPostId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeUserLikedPost(userId: authDataResult.uid, likedPostId: likedPostId)
            getLikes()
        }
    }
}

struct LikesView: View {
    @StateObject private var viewModel = LikesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.userLikedPosts, id: \.id.self) { post in
                PostCellViewBuilder(postId: post.postId)
                    .contextMenu {
                        Button("Remove from likes") {
                            viewModel.removeFromLikes(likedPostId: post.id)
                        }
                    }
            }
        }
        .onAppear {
            viewModel.getLikes()
        }
    }
}
