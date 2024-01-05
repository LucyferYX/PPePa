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
    
    @State private var showAlert = false
    @State private var postCount: Int = 0
    
    init() {
       UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
       UITableView.appearance().backgroundColor = .green
    }

    var body: some View {
        ZStack {
            Color("Walnut").ignoresSafeArea()
            if postCount > 0 {
                VStack(spacing: 0) {
                    Text("Your liked post count: \(postCount)")
                        .font(.custom("Baloo2-SemiBold", size: 30))
                        .foregroundColor(Color("Linen"))
                        .padding(.top)
                    Text("Swipe left to remove from likes")
                        .font(.custom("Baloo2-SemiBold", size: 25))
                        .foregroundColor(Color("Linen"))
                        .foregroundColor(.secondary)
                    List {
                        ForEach(likedPostsViewModel.userLikedPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true, showContext: true)
                                .listRowBackground(Color("Walnut"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 0))
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Color("Walnut"))
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
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
            }
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "LikesView", key: "currentView")
            viewModel.addListenerForLikes()
            postCount = likedPostsViewModel.userLikedPosts.count
            print("Likes listener is turned on")
            
        }
        .onReceive(likedPostsViewModel.$userLikedPosts) { posts in
            postCount = posts.count
        }
        .onDisappear {
            viewModel.removeListenerForLikes()
            print("Likes listener is turned off")
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let postId = likedPostsViewModel.userLikedPosts[index].id
            Task {
                viewModel.removeFromLikes(likedPostId: postId)
                print("Deleted post with ID: \(postId)")
            }
        }
    }
}
