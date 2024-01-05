//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class MainMenuViewModel: ObservableObject {
    @Published var currentPost: Post?
    @Published var isLoading: Bool = false
    @Published var keyboardIsShown: Bool = false
    private var lastDocument: DocumentSnapshot?

    init() {
        nextPost()
//        addKeyboardNotifications()
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

//    func addKeyboardNotifications() {
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
//            self.keyboardIsShown = true
//        }
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
//            self.keyboardIsShown = false
//        }
//    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}



struct MainMenuView: View {
    @StateObject private var viewModel = MainMenuViewModel()
    
    @Binding var showSignInView: Bool
    @State private var showPanelView = false
    @State private var showProfileView = false
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


//struct MainMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainMenuView(showSignInView: .constant(false))
//    }
//}



extension MainMenuView {
    private var panelButtons: some View {
        HStack {
            PanelButton(action: { showPanelView.toggle() },
                        systemImage: "line.3.horizontal",
                        color: Color("Walnut"))
            Spacer()
            PanelButton(action: { showProfileView.toggle() },
                        systemImage: "person.crop.circle",
                        color: Color("Walnut"))
            .padding(.trailing)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showProfileView) {
            ProfileView(showProfileView: $showProfileView)
        }
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
