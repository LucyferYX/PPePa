//
//  UserManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 16/12/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DatabaseUser {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
}

class UserManager {
    // better not to use singletons, check alternatives
    static let shared = UserManager()
    private init() {}
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData: [String: Any] = [
            "user_id" : auth.uid,
            "is_anonymous" : auth.isAnonymous,
            "date_created" : Timestamp(),
            
        ]
        if let email = auth.email {
            userData["email"] = email
        }
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        
        try await Firestore.firestore().collection("Users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DatabaseUser {
        let snapshot = try await Firestore.firestore().collection("Users").document(userId).getDocument()
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }

        let isAnonymous = data["is_anonymous"] as? Bool
        let email = data["email"] as? String
        let photoUrl = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        
        return DatabaseUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
    }
}
