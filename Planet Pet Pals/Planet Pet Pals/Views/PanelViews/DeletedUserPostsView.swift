//
//  DeletedUserPostsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 04/01/2024.
//

import SwiftUI

struct DeletedUserPostsView: View {
    @StateObject private var viewModel = DeletedUserPostsViewModel()
    @State private var postCount: Int = 0
    @State private var post: Post? = nil
    
    // Allows view to have entire background in selected color
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
        UITableView.appearance().backgroundColor = .green
    }
    
    var body: some View {
        ZStack {
            Color("Walnut").ignoresSafeArea()
            if postCount > 0 {
                VStack {
                    VStack {
                        Text("Deleted user post count: ")
                        Text("\(postCount)")
                    }
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
                    
                    // List of posts
                    List {
                        ForEach(viewModel.deletedUsersPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true, showContext: false)
                                .listRowBackground(Color("Walnut"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Color("Walnut"))
                    .scrollContentBackground(.hidden)
                }
            } else {
                Text("No posts from deleted users yet.")
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "DeletedUserPostsView", key: "currentView")
            viewModel.addListenerForDeletedUsersPosts()
            print("Deleted users posts listener is turned on")
        }
        .onReceive(viewModel.$deletedUsersPosts) { posts in
            postCount = posts.count
        }
        .onDisappear {
            viewModel.removeListenerForDeletedUsersPosts()
            print("Deleted users posts listener is turned off")
        }
    }
    
    // Deletes post
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let postId = viewModel.deletedUsersPosts[index].postId
            Task {
                do {
                    try await viewModel.deletePost(postId: postId)
                    print("Deleted post with ID: \(postId)")
                } catch {
                    print("Failed to delete post: \(error)")
                }
            }
        }
    }
}
