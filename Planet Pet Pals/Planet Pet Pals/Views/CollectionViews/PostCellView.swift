//
//  PostCellView.swift
//  Planet Pet Pals
//
//  Created by Liene on 21/12/2023.
//

import SwiftUI

struct PostCellView: View {
    @StateObject var viewModel: StatsViewModel
    @State private var isLiked: Bool = false
    @State private var likedPostId: String? = nil

    let post: Post
    
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
           
            
            Button(action: {
                if isLiked {
                    if let likedPostId = likedPostId {
                        viewModel.removeFromLikes(likedPostId: likedPostId)
                    }
                } else {
                    viewModel.addUserLikedPost(postId: post.id)
                }
                isLiked.toggle()
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .gray)
            }
            .onAppear {
                Task {
                    isLiked = await viewModel.isPostLiked(postId: post.id)
                    likedPostId = await viewModel.getLikedPostId(postId: post.id)
                }
            }
            
        }
    }
}


struct PostCellViewBuilder: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var post: Post? = nil
    let postId: String
    
    var body: some View {
        ZStack {
            if let post {
                PostCellView(viewModel: viewModel, post: post)
            }
        }
        .task {
            self.post = try? await PostManager.shared.getPost(postId: postId)
        }
    }
}
