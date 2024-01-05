//
//  PostListViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 22/12/2023.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class PostListViewModel: ObservableObject {
    @ObservedObject var likedPostsViewModel = LikedPostsViewModel.shared
    @Published private(set) var posts: [Post] = []
    @Published private(set) var userLikedPosts: [UserLikedPost] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedType: TypeOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
    
    func getPosts() {
        Task {
            let (newPosts, lastDocument) = try await PostManager.shared.getAllPosts(likesDescending: selectedFilter?.likesDescending, forType: selectedType?.typeValue, count: 10, lastDocument: lastDocument)
            if newPosts.isEmpty {
                print("All posts have been fetched.")
            }
            for post in newPosts {
                if !self.posts.contains(where: { $0.id == post.id }) {
                    self.posts.append(post)
                }
            }
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        }
    }
    
    func getPostCount() {
        Task {
            do {
                let count = try await PostManager.shared.getAllPostsCount()
                print("Post count: \(count)")
            } catch {
                print("Failed to get post count: \(error)")
            }
        }
    }

    
    //MARK: Filters
    enum FilterOption: String, CaseIterable {
        case noFilter
        case likesDescending
        case likesAscending
        
        var likesDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .likesDescending: return true
            case .likesAscending: return false
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.posts = []
        self.lastDocument = nil
        self.getPosts()
    }
    
    enum TypeOption: String, CaseIterable {
        case noType
        case dog
        case cat
        case sloth
        
        var typeValue: String? {
            if self == .noType {
                return nil
            }
            return self.rawValue
        }
    }
    
    func typeSelected(option: TypeOption) async throws {
        self.selectedType = option
        self.posts = []
        self.lastDocument = nil
        self.getPosts()
    }
    
    // MARK: Likes
    func addUserLikedPost(postId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.addUserLikedPost(userId: authDataResult.uid, postId: postId)
        }
    }
    
    func getLikes() {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let likes = try await UserManager.shared.getAllUserLikes(userId: authDataResult.uid)
            self.likedPostsViewModel.updateUserLikedPosts(with: likes)

        }
    }
}
