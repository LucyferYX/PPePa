//
//  PostListView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI
import FirebaseFirestore

struct PostListView: View {
    @StateObject private var viewModel = PostListViewModel()

    @Binding var showPostListView: Bool
    @State private var showHStack = false
    
    var body: some View {
        ZStack {
            MainBackground()
            VStack {
                
                NavigationBar
                
                showMenu()
                
                NavigationView {
                    ZStack {
                        MainBackground()
                        List {
                            if !viewModel.posts.isEmpty {
                                ForEach(viewModel.posts) { post in
                                    PostCellViewBuilder(postId: post.postId, showLikeButton: true, showLikes: false, showContext: true)
                                        .listRowBackground(Color("Linen"))
                                        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                    if post == viewModel.posts.last {
                                        ProgressView()
                                            .onAppear {
                                                print("Posts are being fetched.")
                                                viewModel.getPosts()
                                            }
                                            .listRowBackground(MainBackground())
                                    }
                                }
                            } else {
                                ProgressView()
                                    .listRowBackground(MainBackground())
                            }
                        }
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                    }
                }
                
            }
            .onAppear {
                CrashlyticsManager.shared.setValue(value: "PostListView", key: "currentView")
                viewModel.getPosts()
                viewModel.getLikes()
                viewModel.getPostCount()
            }
            .transition(.move(edge: .trailing))
            .animation(.default, value: showHStack)
        }
    }
}


extension PostListView {
    @ViewBuilder
    func showMenu() -> some View {
        if showHStack {
            HStack(spacing: 0) {
                Menu {
                    ForEach(PostListViewModel.FilterOption.allCases, id: \.self) { filterOption in
                        Button(filterOption.rawValue) {
                            Task {
                                try? await viewModel.filterSelected(option: filterOption)
                            }
                        }
                    }
                } label: {
                    if viewModel.selectedFilter != nil {
                        Text("\(viewModel.selectedFilter!.rawValue)")
                            .font(.custom("Baloo2-SemiBold", size: 20))
                            .frame(width: 200)
                        
                    } else {
                        Text("Select filter")
                            .font(.custom("Baloo2-SemiBold", size: 20))
                            .frame(width: 200)
                        
                    }
                }
                
                Spacer()
                
                Menu {
                    ForEach(PostListViewModel.TypeOption.allCases, id: \.self) { typeOption in
                        Button(typeOption.rawValue) {
                            Task {
                                try? await viewModel.typeSelected(option: typeOption)
                            }
                        }
                    }
                } label: {
                    if viewModel.selectedType != nil {
                        Text("\(viewModel.selectedType!.rawValue)")
                            .font(Font.custom("Baloo2-SemiBold", size: 20))
                            .frame(width: 200)
                    } else {
                        Text("Select type")
                            .font(Font.custom("Baloo2-SemiBold", size: 20))
                            .frame(width: 200)
                    }
                }
            }
            .transition(.move(edge: .top))
        } else {
            EmptyView()
        }
    }
    
    private var NavigationBar: some View {
        MainNavigationBar(
            title: "Posts",
            leftButton: LeftNavigationButton(
                action: { self.showPostListView = false },
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
