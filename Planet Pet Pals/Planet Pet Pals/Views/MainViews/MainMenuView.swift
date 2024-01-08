//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = MainMenuViewModel()
    
    @Binding var showSignInView: Bool
    @State private var showPanelView: Bool = false
    @State private var showCreateView: Bool = false
    @State private var showMapView: Bool = false
    @State private var showStatsView: Bool = false
    
    @State private var showCurrentPostView: Bool = false
    @State private var showSelectedPostView: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardIsShown: Bool = false
    @State private var showButton: Bool = false
    
    @State private var searchText = ""
    @State var filteredPosts: [Post] = []

    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .topLeading) {
                    MainBackground()
                        .ignoresSafeArea()
                    
                    VStack {
                        // If search functionality shows a list of found posts,
                        // interaction with other elements is disabled temporarily
                        
                        // Button for opening the panel
                        panelButtons
                            .disabled(!viewModel.filteredPosts.isEmpty)
                        
                        // Shows app logo
                        logoImage
                            .disabled(!viewModel.filteredPosts.isEmpty)
                        
                        Spacer()
                        
                        // Shows post images and lets user move them forward as well as open post view for the one shown
                        postNavigation
                            .disabled(!viewModel.filteredPosts.isEmpty)
                        
                        Spacer()
                        
                        // Search bar
                        searchBar
                        
                        Spacer()
                        
                        // Create, map and stats view buttons
                        // Buttons are hidden if keyboard is shown to prevent elements from being pushed outside the view
                        if showButton {
                            mainButtons
                                .disabled(!viewModel.filteredPosts.isEmpty)
                        } else if !keyboardIsShown {
                            mainButtons
                                .disabled(!viewModel.filteredPosts.isEmpty)
                        }
                    
                    }
                    
                    // Show user searched posts that match the input for their title field
                    if !viewModel.filteredPosts.isEmpty {
                        ZStack {
                            List(viewModel.filteredPosts) { post in
                                Text(post.title)
                                    .background(Color("Snow"))
                                    .onTapGesture {
                                        viewModel.selectedPost = post
                                        showSelectedPostView = true
                                    }
                            }
                            .listStyle(PlainListStyle())
                            .background(Color.clear)
                            .frame(maxHeight: 200)
                            .padding(.top, 250)
                            .padding(.bottom, 280)
                            .padding(.horizontal, 30)
                            .shadow(radius: 30)
                        }
                        .background(Color.clear.ignoresSafeArea().contentShape(Rectangle()).onTapGesture {
                            viewModel.filteredPosts = []
                        })
                    }
                    
                    // Show panel view in a side menu style
                    PanelView(showSignInView: $showSignInView, width: geometry.size.width*0.8, showPanelView: self.showPanelView, closePanelView: { self.showPanelView = false })
                        .offset(x: self.showPanelView ? 0 : -geometry.size.width)
                        .transition(.move(edge: .leading))
                }
            }
            .onAppear {
                CrashlyticsManager.shared.setValue(value: "MainMenuView", key: "currentView")
                viewModel.addKeyboardNotifications()
                self.showButton = false
            }
            .onDisappear {
                viewModel.removeKeyboardNotifications()
            }
            // Open post view from post navigation function
            .fullScreenCover(isPresented: $showCurrentPostView) {
                if let postId = viewModel.currentPost?.postId {
                    PostView(showPostView: $showCurrentPostView, postId: postId)
                }
            }
            // Open post view from tapping searched post cell
            .fullScreenCover(isPresented: $showSelectedPostView) {
                if let postId = viewModel.selectedPost?.postId {
                    PostView(showPostView: $showSelectedPostView, postId: postId)
                }
            }
        }
    }
}


struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(showSignInView: .constant(false))
    }
}



extension MainMenuView {
    private var panelButtons: some View {
        HStack {
            PanelButton(action: { showPanelView.toggle() },
                        systemImage: "line.3.horizontal",
                        color: Color("Walnut"))
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var logoImage: some View {
        HStack {
            SimpleImageView(imageName: "LogoBig", width: 250, height: 120)
                .padding(.top, -10)
        }
    }
    
    private var postNavigation: some View {
        HStack(spacing: 0) {
            SimpleButton(action: {
                showCurrentPostView = true
            }, systemImage: "chevron.left", buttonText: "", size: 30, color: Color("Snow"))
            
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    FadeOutImageView(isLoading: viewModel.isLoading,
                                     url: URL(string: viewModel.currentPost?.image ?? ""))
                        .frame(width: 250, height: 250)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: 250, height: 250)

            SimpleButton(action: {
                viewModel.nextPost()
            }, systemImage: "chevron.right", buttonText: "", size: 30, color: Color("Snow"))
        }
    }
    
    private var searchBar: some View {
        MainSearchBar(text: $viewModel.searchText) {
            Task {
                _ = await viewModel.getAllPosts()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("No posts found"), message: Text("No posts were from your search with this title."), dismissButton: .default(Text("OK")))
        }
    }
    
    private var mainButtons: some View {
        HStack(spacing: -3) {
            MainButton(action: { showCreateView.toggle(); showButton.toggle() },
                       imageName: "camera.fill",
                       buttonText: "Create",
                       imageColor: Color("Salmon"),
                       buttonColor: Color("Snow"))
            .padding()
            
            MainButton(action: { self.showMapView = true },
                       imageName: "map.fill",
                       buttonText: "Map",
                       imageColor: Color("Walnut"),
                       buttonColor: Color("Snow"))
            .padding()
            
            MainButton(action: { self.showStatsView = true },
                       imageName: "chart.bar.fill",
                       buttonText: "Stats",
                       imageColor: Color("Salmon"),
                       buttonColor: Color("Snow"))
            .padding()
            NavigationLink(destination: StatsView(showStatsView: $showStatsView).navigationBarHidden(true), isActive: $showStatsView) {
                    EmptyView()
            }
        }
        .fullScreenCover(isPresented: $showMapView) {
            MapView(showMapView: $showMapView)
        }
        .fullScreenCover(isPresented: $showCreateView) {
            CreateView(showCreateView: $showCreateView, showButton: $showButton)
        }
    }
}
