//
//  ContentView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var dataManager = DataManager()
    
    @Binding var showSignInView: Bool
    
    @State private var currentImage: String = ""
    @State private var currentIndex: Int = 0 {
        didSet {
            updateCurrentImage()
        }
    }
    
    @State private var searchText = ""
    @State private var showPanelView = false
    @State private var showAddView = false
    @State private var showMapView = false
    @State private var showStatsView = false
    
    var body: some View {
        return GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .topLeading) {
                    MainBackground()
                    
                    VStack {
                        HStack {
                            PanelButton(action: { showPanelView.toggle() },
                                        systemImage: "line.3.horizontal",
                                        color: Colors.walnut)
                            Spacer()
                        }
                        
                        HStack {
                            SimpleImageView(imageName: "LogoBig", width: 250, height: 120)
                                .padding(.top, -10)
                        }
                        
                        //
                        HStack {
                            SimpleButton(action: {
                                if self.currentIndex > 0 {
                                    self.currentIndex -= 1
                                }
                            }, systemImage: "chevron.left", buttonText: "", size: 30, color: Colors.snow)
                            
                            if dataManager.posts.isEmpty || currentImage.isEmpty {
                                // Display a placeholder or a loading sign
                                Text("Loading...")
                            } else {
                                FadeOutImageView(content: URLImage(placeholder: Image("MainDog"), url: self.currentImage), width: 250, height: 250)
                            }

                            
                            SimpleButton(action: {
                                if self.currentIndex < self.dataManager.posts.count - 1 {
                                    self.currentIndex += 1
                                }
                            }, systemImage: "chevron.right", buttonText: "", size: 30, color: Colors.snow)
                        }
                        //
                        
                        Spacer()
                        
                        MainSearchBar(text: $searchText) {
                            print("Searching for \(searchText)")
                        }

                        
                        Spacer()
                        
                        // Main buttons
                        HStack(spacing: -3) {
                            MainButton(action: { showAddView.toggle() },
                                       imageName: "camera.fill",
                                       buttonText: "Create",
                                       imageColor: Colors.salmon,
                                       buttonColor: Colors.snow)
                            .padding()
                            
                            MainButton(action: { self.showMapView = true },
                                       imageName: "map.fill",
                                       buttonText: "Map",
                                       imageColor: Colors.walnut,
                                       buttonColor: Colors.snow)
                            .padding()
                            
                            MainButton(action: { self.showStatsView = true },
                                       imageName: "chart.bar.fill",
                                       buttonText: "Stats",
                                       imageColor: Colors.salmon,
                                       buttonColor: Colors.snow)
                            .padding()
                            
                        }
                        // Opens the view modally
                        .fullScreenCover(isPresented: $showMapView) {
                            MapView(showMapView: $showMapView, region: "Europe")
                        }
                        .fullScreenCover(isPresented: $showAddView) {
                            CreateView(showAddView: $showAddView)
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
        }
        .onAppear(perform: updateCurrentImage)
    }
    
    private func updateCurrentImage() {
        if !dataManager.posts.isEmpty {
            DispatchQueue.main.async {
                self.currentImage = self.dataManager.posts[self.currentIndex].image
            }
        }
    }
}

struct URLImage: View {
    @State private var uiImage: UIImage? = nil
    let placeholder: Image
    let url: String

    var body: some View {
        if let uiImage = uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            placeholder
                .onAppear(perform: fetch)
        }
    }

    private func fetch() {
        if let imageData = Data(base64Encoded: url) {
            self.uiImage = UIImage(data: imageData)
        } else {
            print("Failed to decode Base64 image")
        }
    }
}
