//
//  UserManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 16/12/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DatabaseUser: Codable {
    let userId: String
    var username: String?
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isAdmin: Bool?
    let favorites: [String]?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.username = "User"
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isAdmin = false
        self.favorites = nil
    }
    
    init(
        userId: String,
        username: String? = "User",
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isAdmin: Bool? = nil,
        favorites: [String]? = nil
    ) {
        self.userId = userId
        self.username = username
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isAdmin = false
        self.favorites = favorites
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username = "username"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isAdmin = "is_admin"
        case favorites = "favorites"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin)
        favorites = try container.decodeIfPresent([String].self, forKey: .favorites)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.isAnonymous, forKey: .isAnonymous)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.isAdmin, forKey: .isAdmin)
        try container.encode(self.favorites, forKey: .favorites)
    }
}


final class UserManager {
    static let shared = UserManager()
    private init() {}

    private let usersCollection: CollectionReference = Firestore.firestore().collection("Users")
    
    private func usersDocument(userId: String) -> DocumentReference {
        usersCollection.document(userId)
    }
    
    func getUser(userId: String) async throws -> DatabaseUser {
        try await usersDocument(userId: userId).getDocument(as: DatabaseUser.self)
    }
    
    func getAllUsers() async throws -> [DatabaseUser] {
        try await usersCollection.getDocuments(as: DatabaseUser.self)
    }
    
    private func userLikesCollection(userId: String) -> CollectionReference {
        usersDocument(userId: userId).collection("liked_posts")
    }
    
    private func userLikesDocument(userId: String, likedPostId: String) -> DocumentReference {
        userLikesCollection(userId: userId).document(likedPostId)
    }
    
    func createNewUser(user: DatabaseUser) async throws {
        try usersDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func deleteUser(userId: String) async throws {
        try await usersDocument(userId: userId).delete()
    }
    
    func updateUserPremiumStatus(userId: String, isAdmin: Bool) async throws {
        let data: [String: Any] = [
            DatabaseUser.CodingKeys.isAdmin.rawValue : isAdmin
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func addUserFavorites(userId: String, favorite: String) async throws {
        let data: [String: Any] = [
            DatabaseUser.CodingKeys.favorites.rawValue : FieldValue.arrayUnion([favorite])
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func removeUserFavorites(userId: String, favorite: String) async throws {
        let data: [String: Any] = [
            DatabaseUser.CodingKeys.favorites.rawValue : FieldValue.arrayRemove([favorite])
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func updateUserPhotoUrl(userId: String, photoUrl: String) async throws {
        let data: [String: Any] = [
            DatabaseUser.CodingKeys.photoUrl.rawValue : photoUrl
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
            DatabaseUser.CodingKeys.isAnonymous.rawValue : isAnonymous,
            DatabaseUser.CodingKeys.email.rawValue : email ?? NSNull()
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
    
    func updateUsername(userId: String, newUsername: String) async throws {
        let userDocument = usersDocument(userId: userId)
        try await userDocument.updateData([DatabaseUser.CodingKeys.username.rawValue: newUsername])
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

    func addListenerForUserProfile(userId: String, completion: @escaping (_ user: DatabaseUser) -> Void) {
        self.userProfileListener = usersDocument(userId: userId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching user: \(error!)")
                return
            }
            guard let user = try? document.data(as: DatabaseUser.self) else {
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
