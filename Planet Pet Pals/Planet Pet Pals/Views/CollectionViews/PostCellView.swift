//
//  PostCellView.swift
//  Planet Pet Pals
//
//  Created by Liene on 21/12/2023.
//

import SwiftUI

struct PostCellView: View {
    @StateObject var likedPostsViewModel = LikedPostsViewModel.shared
    
    @State private var isLiked: Bool = false
    @State private var likedPostId: String? = nil
    @State private var showLikeAnimation: Bool = false
    @State private var showMessage: Bool = false

    let post: Post
    let showLikeButton: Bool

    var body: some View {
        HStack {

            AsyncImage(url: URL(string: post.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 70)
            .shadow(color: Colors.walnut.opacity(0.3), radius: 4, x: 0, y: 2)


            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(post.description)
                Label {
                    Text(post.type)
                } icon: {
                    Image(systemName: "pawprint.fill")
                }
                Text("Likes: \(post.likes ?? 0)")
            }
            .foregroundColor(.secondary)
            
            if showLikeButton {
                Button(action: {
                    if isLiked {
                        print("This post has already been liked: : \(post.postId)")
                    } else {
                        likedPostsViewModel.addUserLikedPost(postId: post.id)
                        isLiked = true
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showLikeAnimation = true
                        }
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showMessage = false
                        }
                        print("You liked post: \(post.postId)")
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .scaleEffect(showLikeAnimation ? 1.5 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: showLikeAnimation)
                }
                .onAppear {
                    Task {
                        isLiked = likedPostsViewModel.isPostLiked(postId: post.id)
                        likedPostId = likedPostsViewModel.getLikedPostId(postId: post.id)
                    }
                }
                .onReceive(likedPostsViewModel.$userLikedPosts) { _ in
                    Task {
                        isLiked = likedPostsViewModel.isPostLiked(postId: post.id)
                    }
                }
            }

            if showMessage {
                withAnimation(.easeInOut(duration: 0.5)) {
                    Text("Post liked!")
                        .transition(.move(edge: .bottom))
                }
            }

        }
    }
}


struct PostCellViewBuilder: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var post: Post? = nil
    let postId: String
    let showLikeButton: Bool
    
    var body: some View {
        ZStack {
            if let post {
                PostCellView(post: post, showLikeButton: showLikeButton)
            }
        }
        .task {
            self.post = try? await PostManager.shared.getPost(postId: postId)
        }
    }
}
