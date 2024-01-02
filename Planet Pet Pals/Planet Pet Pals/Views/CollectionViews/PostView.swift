//
//  PostView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/12/2023.
//

import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    @Published private(set) var post: Post? = nil
    @Published var isLoading = false

    func loadPost(postId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        self.post = try await PostManager.shared.getPost(postId: postId)
    }
}

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @Binding var showPostView: Bool
    let postId: String

    var body: some View {
        ZStack {
            MainBackground2()
            VStack {
                NavigationBar()
                ScrollView {
                    if let post = viewModel.post {
                        DynamicImageView(isLoading: viewModel.isLoading, url: URL(string: post.image))
                            .ignoresSafeArea()
                        VStack {
                            Text("Post id: \(post.postId)")
                            Text("Title: \(post.title)")
                            Text("Type: \(post.type)")
                            Text("Description: \(post.description)")
                            Text("Likes: \(post.likes ?? 0)")
                            Text("Report: \(String(post.isReported))")
                        }
                    } else {
                        ProgressView()
                    }
                }
                .ignoresSafeArea()
            }
        }
        .task {
            do {
                try await viewModel.loadPost(postId: postId)
            } catch {
                print("Failed to load post: \(error)")
            }
        }
    }
}


//struct PostPreviews: PreviewProvider {
//    static var previews: some View {
//        PostView(showPostView: .constant(true), postId: "F75DEF0B-68D8-479C-970E-3EBF375D7664")
//    }
//}


struct DynamicImageView: View {
    let isLoading: Bool
    let url: URL?

    var body: some View {
        GeometryReader { geometry in
            let offsetY = geometry.frame(in: .global).minY
            let isScrolled = offsetY > 0
            Spacer()
                .frame(height: isScrolled ? 400  + offsetY: 400)
                .background {
                    if isLoading {
                        ProgressView()
                    } else if let url = url {
                        Color.clear.overlay(
                            AsyncImage(url: url) { image in
                                image.resizable()
                                     .scaledToFill()
                                     .offset(y: isScrolled ? -offsetY: 0)
                                     .scaleEffect(isScrolled ? offsetY / 2000 + 1 : 1)
                            } placeholder: {
                                ProgressView()
                            }
                        )
                    }
                }
        }
        .frame(height: 400)
    }
}


extension PostView {
    func NavigationBar() -> some View {
        MainNavigationBar(
            title: "Post",
            leftButton: LeftNavigationButton(
                action: { self.showPostView = false },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: false
            ),
            rightButton: RightNavigationButton(
                action: {  },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: true,
                textInvisible: true
            )
        )
    }
}
