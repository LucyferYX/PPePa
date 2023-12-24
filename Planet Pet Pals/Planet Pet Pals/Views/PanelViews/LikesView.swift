//
//  LikesView.swift
//  Planet Pet Pals
//
//  Created by Liene on 20/12/2023.
//

import SwiftUI

struct LikesView: View {
    @StateObject private var viewModel = LikesViewModel()
    @StateObject var likedPostsViewModel = LikedPostsViewModel.shared
    
    @State private var deletionAllowed = true
    @State private var showAlert = false
    
    @State private var didAppear = false
    @State private var postCount: Int = 0
    
    init() {
       UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
       UITableView.appearance().backgroundColor = .green
    }

    var body: some View {
        ZStack {
            Colors.walnut.ignoresSafeArea()
            if postCount > 0 {
                VStack {
                    Text("Your liked post count: \(postCount)")
                        .font(.custom("Baloo2-SemiBold", size: 30))
                        .foregroundColor(Colors.linen)
                        .padding(.top)
                    List {
                        ForEach(likedPostsViewModel.userLikedPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true)
                                .listRowBackground(Colors.linen)
                                .buttonStyle(.borderless)
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Colors.walnut)
                    .scrollContentBackground(.hidden)
                    // 1 second until another post is deleted
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Please Wait"), message: Text("Please wait a moment before deleting another post."), dismissButton: .default(Text("OK")))
                    }
                    .onChange(of: likedPostsViewModel.userLikedPosts) { _ in
                        postCount = likedPostsViewModel.userLikedPosts.count
                    }
                }
            } else {
                Text("No liked posts yet.")
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Colors.linen)
                    .padding(.top)
            }
        }
        .onAppear {
            if !didAppear {
                viewModel.addListenerForLikes()
                postCount = likedPostsViewModel.userLikedPosts.count
                didAppear = true
            }
        }
        .onReceive(likedPostsViewModel.$userLikedPosts) { posts in
            postCount = posts.count
        }

    }

    func delete(at offsets: IndexSet) {
        if deletionAllowed {
            for index in offsets {
                let postId = likedPostsViewModel.userLikedPosts[index].id
                print("Deleted post with ID: \(postId)")
                viewModel.removeFromLikes(likedPostId: postId)
            }
            deletionAllowed = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                deletionAllowed = true
            }
        } else {
            showAlert = true
            print("Deleting post is happening too quick.")
        }
    }
}
