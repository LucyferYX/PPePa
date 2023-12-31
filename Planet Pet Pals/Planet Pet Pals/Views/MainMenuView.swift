//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI
import FirebaseFirestore

class MainMenuViewModel: ObservableObject {
    @Published var currentPost: Post?
    @Published var isLoading: Bool = false
    private var lastDocument: DocumentSnapshot?
    private var randomId: String = ""

    init() {
        randomId = generateRandomId()
        nextPost()
    }

    func nextPost() {
        isLoading = true
        DispatchQueue.main.async {
            Task {
                do {
                    let (posts, lastDocument) = try await PostManager.shared.getAllPostsBy1(startAfter: self.lastDocument)
                    if let post = posts.first {
                        self.lastDocument = lastDocument
                        if post.userId.contains(self.randomId) {
                            self.currentPost = post
                        } else {
                            self.nextPost()
                        }
                    } else {
                        // If no more posts, generate a new random ID and start from the beginning
                        self.randomId = self.generateRandomId()
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
    
    func generateRandomId() -> String {
        let characters = Array("0123456789abcdefghijklmnoprstuvzyxwq")
        return String(characters[Int.random(in: 0..<characters.count)])
    }
}



struct MainMenuView: View {
    @StateObject private var postLoader = MainMenuViewModel()
    
    @Binding var showSignInView: Bool
    @State private var showPanelView = false
    @State private var showProfileView = false
    @State private var showCreateView = false
    @State private var showMapView = false
    @State private var showStatsView = false
    @State private var showPostView = false
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardIsShown: Bool = false
    @State private var showButton: Bool = false
    @State private var buttonsEnabled: Bool = true

    @State private var searchText = ""
    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .topLeading) {
                    MainBackground()
                    
                    VStack {
                        HStack {
                            PanelButton(action: { showPanelView.toggle() },
                                        systemImage: "line.3.horizontal",
                                        color: Color("Walnut"))
                            Spacer()
                            PanelButton(action: { showProfileView.toggle() },
                                        systemImage: "person.crop.circle",
                                        color: Color("Walnut"))
                        }
                        .ignoresSafeArea(.keyboard)
                        .fullScreenCover(isPresented: $showProfileView) {
                            ProfileView(showProfileView: $showProfileView)
                        }
                        
                        
                        HStack {
                            SimpleImageView(imageName: "LogoBig", width: 250, height: 120)
                                .padding(.top, -10)
                        }
                        
                        
                        HStack {
                            SimpleButton(action: {
                                showPostView = true
                            }, systemImage: "chevron.left", buttonText: "", size: 30, color: Color("Snow"))
                            
                            if postLoader.isLoading {
                                ProgressView()
                            } else {
                                FadeOutImageView(isLoading: postLoader.isLoading,
                                                 url: URL(string: postLoader.currentPost?.image ?? ""),
                                                 width: 250, height: 250)
                            }

                            SimpleButton(action: {
                                postLoader.nextPost()
                            }, systemImage: "chevron.right", buttonText: "", size: 30, color: Color("Snow"))
                        }

                        
                        Spacer()
                        
                        MainSearchBar(text: $searchText) {
                            print("Searching for \(searchText)")
                        }
                        
                        Spacer()
                        
                        // Main buttons
                        if showButton {
                            mainButtons
                        } else if !keyboardIsShown {
                            mainButtons
                        }
                    }
                    PanelView(showSignInView: $showSignInView , width: geometry.size.width*0.7, showPanelView: self.showPanelView, closePanelView: { self.showPanelView = false })
                        .offset(x: self.showPanelView ? 0 : -geometry.size.width)
                        .transition(.move(edge: .leading))
                    StatsView(showStatsView: self.$showStatsView)
                        .offset(x: self.showStatsView ? 0 : geometry.size.width)
                        .transition(.move(edge: .trailing))
                }
            }
            .onAppear {
                addKeyboardNotifications()
                self.showButton = false
            }
            .onDisappear {
                removeKeyboardNotifications()
            }
            .sheet(isPresented: $showPostView) {
                if let postId = postLoader.currentPost?.postId {
                    PostView(showPostView: $showPostView, postId: postId)
                }
            }
        }
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardIsShown = true
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardIsShown = false
            }
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


extension MainMenuView {
    var mainButtons: some View {
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
        }
        .fullScreenCover(isPresented: $showMapView) {
            MapView(showMapView: $showMapView)
        }
        .fullScreenCover(isPresented: $showCreateView) {
            CreateView(showCreateView: $showCreateView, showButton: $showButton)
        }
    }
}
