//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class StatsViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedType: TypeOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
    
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
        self.getPosts()
    }
    
    func getPosts() {
        Task {
            self.posts = try await PostManager.shared.getAllPosts(likesDescending: selectedFilter?.likesDescending, forType: selectedType?.typeValue)
        }
    }
    
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
            }
            
            NavigationView {
                ZStack {
                    MainBackground()
                    List {
//                        Button("Fetch more objects") {
//                            viewModel.getPostsByViews()
//                        }
                        ForEach(viewModel.posts) { post in
                            PostCellView(post: post)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.getPosts()
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


struct PostCellView: View {
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
            
            VStack {
                Text(post.title)
                    .font(.headline)
                Text(post.description)
                Label {
                    Text(post.type)
                } icon: {
                    Image(systemName: "pawprint.fill")
                }
                Text("\(post.likes ?? 0)")
            }
            .foregroundColor(.secondary)
        }
    }
}
