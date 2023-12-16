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
    var isPremium: Bool?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
    }
    
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
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
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: DatabaseUser) async throws {
        try usersDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    func getUser(userId: String) async throws -> DatabaseUser {
        try await usersDocument(userId: userId).getDocument(as: DatabaseUser.self, decoder: decoder)
    }
    
    func updateUserPremiumStatus(user: DatabaseUser) async throws {
        try usersDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String: Any] = [
            "is_premium" : isPremium
        ]
        try await usersDocument(userId: userId).updateData(data)
    }
}
