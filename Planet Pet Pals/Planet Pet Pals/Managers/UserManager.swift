//
//  UserManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 16/12/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {
    static let shared = UserManager()
    private init() {}

    private let usersCollection: CollectionReference = Firestore.firestore().collection("Users")
    
    private func usersDocument(userId: String) -> DocumentReference {
        usersCollection.document(userId)
    }
    
    func getUser(userId: String) async throws -> DBUserModel {
        try await usersDocument(userId: userId).getDocument(as: DBUserModel.self)
    }
    
    func getAllUsers() async throws -> [DBUserModel] {
        try await usersCollection.getDocuments(as: DBUserModel.self)
    }
    
    private func userLikesCollection(userId: String) -> CollectionReference {
        usersDocument(userId: userId).collection("liked_posts")
    }
    
    private func userLikesDocument(userId: String, likedPostId: String) -> DocumentReference {
        userLikesCollection(userId: userId).document(likedPostId)
    }
    
    func createNewUser(user: DBUserModel) async throws {
        try usersDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func deleteUser(userId: String) async throws {
        try await usersDocument(userId: userId).delete()
    }
    
    func updateUserPremiumStatus(userId: String, isAdmin: Bool) async throws {
        let data: [String: Any] = [
            DBUserModel.CodingKeys.isAdmin.rawValue : isAdmin
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func addUserFavorites(userId: String, favorite: String) async throws {
        let data: [String: Any] = [
            DBUserModel.CodingKeys.favorites.rawValue : FieldValue.arrayUnion([favorite])
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func removeUserFavorites(userId: String, favorite: String) async throws {
        let data: [String: Any] = [
            DBUserModel.CodingKeys.favorites.rawValue : FieldValue.arrayRemove([favorite])
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func updateUserPhotoUrl(userId: String, photoUrl: String) async throws {
        let data: [String: Any] = [
            DBUserModel.CodingKeys.photoUrl.rawValue : photoUrl
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    //MARK: Likes
    func addUserLikedPost(userId: String, postId: String) async throws {
        let document = userLikesCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            UserLikedPost.CodingKeys.id.rawValue : documentId,
            UserLikedPost.CodingKeys.postId.rawValue : postId,
            UserLikedPost.CodingKeys.dateCreated.rawValue : Timestamp()
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func removeUserLikedPost(userId: String, likedPostId: String) async throws {
        try await userLikesDocument(userId: userId, likedPostId: likedPostId).delete()
    }
    
    func getAllUserLikes(userId: String) async throws -> [UserLikedPost] {
        try await userLikesCollection(userId: userId).getDocuments(as: UserLikedPost.self)
    }
    
    func updateUserAnonymousStatusAndEmail(userId: String, isAnonymous: Bool, email: String?) async throws {
        let data: [String: Any] = [
            DBUserModel.CodingKeys.isAnonymous.rawValue : isAnonymous,
            DBUserModel.CodingKeys.email.rawValue : email ?? NSNull()
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func updateUsername(userId: String, newUsername: String) async throws {
        let userDocument = usersDocument(userId: userId)
        try await userDocument.updateData([DBUserModel.CodingKeys.username.rawValue: newUsername])
    }
    
    // MARK: Listener for likes
    private var userLikedPostsListener: ListenerRegistration? = nil
    
    func addListenerForPostsLiked(userId: String, completion: @escaping (_ posts: [UserLikedPost]) -> Void) {
        self.userLikedPostsListener = userLikesCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents for liked posts found")
                return
            }
            
            let posts: [UserLikedPost] = documents.compactMap({try? $0.data(as: UserLikedPost.self)})
            completion(posts)
        }
    }
    
    func removeListenerForPostsLiked() {
        self.userLikedPostsListener?.remove()
    }
    
    // MARK: Listener for profile
    private var userProfileListener: ListenerRegistration? = nil

    func addListenerForUserProfile(userId: String, completion: @escaping (_ user: DBUserModel) -> Void) {
        self.userProfileListener = usersDocument(userId: userId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching user: \(error!)")
                return
            }
            guard let user = try? document.data(as: DBUserModel.self) else {
                print("Error decoding user")
                return
            }
            completion(user)
        }
    }

    func removeListenerForUserProfile() {
        self.userProfileListener?.remove()
    }

}
