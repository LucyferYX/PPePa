//
//  StatsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 02/01/2024.
//

import SwiftUI

@MainActor
class StatsViewModel: ObservableObject {
    @Published var mostLikedPost: Post?

    func fetchMostLikedPost() async {
        do {
            mostLikedPost = try await PostManager.shared.getMostLikedPost()
        } catch {
            print("Failed to fetch most liked post: \(error)")
        }
    }
}
    
struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel = StatsViewModel()
    @State private var showPostListView: Bool = false
    @Binding var showStatsView: Bool
    
    @State private var flipped = false

    var body: some View {
        ZStack {
            MainBackground()
            VStack {
                NavigationBar
                
                ZStack {
                    PostCircle() {
                        AnyView(
                            VStack {
                                Text("Tap to reveal!")
                                    .foregroundColor(Color("Snow"))
                                    .font(.custom("Baloo2-SemiBold", size: 20))
                            }
                        )
                    }
                    .opacity(flipped ? 0 : 1)
                    PostCircle() {
                        AnyView(
                            VStack {
                                if let post = viewModel.mostLikedPost {
                                    Image(post.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
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
                
                FlipTextButton()
                
                Spacer()
                
                ChartView()
                    .frame(width: 300, height: 200)
                                
                HStack {
                    MainButton(action: { self.showPostListView = true },
                               imageName: "chart.bar.fill",
                               buttonText: "See all posts?",
                               imageColor: Color("Salmon"),
                               buttonColor: Color("Snow"))
                    .padding()
                }
                .fullScreenCover(isPresented: $showPostListView) {
                    PostListView(showPostListView: $showPostListView)
                }
            }
        }
        .task {
            await viewModel.fetchMostLikedPost()
        }
        .onAppear {
            flipped = false
        }
    }
}


struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(showStatsView: .constant(true))
    }
}


extension StatsView {
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
                        Text("\(post.title) is most liked!")
                            .foregroundColor(Color("Walnut"))
                            .font(.custom("Baloo2-Regular", size: 20))
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
            title: "Map",
            leftButton: LeftNavigationButton(
                action: { self.presentationMode.wrappedValue.dismiss() },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: false
            ),
            rightButton: RightNavigationButton(
                action: {},
                imageName: "slider.horizontal.3",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: true
            )
        )
    }
}
