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

    func loadPost(postId: String) async throws {
        self.post = try await PostManager.shared.getPost(postId: postId)
    }
}

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @Binding var showPostView: Bool
    let postId: String

    var body: some View {
        VStack {
            NavigationBar()
            List {
                if let post = viewModel.post {
                    Text("Post id: \(post.postId)")
                    Text("Title: \(post.title)")
                    Text("Type: \(post.type)")
                    Text("Description: \(post.description)")
                    Text("Likes: \(post.likes ?? 0)")
                    Text("Report: \(String(post.isReported))")
                }
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
