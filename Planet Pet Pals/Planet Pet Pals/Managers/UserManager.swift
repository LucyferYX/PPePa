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
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let favorites: [String]?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.favorites = nil
    }
    
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        favorites: [String]? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.favorites = favorites
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "is_premium"
        case favorites = "favorites"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        favorites = try container.decodeIfPresent([String].self, forKey: .favorites)
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.isAnonymous, forKey: .isAnonymous)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.isPremium, forKey: .isPremium)
        try container.encode(self.favorites, forKey: .favorites)
    }
}

class UserManager {
    // better not to use singletons, check alternatives
    static let shared = UserManager()
    private init() {}
    // Firestore collection named Users
    private let usersCollection: CollectionReference = Firestore.firestore().collection("Users")
    
    private func usersDocument(userId: String) -> DocumentReference {
        usersCollection.document(userId)
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
    
    func getUser(userId: String) async throws -> DatabaseUser {
        try await usersDocument(userId: userId).getDocument(as: DatabaseUser.self)
    }
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String: Any] = [
            DatabaseUser.CodingKeys.isPremium.rawValue : isPremium
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
    
    func addListenerForPostsLiked(userId: String, completion: @escaping (_ posts: [UserLikedPost]) -> Void) {
        userLikesCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let posts: [UserLikedPost] = documents.compactMap({try? $0.data(as: UserLikedPost.self)})
            completion(posts)
        }
    }
}

struct UserLikedPost: Codable {
    let id: String
    let postId: String
    let dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case postId = "post_id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        postId = try container.decode(String.self, forKey: .postId)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(postId, forKey: .postId)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
}

