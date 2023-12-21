//
//  LikesView.swift
//  Planet Pet Pals
//
//  Created by Liene on 20/12/2023.
//

import SwiftUI

@MainActor
final class LikesViewModel: ObservableObject {
    @ObservedObject var likedPostsViewModel = LikedPostsViewModel.shared

//    func addListenerForLikes() {
//        guard let authDataResult = try? AuthManager.shared.getAuthenticatedUser() else { return }
//        UserManager.shared.addListenerForPostsLiked(userId: authDataResult.uid) { [weak self] posts in
//            self?.likedPostsViewModel.userLikedPosts = posts
//        }
//    }

    func getLikes() {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let likes = try await UserManager.shared.getAllUserLikes(userId: authDataResult.uid)
            self.likedPostsViewModel.updateUserLikedPosts(with: likes)
        }
    }
    
    func removeFromLikes(likedPostId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let postId = likedPostsViewModel.userLikedPosts.first(where: { $0.id == likedPostId })?.postId
            try await UserManager.shared.removeUserLikedPost(userId: authDataResult.uid, likedPostId: likedPostId)
            if let postId = postId {
                try? await PostManager.shared.decrementLikes(postId: postId)
            }
            getLikes()
        }
    }
}


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


//struct LikesView: View {
//    @StateObject private var viewModel = LikesViewModel()
//
//    var body: some View {
//        Text("Your liked posts")
//            .font(.custom("Baloo2-SemiBold", size: 20))
//            .foregroundColor(Colors.linen)
//        List {
//            ForEach(viewModel.userLikedPosts, id: \.id.self) { post in
//                PostCellViewBuilder(postId: post.postId)
//                    .contextMenu {
//                        Button("Remove from likes") {
//                            viewModel.removeFromLikes(likedPostId: post.id)
//                        }
//                    }
//            }
//        }
//        .onAppear {
//            viewModel.getLikes()
//        }
//    }
//}

//struct LikesView_Previews: PreviewProvider {
//    static var previews: some View {
//        LikesView()
//            .environmentObject(LikesViewModel())
//    }
//}
