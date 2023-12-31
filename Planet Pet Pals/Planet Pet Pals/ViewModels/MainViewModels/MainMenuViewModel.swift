//
//  MainMenuViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 01/01/2024.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class MainMenuViewModel: ObservableObject {
    @Published var currentPost: Post?
    @Published var selectedPost: Post?
    @Published var isLoading: Bool = false
    @Published var keyboardIsShown: Bool = false
    private var lastDocument: DocumentSnapshot?
    
    @Published var searchText = ""
    @Published var filteredPosts: [Post] = []
    @Published var showAlert: Bool = false

    init() {
        nextPost()
    }
    
    func getAllPosts() async {
        do {
            let allPosts = try await PostManager.shared.getAllPosts()
            DispatchQueue.main.async {
                if self.searchText.isEmpty {
                    self.filteredPosts = []
                } else {
                    self.filteredPosts = allPosts.filter { $0.title.lowercased().contains(self.searchText.lowercased()) }
                }
                self.showAlert = self.filteredPosts.isEmpty
            }
        } catch {
            print("Failed to fetch posts: \(error)")
        }
    }

    func nextPost() {
        isLoading = true
        DispatchQueue.main.async {
            Task {
                do {
                    let (posts, lastDocument) = try await PostManager.shared.getAllPostsBy1(startAfter: self.lastDocument)
                    if let post = posts.sorted(by: { $0.dateCreated > $1.dateCreated }).first {
                        self.lastDocument = lastDocument
                        self.currentPost = post
                    } else {
                        self.lastDocument = nil
                        self.nextPost()
                    }
                } catch {
                    print("Failed to fetch post: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    // Publishing changes from within view updates is not allowed, this will cause undefined behavior.
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async {
                self.keyboardIsShown = true
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async {
                self.keyboardIsShown = false
            }
        }
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
