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
    
    @State private var showReportedPostView = false
    @State private var showProfileSettingsView = false
    @State private var showSettingsView = false
    @State private var showLikesView = false
    @State private var showAboutView = false
    
    @State private var showDeleteAlert = false
    @State private var showEmailAlert = false
    @State private var emailAlertMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                SimpleButton(action: {
                    print("Username pressed")
                }, systemImage: nil, buttonText: "Username", size: 30, color: Color("Linen"))
                
                HStack {
                    RoundImage(systemName: "person.circle", size: 60, color: Color("Linen"))
                    VStack(alignment: .leading) {
                        Text("LN3569")
                            .font(.custom("Baloo2-SemiBold", size: 20))
                            .foregroundColor(Color("Linen"))
                        
                        // MARK: Registered accounts
                        if viewModel.authProviders.contains(.email) {
                            // create section, name it emailsection
                            
                            Button("Reset password") {
                                Task {
                                    do {
                                        try await viewModel.resetPassword()
                                        print("Password reset")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            Button("Update email") {
                                Task {
                                    do {
                                        try await viewModel.updateEmail()
                                        print("Email updated")
                                    } catch {
                                        print("Error: \(error)")
                                        emailAlertMessage = error.localizedDescription
                                        showEmailAlert = true
                                    }
                                }
                            }
                            
                            Button("Update password") {
                                Task {
                                    do {
                                        try await viewModel.updatePassword()
                                        print("Password updated")
                                    } catch {
                                        print("Error: \(error)")
                                        emailAlertMessage = error.localizedDescription
                                        showEmailAlert = true
                                    }
                                }
                            }
                        }
                        
                        // MARK: Create account
                        // perhaps dont have the if, just output errors if user tries to link account to google if account already exists
                        if viewModel.authUser?.isAnonymous == true {
                            Button("Create Google account") {
                                Task {
                                    do {
                                        try await viewModel.linkGoogleAccount()
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            Button("Create e-mail account") {
                                Task {
                                    do {
                                        try await viewModel.linkEmailAccount()
                                        print("E-mail linked")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                        }
                        
                        
                        // MARK: All accounts
                        Button("Sign out") {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    showSignInView = true
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete Account")
                        }
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(title: Text("Delete Account"),
                                  message: Text("Would you like to delete account? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete").foregroundColor(.red)) {
                                    Task {
                                        do {
                                            let userId = Auth.auth().currentUser?.uid
                                            try await UserManager.shared.deleteUser(userId: userId!)
                                            try await viewModel.deleteAccount()
                                            showSignInView = true
                                        } catch {
                                            print("Error: \(error)")
                                        }
                                    }
                                },
                                secondaryButton: .cancel())
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
                .frame(height: 300)
                .padding(.bottom)
                .padding(.top)
                
                Line()
                if viewModel.isAdmin {
                    SimpleButton(action: {
                        showReportedPostView = true
                    }, systemImage: "gearshape", buttonText: "Reported posts", size: 30, color: Color("Linen"))
                }
                SimpleButton(action: {
                    showProfileSettingsView = true
                }, systemImage: "person.2.badge.gearshape.fill", buttonText: "Profile settings", size: 30, color: Color("Linen"))
                SimpleButton(action: {
                    showSettingsView = true
                }, systemImage: "gear", buttonText: "App settings", size: 30, color: Color("Linen"))
                SimpleButton(action: {
                    showLikesView = true
                }, systemImage: "heart", buttonText: "Likes", size: 30, color: Color("Linen"))
                SimpleButton(action: {
                    showAboutView = true
                }, systemImage: "info.circle", buttonText: "About", size: 30, color: Color("Linen"))
                .sheet(isPresented: $showReportedPostView) {
                    ReportedPostView()
                }
                .sheet(isPresented: $showProfileSettingsView) {
                    ProfileSettingsView(showSignInView: $showSignInView)
                }
                .sheet(isPresented: $showSettingsView) {
                    SettingsView()
                }
                .sheet(isPresented: $showLikesView) {
                    LikesView()
                }
                .sheet(isPresented: $showAboutView) {
                    AboutView()
                }
                
            }
            .frame(height: geometry.size.height)
            .onAppear() {
                viewModel.checkIfUserIsAdmin()
            }
            .alert(isPresented: $showEmailAlert) {
                Alert(title: Text("Error"), message: Text(emailAlertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


struct PanelView: View {
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
    }
}

extension PanelView {
    private var updateSection: some View {
        Section {
            //button etc
        }
    }
}
