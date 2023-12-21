//
//  LikesView.swift
//  Planet Pet Pals
//
//  Created by Liene on 20/12/2023.
//

import SwiftUI

@MainActor
final class LikesViewModel: ObservableObject {
//    @Published private(set) var userLikedPosts: [UserLikedPost] = []
    @ObservedObject var likedPostsViewModel = LikedPostsViewModel.shared

//    func getLikes() {
//        Task {
//            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
//            self.userLikedPosts = try await UserManager.shared.getAllUserLikes(userId: authDataResult.uid)
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
            try await UserManager.shared.removeUserLikedPost(userId: authDataResult.uid, likedPostId: likedPostId)
            getLikes()
        }
    }
}


struct LikesView: View {
    @StateObject private var viewModel = LikesViewModel()
    @StateObject var likedPostsViewModel = LikedPostsViewModel.shared

    
    var body: some View {
        VStack {
            Text("Your liked posts")
                .font(.custom("Baloo2-SemiBold", size: 20))
                .foregroundColor(Colors.linen)
            
            List {
                ForEach(likedPostsViewModel.userLikedPosts, id: \.id.self) { post in
                    PostCellViewBuilder(postId: post.postId)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.removeFromLikes(likedPostId: likedPostsViewModel.userLikedPosts[index].id)
                    }
                }
            }
//            List {
//                ForEach(likedPostsViewModel.userLikedPosts, id: \.id.self) { post in
//                    PostCellViewBuilder(postId: post.postId)
//                }
//                .onDelete { indexSet in
//                    for index in indexSet {
//                        viewModel.removeFromLikes(likedPostId: viewModel.userLikedPosts[index].id)
//                    }
//                }
//            }
            .onAppear {
                viewModel.getLikes()
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
