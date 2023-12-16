//
//  ProfileView.swift
//  Planet Pet Pals
//
//  Created by Liene on 15/12/2023.
//

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DatabaseUser? = nil

    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        VStack {
            Button("Back") {
                showSignInView = false
            }
            .padding()
            List {
                if let user = viewModel.user {
                    Text("User id: \(user.userId)")
                    if let isAnonymous = user.isAnonymous {
                        Text("Is anonymous: \(isAnonymous.description.capitalized)")
                    }
                }
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
}


//@MainActor
//class ProfileViewModel: ObservableObject {
//    @Published private(set) var user: AuthDataResultModel? = nil
//
//    func loadCurrentUser() throws {
//        self.user = try AuthManager.shared.getAuthenticatedUser()
//    }
//
//}
//
//struct ProfileView: View {
//    @StateObject private var viewModel = ProfileViewModel()
//    @Binding var showSignInView: Bool
//
//    var body: some View {
//        VStack {
//            Button("Back") {
//                showSignInView = false
//            }
//            .padding()
//            List {
//                if let user = viewModel.user {
//                    Text("User id: \(user.uid)")
//                }
//            }
//            .onAppear {
//                try? viewModel.loadCurrentUser()
//            }
//        }
//    }
//}


//@MainActor
//class ProfileViewModel: ObservableObject {
//    @Published private(set) var user: DatabaseUser? = nil
//
//    func loadCurrentUser() async throws {
//        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
//        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
//    }
//}
//
//struct ProfileView: View {
//    @StateObject private var viewModel = ProfileViewModel()
//    @Binding var showSignInView: Bool
//
//    var body: some View {
//        VStack {
//            Button("Back") {
//                showSignInView = false
//            }
//            .padding()
//            List {
//                if let user = viewModel.user {
//                    Text("User id: \(user.userId)")
//                    if let isAnonymous = user.isAnonymous {
//                        Text("Is anonymous: \(isAnonymous.description.capitalized)")
//                    }
//                }
//            }
//            .onReceive(Just(viewModel.user)) { user in
//                print("User is printed out!")
//            }
//            .task {
//                try? await viewModel.loadCurrentUser()
//                print("User is printed out from task!")
//            }
//        }
//    }
//}


//2023-12-16 02:11:35.551532+0200 Planet Pet Pals[5539:124211] 9.6.0 - [FirebaseMessaging][I-FCM002022] APNS device token not set before retrieving FCM Token for Sender ID '118749024435'. Notifications to this FCM Token will not be delivered over APNS.Be sure to re-retrieve the FCM token once the APNS device token is set.
