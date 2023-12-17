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
    @State private var showAboutView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                SimpleButton(action: {
                    print("Username pressed")
                }, systemImage: "", buttonText: "Username", size: 30, color: Colors.linen)
                
                HStack {
                    RoundImage(systemName: "person.circle", size: 80, color: Colors.linen)
                    VStack(alignment: .leading) {
                        Text("LN3569")
                            .font(.custom("Baloo2-SemiBold", size: 20))
                            .foregroundColor(Colors.linen)
                        
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
                                        print("Google account linked")
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
                            showingDeleteAlert = true
                        } label: {
                            Text("Delete Account")
                        }
                        .alert(isPresented: $showingDeleteAlert) {
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
                
                Line()
                
                SimpleButton(action: {
                    print("Favorites pressed")
                }, systemImage: "", buttonText: "Favorites", size: 30, color: Colors.linen)
                SimpleButton(action: {
                    print("Settings pressed")
                }, systemImage: "", buttonText: "Settings", size: 30, color: Colors.linen)
                SimpleButton(action: {
                    print("About pressed")
                    showAboutView = true
                }, systemImage: "", buttonText: "About", size: 30, color: Colors.linen)
                .sheet(isPresented: $showAboutView) {
                    AboutView()
                }
                
            }
            .frame(height: geometry.size.height)
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
                    .background(Colors.walnut)
                    .offset(x: showPanelView ? 0 : -self.width)
                Spacer()
            }
            .background(Colors.walnut.opacity(showPanelView ? 0.5 : 0.0))
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
