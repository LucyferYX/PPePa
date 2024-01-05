//
//  ReportedPostsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 02/01/2024.
//

import SwiftUI

@MainActor
final class ReportedPostsViewModel: ObservableObject {
    @Published var reportedPosts: [Post] = []
    
    func deletePost(postId: String) async throws {
        try await PostManager.shared.deletePost(postId: postId)
    }

    func addListenerForReportedPosts() {
        PostManager.shared.addListenerForReportedPosts { [weak self] posts in
            self?.reportedPosts = posts
        }
    }

    func removeListenerForReportedPosts() {
        PostManager.shared.removeListenerForReportedPosts()
    }
    
    func undoReportPost(postId: String) async throws {
        try await PostManager.shared.updatePostReportStatus(postId: postId, isReported: false)
    }
}


struct ReportedPostView: View {
    @StateObject private var viewModel = ReportedPostsViewModel()
    @State private var postCount: Int = 0
    @State private var post: Post? = nil
    
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
                    Text("Reported post count: \(postCount)")
                        .font(.custom("Baloo2-SemiBold", size: 30))
                        .foregroundColor(Color("Linen"))
                        .padding(.top)
                    Text("Swipe left to delete. Hold to remove report")
                        .font(.custom("Baloo2-SemiBold", size: 25))
                        .foregroundColor(Color("Linen"))
                        .foregroundColor(.secondary)
                    List {
                        ForEach(viewModel.reportedPosts, id: \.id.self) { post in
                            PostCellViewBuilder(postId: post.postId, showLikeButton: false, showLikes: true, showContext: false)
                                .listRowBackground(Color("Linen"))
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
                }
            } else {
                Text("No reported posts yet.")
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .foregroundColor(Color("Linen"))
                    .padding(.top)
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
