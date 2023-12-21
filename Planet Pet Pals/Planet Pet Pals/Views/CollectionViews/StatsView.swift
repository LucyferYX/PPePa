//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class LikedPostsViewModel: ObservableObject {
    static let shared = LikedPostsViewModel()
    @Published private(set) var userLikedPosts: [UserLikedPost] = []
    @Published var isLiked: [String: Bool] = [:]
    
    func updateUserLikedPosts(with posts: [UserLikedPost]) {
        self.userLikedPosts = posts
        self.isLiked = posts.reduce(into: [:]) { $0[$1.postId] = true }
    }
    
    func isPostLiked(postId: String) -> Bool {
        return isLiked[postId] ?? false
    }
    
    func getLikedPostId(postId: String) -> String? {
        return userLikedPosts.first(where: { $0.postId == postId })?.id
    }
    
    func addUserLikedPost(postId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.addUserLikedPost(userId: authDataResult.uid, postId: postId)
            try? await PostManager.shared.incrementLikes(postId: postId)
        }
    }
}


@MainActor
class StatsViewModel: ObservableObject {
    @ObservedObject var likedPostsViewModel = LikedPostsViewModel.shared
    @Published private(set) var posts: [Post] = []
    @Published private(set) var userLikedPosts: [UserLikedPost] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedType: TypeOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
    
    func getPosts() {
        Task {
            let (newPosts, lastDocument) = try await PostManager.shared.getAllPosts(likesDescending: selectedFilter?.likesDescending, forType: selectedType?.typeValue, count: 1, lastDocument: lastDocument)
            self.posts.append(contentsOf: newPosts)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
            self.lastDocument = lastDocument
        }
    }
    
    func getPostCount() {
        Task{
            let count = try await PostManager.shared.getAllPostsCount()
            print("Post count: \(count)")
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
    
    func removeFromLikes(likedPostId: String) {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeUserLikedPost(userId: authDataResult.uid, likedPostId: likedPostId)
            getLikes()
        }
    }

//    func isPostLiked(postId: String) async -> Bool {
//        let authDataResult = try? AuthManager.shared.getAuthenticatedUser()
//        let likedPosts = try? await UserManager.shared.getAllUserLikes(userId: authDataResult?.uid ?? "No posts")
//        return likedPosts?.contains(where: { $0.postId == postId }) ?? false
//    }
    
//    func getLikedPostId(postId: String) async -> String? {
//        let authDataResult = try? AuthManager.shared.getAuthenticatedUser()
//        let likedPosts = try? await UserManager.shared.getAllUserLikes(userId: authDataResult?.uid ?? "No posts")
//        return likedPosts?.first(where: { $0.postId == postId })?.id
//    }
    
//    func getPostsByViews() {
//        Task {
//            let (newPosts, lastDocument) = try await PostManager.shared.getPostsByViews(count: 1, lastDocument: lastDocument)
//            self.posts.append(contentsOf: newPosts)
//            self.lastDocument = lastDocument
//        }
//    }
}


struct StatsView: View {
    @Binding var showStatsView: Bool
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = StatsViewModel()
    @State private var showHStack = false
    
    var body: some View {
        VStack {
            
            NavigationBar()
            
            showMenu()
            
            NavigationView {
                ZStack {
                    MainBackground()
                    List {
                        ForEach(viewModel.posts) { post in
                            PostCellView(post: post, showLikeButton: true)
                            
                            if post == viewModel.posts.last {
                                ProgressView()
                                    .onAppear {
                                        print("More posts are being fetched.")
                                        viewModel.getPosts()
                                    }
                            }
                        }
                    }
                }
            }

        }
        .onAppear {
            viewModel.getPostCount()
            viewModel.getPosts()
            viewModel.getLikes()
        }
        .transition(.move(edge: .trailing))
        .animation(.default, value: showHStack)
    }
}


//struct StatsPreview: PreviewProvider {
//    static var previews: some View {
//        StatsView(showStatsView: .constant(true))
//    }
//}


extension StatsView {
    @ViewBuilder
    func showMenu() -> some View {
        if showHStack {
            HStack {
                Menu(viewModel.selectedFilter != nil ? "Filter: \(viewModel.selectedFilter!.rawValue)" : "Select filter") {
                    ForEach(StatsViewModel.FilterOption.allCases, id: \.self) { filterOption in
                        Button(filterOption.rawValue) {
                            Task {
                                try? await viewModel.filterSelected(option: filterOption)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Menu(viewModel.selectedType != nil ? "Type: \(viewModel.selectedType!.rawValue)" : "Select type") {
                    ForEach(StatsViewModel.TypeOption.allCases, id: \.self) { typeOption in
                        Button(typeOption.rawValue) {
                            Task {
                                try? await viewModel.typeSelected(option: typeOption)
                            }
                        }
                    }
                }
            }
            .padding()
            .transition(.move(edge: .top))
        } else {
            EmptyView()
        }
    }
    
    func NavigationBar() -> some View {
        MainNavigationBar(
            title: "Stats",
            leftButton: LeftNavigationButton(
                action: { self.showStatsView = false },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: false
            ),
            rightButton: RightNavigationButton(
                action: { self.showHStack.toggle() },
                imageName: "slider.horizontal.3",
                buttonText: "Filter",
                imageInvisible: false,
                textInvisible: false
            )
        )
    }
}
