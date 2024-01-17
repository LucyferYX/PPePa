//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 02/01/2024.
//

import SwiftUI
    
struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel = StatsViewModel()
    @State private var showPostListView: Bool = false
    @State private var showPostView: Bool = false
    @Binding var showStatsView: Bool
    
    @State private var flipped = false
    @State private var selectedDataType: DataType = .users

    var body: some View {
        ZStack {
            MainBackground()
            VStack {
                NavigationBar
                ScrollView {
                    // Most liked post is hidden
                    ZStack {
                        circle1
                        circle2
                    }
                    .rotation3DEffect(
                        .degrees(flipped ? 180 : 0),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    .padding()
                    
                    // Flips over the most liked post
                    FlipTextButton()
                    
                    Line()
                        .padding(.horizontal)
                    
                    // Shows either user or post graph
                    dataTypePickerView(selectedDataType: $selectedDataType)
                        .padding(.horizontal)
                    
                    Line()
                        .padding(.horizontal)
                    
                    // See all posts button
                    postButtonView(showPostListView: $showPostListView)
                }
            }
        }
        .task {
            await viewModel.fetchMostLikedPost()
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "StatsView", key: "currentView")
            flipped = false
        }
        .fullScreenCover(isPresented: $showPostView) {
            if let postId = viewModel.mostLikedPost?.postId {
                PostView(showPostView: $showPostView, postId: postId)
            }
        }
    }
}


// MARK: Extension
extension StatsView {
    private var circle1: some View {
        PostCircle() {
            AnyView(
                VStack {
                    Text("?")
                        .foregroundColor(Color("Snow"))
                        .font(.custom("Baloo2-SemiBold", size: 20))
                }
            )
        }
        .opacity(flipped ? 0 : 1)
    }
    
    private var circle2: some View {
        PostCircle() {
            AnyView(
                VStack {
                    if let post = viewModel.mostLikedPost, let url = URL(string: post.image) {
                        Button(action: {
                            showPostView = true
                        }) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                        }
                    } else {
                        ProgressView()
                    }
                }
                .scaleEffect(x: -1, y: 1)
            )
        }
        .opacity(flipped ? 1 : 0)
    }
    
    func dataTypePickerView(selectedDataType: Binding<DataType>) -> some View {
        VStack {
            Text(selectedDataType.wrappedValue == .users ? "Users created in last 30 days!" : "Posts created in last 30 days!")
                .foregroundColor(Color("Walnut"))
                .font(.custom("Baloo2-SemiBold", size: 20))
            
            ChartView(dataType: selectedDataType.wrappedValue)
                .id(selectedDataType.wrappedValue)
            
            Picker("Data Type", selection: selectedDataType) {
                Text("Users").tag(DataType.users)
                Text("Posts").tag(DataType.posts)
            }
            .pickerStyle(SegmentedPickerStyle())
            .foregroundColor(Color("Gondola"))
            .font(.custom("Baloo2-SemiBold", size: 30))
            .padding()
        }
    }
    
    func postButtonView(showPostListView: Binding<Bool>) -> some View {
        HStack {
            Button(action: {
                showPostListView.wrappedValue = true
            }) {
                Image(systemName: "photo.stack")
                Text("See all posts!")
            }
            .foregroundColor(Color("Walnut"))
            .font(.custom("Baloo2-SemiBold", size: 25))
            .padding()
        }
        .fullScreenCover(isPresented: showPostListView) {
            PostListView(showPostListView: showPostListView)
        }
    }
    
    func postCircleView(flipped: Bool, viewModel: StatsViewModel) -> some View {
        ZStack {
            PostCircle() {
                AnyView(
                    VStack {
                        Text("?")
                            .foregroundColor(Color("Snow"))
                            .font(.custom("Baloo2-SemiBold", size: 20))
                    }
                )
            }
            .opacity(flipped ? 0 : 1)
            PostCircle() {
                AnyView(
                    VStack {
                        if let post = viewModel.mostLikedPost, let url = URL(string: post.image) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                        } else {
                            ProgressView()
                        }
                    }
                    .scaleEffect(x: -1, y: 1)
                )
            }
            .opacity(flipped ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(flipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .padding()
    }
    
    func FlipTextButton() -> some View {
        Button(action: {
            withAnimation(.spring()) {
                flipped.toggle()
            }
        }) {
            Group {
                if !flipped {
                    Text("Most liked post?")
                        .foregroundColor(Color("Walnut"))
                        .font(.custom("Baloo2-SemiBold", size: 20))
                } else {
                    if let post = viewModel.mostLikedPost {
                        VStack {
                            VStack {
                                Text("Most liked post is ")
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                                Text("'\(post.title)'")
                                    .font(.custom("Baloo2-Bold", size: 20))
                            }
                            HStack {
                                Text(" with ")
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                                Text("\(post.likes ?? 0)")
                                    .font(.custom("Baloo2-Bold", size: 20))
                                Text(" likes!")
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                            }
                        }
                        .foregroundColor(Color("Walnut"))
                    } else {
                        Text("Please wait...")
                            .foregroundColor(Color("Walnut"))
                            .font(.custom("Baloo2-Regular", size: 20))
                    }
                }
            }
        }
    }
    
    private var NavigationBar: some View {
        MainNavigationBar(
            title: "Stats",
            leftButton: LeftNavigationButton(
                action: { self.presentationMode.wrappedValue.dismiss() },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: false
            ),
            rightButton: RightNavigationButton(
                action: {},
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: true,
                textInvisible: true
            )
        )
    }
}
