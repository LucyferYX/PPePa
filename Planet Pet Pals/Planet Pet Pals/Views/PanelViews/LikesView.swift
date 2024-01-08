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
                    HStack {
                        Text("Your liked post count: ")
                            .padding(.trailing)
                        Text("\(postCount)")
                    }
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(Color("Linen"))
                    .padding(.vertical)
                    .lineSpacing(0)
                    .multilineTextAlignment(.center)
                    Text("Swipe left to remove")
                        .font(.custom("Baloo2-SemiBold", size: 20))
                        .foregroundColor(Color("Linen"))
                        .foregroundColor(.secondary)
                        .lineSpacing(0)
                        .multilineTextAlignment(.center)
                    List {
                        ForEach(likedPostsViewModel.userLikedPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true, showContext: true)
                                .listRowBackground(Color("Walnut"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Color("Walnut"))
                    .scrollContentBackground(.hidden)
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
