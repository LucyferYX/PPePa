//
//  PanelView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 08/10/2023.
//

import SwiftUI
import FirebaseAuth

struct PanelContent: View {
    @StateObject private var viewModel = PanelViewModel()
    @Binding var showSignInView: Bool
    
//    @State private var showReportedPostView = false
//    @State private var showAccountSettingsView = false
//    @State private var showSettingsView = false
//    @State private var showLikesView = false
//    @State private var showAboutView = false
    @State private var showProfileView = false
    
    @State private var showDeleteAlert = false
    @State private var showEmailAlert = false
    @State private var emailAlertMessage = ""
    
//    Text("LN3569")
//        .font(.custom("Baloo2-SemiBold", size: 20))
//        .foregroundColor(Color("Linen"))
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {

                Text("Hi, \(viewModel.user?.username ?? "User")!")
                    .foregroundColor(Color("Linen"))
                    .font(.custom("Baloo2-SemiBold", size: 30))
                    .padding(.leading)
                    .padding(.top, 30)
                
                HStack {
                    profileImage(for: viewModel)
                    
                    VStack(alignment: .leading) {
                        Button(action: {
                            showProfileView = true
                        }) {
                            HStack {
                                Text("Open profile")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                    .foregroundColor(Color("Linen"))
                                Image(systemName: "chevron.right")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color("Linen"))
                            }
                        }
                        .fullScreenCover(isPresented: $showProfileView) {
                            ProfileView(showProfileView: $showProfileView)
                        }

                        Spacer()
                        
                        Button(action: {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    showSignInView = true
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }) {
                            Label("Sign out", systemImage: "arrowshape.turn.up.left")
                                .font(.custom("Baloo2-Regular", size: 20))
                                .foregroundColor(Color("Linen"))
                        }
                    }
                    .padding(.leading, 20)
                }
                .padding(.leading, 35)
                .onAppear {
                    viewModel.loadAuthProviders()
                    viewModel.loadAuthUser()
                }
                
                Line()
                
                scroll
                
                Line()
                
                panelButtons(viewModel: viewModel, showSignInView: $showSignInView)
                    .padding(.bottom)
            }
            .frame(height: geometry.size.height)
            .onAppear() {
                viewModel.checkIfUserIsAdmin()
                viewModel.addListenerForUser()
                print("User listener is turned on")
            }
            .onDisappear {
                viewModel.removeListenerForUser()
                print("User listener is turned off")
            }

        }
    }
}


struct PanelView: View {
    @StateObject private var viewModel = PanelViewModel()
    @Binding var showSignInView: Bool
    
    let width: CGFloat
    let showPanelView: Bool
    let closePanelView: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                PanelContent(showSignInView: $showSignInView)
                    .frame(width: self.width)
                    .background(Color("Walnut"))
                    .offset(x: showPanelView ? 0 : -self.width)
                Spacer()
            }
            .background(Color("Walnut").opacity(showPanelView ? 0.5 : 0.0))
            // Closing view with tap or sliding from right side
            .onTapGesture {
                withAnimation(.easeIn.delay(0.1)) {
                    self.closePanelView()
                }
            }
            .gesture(DragGesture().onEnded { value in
                if value.translation.width < -self.width / 2 {
                    withAnimation {
                        self.closePanelView()
                    }
                }
            })
        }
        .task {
            do {
                try await viewModel.loadCurrentUser()
            } catch {
                print("Failed to load user: \(error)")
            }
        }
    }
}

extension PanelContent {
    func profileImage(for viewModel: PanelViewModel) -> some View {
        Group {
            if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .clipShape(Circle())
                .frame(width: 60, height: 60)
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("Linen"))
                    .overlay(Circle().stroke(Color("Salmon"), lineWidth: 4))
                    .shadow(radius: 10)
            }
        }
    }
    
    func panelButtons(viewModel: PanelViewModel, showSignInView: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            if viewModel.isAdmin {
                SimpleButton(action: {
                    viewModel.showReportedPostView = true
                }, systemImage: "gearshape", buttonText: "Reported posts", size: 30, color: Color("Linen"))
            }
            SimpleButton(action: {
                viewModel.showAccountSettingsView = true
            }, systemImage: "person.2.badge.gearshape.fill", buttonText: "Profile settings", size: 30, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showSettingsView = true
            }, systemImage: "gear", buttonText: "App settings", size: 30, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showLikesView = true
            }, systemImage: "heart", buttonText: "Likes", size: 30, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showAboutView = true
            }, systemImage: "info.circle", buttonText: "About", size: 30, color: Color("Linen"))
        }
        .sheet(isPresented: $viewModel.showReportedPostView) {
            ReportedPostView()
        }
        .sheet(isPresented: $viewModel.showAccountSettingsView) {
            AccountSettingsView(showSignInView: showSignInView)
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            AppSettingsView()
        }
        .sheet(isPresented: $viewModel.showLikesView) {
            LikesView()
        }
        .sheet(isPresented: $viewModel.showAboutView) {
            AboutView()
        }
    }
    
    private var scroll: some View {
        ScrollView {
            VStack {
                ForEach(0..<10) { _ in
                    NavigationLink(destination: Text("Detail View")) {
                        CellView()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .background(Color.clear)
        .frame(height: 200)
        .padding(.bottom)
        .padding(.top)
    }
}
