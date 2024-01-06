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
    @State private var showPanelView = false
    @State private var showCreateView = false
    @State private var showMapView = false
    @State private var showStatsView = false
    @State var showPostView = false
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardIsShown: Bool = false
    @State private var showButton: Bool = false
    @State private var searchText = ""
    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .topLeading) {
                    MainBackground()
                        .ignoresSafeArea()
                    
                    VStack {
                        panelButtons
                        
                        logoImage
                        
                        postNavigation

                        Spacer()
                        
                        searchBar
                        
                        Spacer()
                        
                        if showButton {
                            mainButtons
                        } else if !keyboardIsShown {
                            mainButtons
                        }
                    }
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
            .fullScreenCover(isPresented: $showPostView) {
                if let postId = viewModel.currentPost?.postId {
                    PostView(showPostView: $showPostView, postId: postId)
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
                showPostView = true
            }, systemImage: "chevron.up", buttonText: "", size: 30, color: Color("Snow"))
            
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
        MainSearchBar(text: $searchText) {
            print("Searching for \(searchText)")
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
