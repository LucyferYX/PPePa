//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/11/2023.
//

import SwiftUI
import FirebaseFirestore

struct StatsView: View {
    @Binding var showStatsView: Bool
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = StatsViewModel()
    @State private var showHStack = false
    
    var body: some View {
        ZStack {
            Color("Snow").ignoresSafeArea()
            VStack {
                
                NavigationBar()
                
                showMenu()
                
                NavigationView {
                    ZStack {
                        MainBackground()
                        List {
                            ForEach(viewModel.posts) { post in
                                PostCellView(post: post, showLikeButton: true, showLikes: false)
                                    .listRowBackground(Color("Linen"))
                                    .buttonStyle(.borderless)
                                
                                if post == viewModel.posts.last {
                                    ProgressView()
                                        .onAppear {
                                            print("Posts are being fetched.")
                                            viewModel.getPosts()
                                        }
                                }
                            }
                        }
                        .background(Color("Snow"))
                        .scrollContentBackground(.hidden)
                    }
                }
                
            }
            .onAppear {
                viewModel.getPosts()
                viewModel.getLikes()
                viewModel.getPostCount()
            }
            .transition(.move(edge: .trailing))
            .animation(.default, value: showHStack)
        }
    }
}


extension StatsView {
    @ViewBuilder
    func showMenu() -> some View {
        if showHStack {
            HStack(spacing: 0) {
                Menu {
                    ForEach(StatsViewModel.FilterOption.allCases, id: \.self) { filterOption in
                        Button(filterOption.rawValue) {
                            Task {
                                try? await viewModel.filterSelected(option: filterOption)
                            }
                        }
                    }
                } label: {
                    if viewModel.selectedFilter != nil {
                        Text("\(viewModel.selectedFilter!.rawValue)")
                            .font(Font.custom("Baloo2-SemiBold", size: 20))
                    } else {
                        Text("Select filter")
                            .font(Font.custom("Baloo2-SemiBold", size: 20))
                    }
                }
                
                Spacer()
                
                Menu {
                    ForEach(StatsViewModel.TypeOption.allCases, id: \.self) { typeOption in
                        Button(typeOption.rawValue) {
                            Task {
                                try? await viewModel.typeSelected(option: typeOption)
                            }
                        }
                    }
                } label: {
                    if viewModel.selectedFilter != nil {
                        Text("\(viewModel.selectedFilter!.rawValue)")
                            .font(Font.custom("Baloo2-SemiBold", size: 20))
                    } else {
                        Text("Select type")
                            .font(Font.custom("Baloo2-SemiBold", size: 20))
                    }
                }
            }
            .padding(.leading)
            .padding(.trailing)
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
