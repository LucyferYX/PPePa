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
    private let usersCollection = Firestore.firestore().collection("Users")
    
    private func usersDocument(userId: String) -> DocumentReference {
        usersCollection.document(userId)
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
}
