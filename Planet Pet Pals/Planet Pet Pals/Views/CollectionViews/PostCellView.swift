//
//  PostCellView.swift
//  Planet Pet Pals
//
//  Created by Liene on 21/12/2023.
//

import SwiftUI

struct PostCellView: View {
    @StateObject var likedPostsViewModel = LikedPostsViewModel.shared
    @State private var showPostView = false
    
    @State private var isLiked: Bool = false
    @State private var likedPostId: String? = nil
    @State private var showLikeAnimation: Bool = false
    @State private var showMessage: Bool = false

    let post: Post
    let showLikeButton: Bool
    let showLikes: Bool

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    showPostView = true
                }
            HStack {
                
                AsyncImage(url: URL(string: post.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75, height: 75)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 70, height: 70)
                .shadow(color: Color("Walnut").opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.trailing)
                
                VStack(alignment: .leading, spacing: 4) {
                    if showLikes {
                        Text("Post")
                            .font(.custom("Baloo2-Regular", size: 12))
                            .opacity(0)
                    }
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .font(.custom("Baloo2-SemiBold", size: 20))
                    if showLikes {
                        Text("Likes: \(post.likes ?? 0)")
                            .font(.custom("Baloo2-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.secondary)
                
                //Spacer does not respond to tap gestures
                VStack {
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    showPostView = true
                }
                
                if showLikeButton {
                    HStack {
                        Button(action: {
                            if isLiked {
                                print("Post with ID has already been liked: \(post.postId)")
                            } else {
                                likedPostsViewModel.addUserLikedPost(postId: post.id)
                                isLiked = true
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showLikeAnimation = true
                                }
                                showMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showMessage = false
                                    }
                                }
                                print("Liked post with ID: \(post.postId)")
                            }
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .gray)
                                .animation(.easeInOut(duration: 0.2), value: showLikeAnimation)
                                .frame(width: 50, height: 50)
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
                } else {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Delete")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .font(.custom("Baloo2-SemiBold", size: 20))
                    }
                }
                
                if showMessage {
                    Text("Post liked!")
                        .transition(.move(edge: .bottom))
                        .font(.custom("Baloo2-Regular", size: 18))
                        .lineSpacing(-7)
                }

            }
            .fullScreenCover(isPresented: $showPostView) {
                PostView(showPostView: $showPostView, postId: post.postId)
            }
            .onTapGesture {
                showPostView = true
            }
            .cornerRadius(10)
            .background(Color("Linen"))
        }
    }
}


struct PostCellViewBuilder: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var post: Post? = nil
    let postId: String
    let showLikeButton: Bool
    let showLikes: Bool
    
    var body: some View {
        ZStack {
            if let post {
                PostCellView(post: post, showLikeButton: showLikeButton, showLikes: showLikes)
                    .listRowBackground(Color("Walnut"))
            }
        }
        .task {
            self.post = try? await PostManager.shared.getPost(postId: postId)
        }
    }
}
