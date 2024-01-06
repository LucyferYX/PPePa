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
    @State private var showProfileView = false
    
    @State private var showDeleteAlert = false
    @State private var showEmailAlert = false
    @State private var emailAlertMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack {
                    Text("Hi, ")
                    Text("\(viewModel.user?.username ?? "User")")
                }
                .foregroundColor(Color("Linen"))
                .font(.custom("Baloo2-SemiBold", size: 30))
                .padding(.leading)
                .padding(.top, 30)
                ZStack {
                    Color("Salmon")
                        .opacity(0.25)
                        .cornerRadius(10)
                    VStack {
                        HStack {
                            profileImage(for: viewModel)
                            
                            VStack(alignment: .leading) {
                                Button(action: {
                                    showProfileView = true
                                }) {
                                    HStack {
                                        Text("Open profile")
                                            .font(.custom("Baloo2-SemiBold", size: 20))
                                            .foregroundColor(Color("Linen"))
                                        Image(systemName: "chevron.right")
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color("Linen"))
                                    }
                                }
                                .fullScreenCover(isPresented: $showProfileView) {
                                    ProfileView(showProfileView: $showProfileView)
                                }
                                
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
                    }
                    .onAppear {
                        viewModel.loadAuthProviders()
                        viewModel.loadAuthUser()
                    }
                }
                .frame(height: 100)
                .padding(.horizontal)
                
                Spacer()
                
                adminPanelButtons(viewModel: viewModel, showSignInView: $showSignInView)
                
                Line()
                
                userPanelButtons(viewModel: viewModel, showSignInView: $showSignInView)
                
                Line()
                
                settingsPanelButtons(viewModel: viewModel, showSignInView: $showSignInView)
            }
            .frame(height: geometry.size.height)
            .onAppear() {
                CrashlyticsManager.shared.setValue(value: "PanelView", key: "currentView")
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
                .frame(width: 80, height: 80)
                .shadow(radius: 10)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("Linen"))
                    .shadow(radius: 10)
            }
        }
    }
    
    func adminPanelButtons(viewModel: PanelViewModel, showSignInView: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            if viewModel.isAdmin {
                SimpleButton(action: {
                    viewModel.showReportedPostsView = true
                }, systemImage: "folder.fill.badge.questionmark", buttonText: LocalizedStringKey("Reported posts"), size: 25, color: Color("Linen"))
                SimpleButton(action: {
                    viewModel.showDeletedUserPostsView = true
                }, systemImage: "folder.fill.badge.person.crop", buttonText: LocalizedStringKey("Deleted user posts"), size: 25, color: Color("Linen"))
            }
        }
        .padding(.trailing)
        .sheet(isPresented: $viewModel.showReportedPostsView) {
            ReportedPostView()
        }
        .sheet(isPresented: $viewModel.showDeletedUserPostsView) {
            DeletedUserPostsView()
        }
    }
    
    func userPanelButtons(viewModel: PanelViewModel, showSignInView: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            SimpleButton(action: {
                viewModel.showMyPostsView = true
            }, systemImage: "photo.artframe", buttonText: LocalizedStringKey("My posts"), size: 25, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showLikesView = true
            }, systemImage: "heart", buttonText: LocalizedStringKey("Liked posts"), size: 25, color: Color("Linen"))
        }
        .padding(.trailing)
        .sheet(isPresented: $viewModel.showMyPostsView) {
            MyPostsView()
        }
        .sheet(isPresented: $viewModel.showLikesView) {
            LikesView()
        }
    }
    
    func settingsPanelButtons(viewModel: PanelViewModel, showSignInView: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            SimpleButton(action: {
                viewModel.showProfileSettingsView = true
            }, systemImage: "person.crop.circle.badge.moon.fill", buttonText: LocalizedStringKey("Profile settings"), size: 25, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showAccountSettingsView = true
            }, systemImage: "person.badge.key", buttonText: LocalizedStringKey("Account settings"), size: 25, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showSettingsView = true
            }, systemImage: "gearshape.2.fill", buttonText: LocalizedStringKey("App settings"), size: 25, color: Color("Linen"))
            SimpleButton(action: {
                viewModel.showAboutView = true
            }, systemImage: "info.circle", buttonText: LocalizedStringKey("About"), size: 25, color: Color("Linen"))
        }
        .padding(.trailing)
        .padding(.bottom)
        .sheet(isPresented: $viewModel.showProfileSettingsView) {
            ProfileSettingsView()
        }
        .sheet(isPresented: $viewModel.showAccountSettingsView) {
            AccountSettingsView(showSignInView: showSignInView)
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            AppSettingsView()
        }
        .sheet(isPresented: $viewModel.showAboutView) {
            AboutView()
        }
    }
}
