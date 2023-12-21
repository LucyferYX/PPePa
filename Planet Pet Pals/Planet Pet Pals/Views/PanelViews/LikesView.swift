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
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.removeFromLikes(likedPostId: likedPostsViewModel.userLikedPosts[index].id)
                        }
                    }
                }
                .background(Colors.walnut)
                .scrollContentBackground(.hidden)
                .onAppear {
                    viewModel.getLikes()
                }
            }
        }
    }
}
