//
//  MyPostsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 03/01/2024.
//

import SwiftUI

struct MyPostsView: View {
    @StateObject private var viewModel = MyPostsViewModel()
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
                        Text("Your post count: ")
                            .padding(.trailing)
                        Text("\(postCount)")
                    }
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
                    .lineSpacing(0)
                    .multilineTextAlignment(.center)
                    Text("Swipe left to delete")
                        .font(.custom("Baloo2-SemiBold", size: 20))
                        .foregroundColor(Color("Linen"))
                        .foregroundColor(.secondary)
                        .lineSpacing(0)
                        .multilineTextAlignment(.center)
                    List {
                        ForEach(viewModel.myPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true, showContext: false)
                                .listRowBackground(Color("Linen"))
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Color("Walnut"))
                    .scrollContentBackground(.hidden)
                }
            } else {
                Text("No created posts yet.")
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
            }
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "MyPostsView", key: "currentView")
            viewModel.addListenerForMyPosts()
            viewModel.getPosts()
            postCount = viewModel.myPosts.count
            print("My posts listener is turned on")
        }
        .onReceive(viewModel.$myPosts) { posts in
            postCount = posts.count
        }
        .onDisappear {
            viewModel.removeListenerForMyPosts()
            print("My posts listener is turned off")
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let postId = viewModel.myPosts[index].postId
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
