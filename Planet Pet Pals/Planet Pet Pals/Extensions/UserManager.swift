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
    
//    func togglePremiumStatus() -> DatabaseUser {
//        let currentValue = isPremium ?? false
//        return DatabaseUser(userId: userId,
//                            isAnonymous: isAnonymous,
//                            email: email,
//                            photoUrl: photoUrl,
//                            dateCreated: dateCreated,
//                            isPremium: !currentValue)
//    }
    
    mutating func togglePremiumStatus() {
        let currentValue = isPremium ?? false
        isPremium = !currentValue
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
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String: Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//
//        try await usersDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DatabaseUser {
        try await usersDocument(userId: userId).getDocument(as: DatabaseUser.self, decoder: decoder)
    }
    
//    func getUser(userId: String) async throws -> DatabaseUser {
//        let snapshot = try await usersDocument(userId: userId).getDocument()
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//        
//        return DatabaseUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
    func updateUserPremiumStatus(user: DatabaseUser) async throws {
        try usersDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
}
