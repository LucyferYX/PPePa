//
//  PostCellView.swift
//  Planet Pet Pals
//
//  Created by Liene on 21/12/2023.
//

import SwiftUI

struct PostCellView: View {
    @StateObject var likedPostsViewModel = LikedPostsViewModel.shared
    
    @State private var isLiked: Bool = false
    @State private var likedPostId: String? = nil
    @State private var showLikeAnimation: Bool = false
    @State private var showMessage: Bool = false

    let post: Post

    var body: some View {
        HStack {

            AsyncImage(url: URL(string: post.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 70)
            .shadow(color: Colors.walnut.opacity(0.3), radius: 4, x: 0, y: 2)


            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(post.description)
                Label {
                    Text(post.type)
                } icon: {
                    Image(systemName: "pawprint.fill")
                }
                Text("Likes: \(post.likes ?? 0)")
            }
            .foregroundColor(.secondary)
            
            Button(action: {
                if isLiked {
                    print("This post has already been liked.")
                } else {
                    likedPostsViewModel.addUserLikedPost(postId: post.id)
                    isLiked = true
                    showLikeAnimation = true
                    showMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showMessage = false
                    }
                    print("You liked a post.")
                }
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .gray)
                    .scaleEffect(showLikeAnimation ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 0.2))
            }
            .onAppear {
                Task {
                    isLiked = await likedPostsViewModel.isPostLiked(postId: post.id)
                    likedPostId = await likedPostsViewModel.getLikedPostId(postId: post.id)
                }
            }
            .onReceive(likedPostsViewModel.$userLikedPosts) { _ in
                Task {
                    isLiked = await likedPostsViewModel.isPostLiked(postId: post.id)
                }
            }


            if showMessage {
                Text("Post liked!")
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.5))
            }
        }
    }
}

