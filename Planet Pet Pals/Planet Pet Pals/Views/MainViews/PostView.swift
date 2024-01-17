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
    @State private var showMap = false
    let postId: String
    
    // Formatting the date from timestamp
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
                        // Post image with dynamic effects
                        DynamicImageView(isLoading: viewModel.isLoading, url: URL(string: post.image))
                            .ignoresSafeArea()
                        
                            postTitleView(post: post)
                        
                        // The rest of post information
                        VStack(spacing: 0) {
                            
                            postDetailView(post: post)
                            
                            Spacer()
                            
                            mapView(showMap: $showMap, post: post)
                            
                            postInfoView(viewModel: viewModel, formattedDate: formattedDate)
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


// MARK: Preview
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


// MARK: Extension
extension PostView {
    func postTitleView(post: Post) -> some View {
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
    }

    func postDetailView(post: Post) -> some View {
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
        }
    }
    
    func mapView(showMap: Binding<Bool>, post: Post) -> some View {
        VStack {
            Button(action: {
                DispatchQueue.main.async {
                    showMap.wrappedValue.toggle()
                }
            }) {
                HStack {
                    Text("Show on map")
                    Image(systemName: "globe.europe.africa")
                }
                .font(.custom("Baloo2-Regular", size: 20))
                .foregroundColor(Color("Gondola"))
            }
            if showMap.wrappedValue {
                PostMapView(geopoint: CLLocationCoordinate2D(latitude: post.geopoint.latitude, longitude: post.geopoint.longitude))
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    func postInfoView(viewModel: PostViewModel, formattedDate: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Post created by: ")
                    .font(.custom("Baloo2-Regular", size: 20))
                if let user = viewModel.user {
                    Text(user.username ?? "Unknown name")
                        .font(.custom("Baloo2-SemiBold", size: 20))
                } else {
                    Text("Deleted user")
                        .font(.custom("Baloo2-SemiBold", size: 20))
                }
            }
            .foregroundColor(Color("Gondola"))
            .padding(.trailing, 10)
            HStack {
                Text("Post created: ")
                Text("\(formattedDate)")
            }
            .font(.custom("Baloo2-Regular", size: 20))
            .foregroundColor(Color("Gondola"))
            .padding(.trailing, 10)
        }
        .padding()
    }
    
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
