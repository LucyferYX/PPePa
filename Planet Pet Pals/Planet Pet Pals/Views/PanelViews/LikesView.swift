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
    
    init() {
       UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
       UITableView.appearance().backgroundColor = .green
    }

    var body: some View {
        ZStack {
            Colors.walnut.ignoresSafeArea()
            VStack {
                Text("Your liked posts")
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
                .onAppear {
                    viewModel.getLikes()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Please Wait"), message: Text("Please wait a moment before deleting another post."), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        if deletionAllowed {
            for index in offsets {
                let postId = likedPostsViewModel.userLikedPosts[index].id
                print("Deleting post with ID: \(postId)")
                viewModel.removeFromLikes(likedPostId: postId)
            }
            deletionAllowed = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                deletionAllowed = true
            }
        } else {
            showAlert = true
        }
    }
}
