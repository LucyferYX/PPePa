//
//  ReportedPostsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 02/01/2024.
//

import SwiftUI

struct ReportedPostView: View {
    @StateObject private var viewModel = ReportedPostsViewModel()
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
                        Text("Reported post count: ")
                        Text("\(postCount)")
                    }
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
                    Text("Swipe left to delete. Hold to remove report")
                        .font(.custom("Baloo2-SemiBold", size: 20))
                        .foregroundColor(Color("Linen"))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // List of posts
                    List {
                        ForEach(viewModel.reportedPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true, showContext: false)
                                .listRowBackground(Color("Walnut"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                .contextMenu{
                                    Button(action: {
                                        Task {
                                            try await viewModel.undoReportPost(postId: post.postId)
                                        }
                                    }) {
                                        Label("Remove report?", systemImage: "flag")
                                            .foregroundColor(.red)
                                    }
                                }
                        }
                        .onDelete(perform: delete)
                    }
                    .background(Color("Walnut"))
                    .scrollContentBackground(.hidden)
                }
            } else {
                Text("No reported posts yet.")
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "ReportedPostView", key: "currentView")
            viewModel.addListenerForReportedPosts()
            print("Report listener is turned on")
        }
        .onReceive(viewModel.$reportedPosts) { posts in
            postCount = posts.count
        }
        .onDisappear {
            viewModel.removeListenerForReportedPosts()
            print("Report listener is turned off")
        }
    }
    
    // Deletes post
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let postId = viewModel.reportedPosts[index].postId
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
