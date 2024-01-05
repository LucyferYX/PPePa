//
//  PostView.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/12/2023.
//

import SwiftUI
import CoreLocation

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @Binding var showPostView: Bool
    let postId: String
    @State private var showMap = false
    
    var formattedDate: String {
        guard let post = viewModel.post else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: post.dateCreated)
    }

    var body: some View {
        ZStack {
            Color("Walnut")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                NavigationBar()
                ScrollView {
                    if let post = viewModel.post {
                        DynamicImageView(isLoading: viewModel.isLoading, url: URL(string: post.image))
                            .ignoresSafeArea()
                        
                        ZStack {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .fill(.clear)
                                Rectangle()
                                    .fill(Color("Salmon"))
                                Rectangle()
                                    .fill(Color("Salmon"))
                            }
                            HStack(spacing: 0) {
                                Text("\(post.title)")
                                    .font(.custom("Baloo2-SemiBold", size: 40))
                                    .foregroundColor(Color("Gondola"))
                                    .padding()
                                    .padding(.trailing, 7)
                                    .background(
                                        TopRightRoundedRectangle(radius: 30)
                                            .fill(Color("Salmon")))
                                Spacer()
                            }
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Image(systemName: UIImage(systemName: "\(post.type).fill") != nil ? "\(post.type).fill" : "pawprint.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .padding()
                                    .foregroundColor(Color("Walnut"))
                                Text("\(post.type)")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                    .foregroundColor(Color("Gondola"))
                                
                                Spacer()
                                
                                Text("\(post.likes ?? 0)")
                                    .font(.custom("Baloo2-SemiBold", size: 25))
                                    .foregroundColor(Color("Gondola"))
                                    .padding(.trailing, 10)
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("Walnut"))
                                    .padding(.trailing, 20)
                            }

                            HStack(spacing: 0) {
                                Text("\(post.description).")
                                    .padding()
                                    .frame(minWidth: 350, minHeight: 100)
                                    .font(.custom("Baloo2-Regular", size: 20))
                                    .foregroundColor(Color("Gondola"))
                                    .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.5)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                            .padding()
                            
                            Spacer()
                            
                            VStack {
                                Button(action: {
                                    showMap.toggle()
                                }) {
                                    HStack {
                                        Text("Show on map")
                                        Image(systemName: "globe.europe.africa")
                                    }
                                    .font(.custom("Baloo2-Regular", size: 20))
                                    .foregroundColor(Color("Gondola"))
                                    
                                }
                                if showMap {
                                    PostMapView(geopoint: CLLocationCoordinate2D(latitude: post.geopoint.latitude, longitude: post.geopoint.longitude))
                                    .frame(width: 300, height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                            }
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("Post created by: ")
                                        .font(.custom("Baloo2-Regular", size: 20))
                                    Text("\(viewModel.user != nil ? (viewModel.user?.username ?? "Unknown name") : "Deleted user")")
                                        .font(.custom("Baloo2-SemiBold", size: 20))
                                }
                                .foregroundColor(Color("Gondola"))
                                .padding(.trailing, 10)

                                Text("Post created: \(formattedDate)")
                                    .font(.custom("Baloo2-Regular", size: 20))
                                    .foregroundColor(Color("Gondola"))
                                    .padding(.trailing, 10)
                            }
                            .padding()
                        }
                        .edgesIgnoringSafeArea(.all)
                        .background(
                            Rectangle()
                                .fill(Color("Salmon"))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        )
                    } else {
                        ProgressView()
                    }
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "PostView", key: "currentView")
            viewModel.addListenerForPost(postId: postId)
            print("Post listener is turned on")
        }
        .onDisappear {
            viewModel.removeListenerForPost()
            print("Post listener is turned off")
        }
        .task {
            do {
                try await viewModel.loadPost(postId: postId)
                print("User is: \(viewModel.user?.userId ?? "Unknown")")
            } catch {
                print("Failed to load post: \(error)")
            }
        }
    }
}


//struct PostPreviews: PreviewProvider {
//    static var previews: some View {
//        let post = Post(
//            postId: "321BC728-FC0D-4B55-9723-C3E2C04964FC",
//            userId: "ddfW7t4LrmO92KqyOjLSpw6FeGx1",
//            title: "Testforcat",
//            type: "cat",
//            description: "Testing a cat",
//            geopoint: GeoPoint(latitude: 14.462570093365457, longitude: -9.28566454540686),
//            image: "https://firebasestorage.googleapis.com:443/v0/b/planet-pet-pals.appspot.com/o/Users%2FddfW7t4LrmO92KqyOjLSpw6FeGx1%2FD8EE0FDD-C438-4973-9996-596EDD8D8187.jpeg?alt=media&token=706ed3b1-a363-4c67-8e14-4474d941c362",
//            likes: 0,
//            isReported: false,
//            dateCreated: Date(timeIntervalSince1970: 1672449322)
//        )
//        let viewModel = PostViewModel(post: post)
//        return PostView(showPostView: .constant(true), postId: post.postId, viewModel: viewModel)
//    }
//}



extension PostView {
    func NavigationBar() -> some View {
        MainNavigationBar(
            title: "Post",
            leftButton: LeftNavigationButton(
                action: { self.showPostView = false },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: false,
                textInvisible: false
            ),
            rightButton: RightNavigationButton(
                action: {  },
                imageName: "chevron.left",
                buttonText: "Back",
                imageInvisible: true,
                textInvisible: true
            )
        )
    }
}