//struct PostCellView: View {
//    @StateObject var viewModel: StatsViewModel
//    @State private var isLiked: Bool = false
//    @State private var likedPostId: String? = nil
//    @State private var showLikeAnimation: Bool = false
//    @State private var showMessage: Bool = false
//
//    let post: Post
//
//    var body: some View {
//        HStack {
//
//            AsyncImage(url: URL(string: post.image)) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 70, height: 70)
//                    .cornerRadius(10)
//            } placeholder: {
//                ProgressView()
//            }
//            .frame(width: 70, height: 70)
//            .shadow(color: Colors.walnut.opacity(0.3), radius: 4, x: 0, y: 2)
//
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(post.title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                Text(post.description)
//                Label {
//                    Text(post.type)
//                } icon: {
//                    Image(systemName: "pawprint.fill")
//                }
//                Text("Likes: \(post.likes ?? 0)")
//            }
//            .foregroundColor(.secondary)
//
//            Button(action: {
//                if isLiked {
//                    print("This post has already been liked.")
//                } else {
//                    viewModel.addUserLikedPost(postId: post.id)
//                    isLiked = true
//                    showLikeAnimation = true
//                    showMessage = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        showMessage = false
//                    }
//                    print("You liked a post.")
//                }
//            }) {
//                Image(systemName: isLiked ? "heart.fill" : "heart")
//                    .foregroundColor(isLiked ? .red : .gray)
//                    .scaleEffect(showLikeAnimation ? 1.5 : 1.0)
//                    .animation(.easeInOut(duration: 0.2))
//            }
//            .onAppear {
//                Task {
//                    isLiked = await viewModel.isPostLiked(postId: post.id)
//                    likedPostId = await viewModel.getLikedPostId(postId: post.id)
//                }
//            }
//            .onReceive(viewModel.$userLikedPosts) { _ in
//                Task {
//                    isLiked = await viewModel.isPostLiked(postId: post.id)
//                }
//            }
//
//
//            if showMessage {
//                Text("Post liked!")
//                    .transition(.move(edge: .bottom))
//                    .animation(.easeInOut(duration: 0.5))
//            }
//        }
//    }
//}



//struct ColorfulCellView: View {
//    @StateObject var viewModel: StatsViewModel
//    @State private var isLiked: Bool = false
//    @State private var likedPostId: String? = nil
//    let post: Post
//    let size: CGFloat = 60
//
//    var body: some View {
//        HStack {
//            AsyncImage(url: URL(string: post.image)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: size, height: size)
//                    .clipShape(Circle())
//            } placeholder: {
//                ProgressView()
//            }
//            .frame(width: size, height: size)
//
//            VStack(alignment: .leading) {
//                Text(post.title)
//                    .font(.custom("Baloo2-SemiBold", size: 30))
//                    .foregroundColor(Colors.walnut)
//            }
//
//            Spacer()
//
//            Button(action: {
//                if isLiked {
//                    if let likedPostId = likedPostId {
//                        viewModel.removeFromLikes(likedPostId: likedPostId)
//                    }
//                } else {
//                    viewModel.addUserLikedPost(postId: post.id)
//                }
//                isLiked.toggle()
//            }) {
//                Image(systemName: isLiked ? "heart.fill" : "heart")
//                    .foregroundColor(isLiked ? .red : .gray)
//                    //.resizable()
//                    .frame(width: 30, height: 30)
//            }
//            .onAppear {
//                Task {
//                    isLiked = await viewModel.isPostLiked(postId: post.id)
//                    likedPostId = await viewModel.getLikedPostId(postId: post.id)
//                }
//            }
//
//            Image(systemName: "chevron.right")
//                .foregroundColor(Colors.walnut)
//        }
//        .padding()
//        .background(Colors.linen)
//        .cornerRadius(40)
//    }
//}

//struct CustomCellView: View {
//    @StateObject var viewModel: StatsViewModel
//    @ObservedObject var likesViewModel: LikedPostsViewModel
//    @State private var likedPostId: String? = nil
//
//    let post: Post
//    let imageSize: CGSize
//    let titleFont: Font
//    let titleColor: Color
//    let backgroundColor: Color
//    let cornerRadius: CGFloat
//
//    var body: some View {
//        HStack {
//            AsyncImage(url: URL(string: post.image)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: imageSize.width, height: imageSize.height)
//                    .clipShape(Circle())
//            } placeholder: {
//                ProgressView()
//            }
//            .frame(width: imageSize.width, height: imageSize.height)
//
//            VStack(alignment: .leading) {
//                Text(post.title)
//                    .font(titleFont)
//                    .foregroundColor(titleColor)
//            }
//
//            Spacer()
//
//            Button(action: {
//                if likesViewModel.isLiked {
//                    if let likedPostId = likedPostId {
//                        viewModel.removeFromLikes(likedPostId: likedPostId)
//                    }
//                } else {
//                    viewModel.addUserLikedPost(postId: post.id)
//                }
//                likesViewModel.isLiked.toggle()
//            }) {
//                Image(systemName: likesViewModel.isLiked ? "heart.fill" : "heart")
//                    .foregroundColor(likesViewModel.isLiked ? .red : .gray)
//                    .frame(width: 30, height: 30)
//            }
//            .onAppear {
//                Task {
//                    likesViewModel.isLiked = await viewModel.isPostLiked(postId: post.id)
//                    likedPostId = await viewModel.getLikedPostId(postId: post.id)
//                }
//            }
//
//            Image(systemName: "chevron.right")
//                .foregroundColor(Colors.walnut)
//        }
//        .padding()
//        .background(backgroundColor)
//        .cornerRadius(cornerRadius)
//    }
//}
//
//struct PostCellView: View {
//    let post: Post
//    @StateObject var viewModel: StatsViewModel
//    @ObservedObject var likesViewModel: LikedPostsViewModel
//
//    var body: some View {
//        CustomCellView(
//            viewModel: viewModel, likesViewModel: likesViewModel,
//            post: post,
//            imageSize: CGSize(width: 70, height: 70),
//            titleFont: .headline,
//            titleColor: .primary,
//            backgroundColor: .white,
//            cornerRadius: 0
//        )
//    }
//}
//
//struct ColorfulCellView: View {
//    let post: Post
//    @StateObject var viewModel: StatsViewModel
//    @ObservedObject var likesViewModel: LikedPostsViewModel
//
//    var body: some View {
//        CustomCellView(
//            viewModel: viewModel, likesViewModel: likesViewModel,
//            post: post,
//            imageSize: CGSize(width: 60, height: 60),
//            titleFont: .custom("Baloo2-SemiBold", size: 30),
//            titleColor: Colors.walnut,
//            backgroundColor: Colors.linen,
//            cornerRadius: 40
//        )
//    }
//}



struct PostCellViewBuilder: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var post: Post? = nil
    let postId: String
    
    var body: some View {
        ZStack {
            if let post {
                PostCellView(post: post)
            }
        }
        .task {
            self.post = try? await PostManager.shared.getPost(postId: postId)
        }
    }
}


//class LikedPostsViewModel: ObservableObject {
//    @Published var isLiked: Bool = false
//}
