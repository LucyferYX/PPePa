//
//  DBUserModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 07/01/2024.
//

import SwiftUI

struct DBUserModel: Codable {
    let userId: String
    let isAdmin: Bool
    var username: String?
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date
    let favorites: [String]?
    
    init(auth: AuthUserModel) {
        self.userId = auth.uid
        self.isAdmin = false
        self.username = "User"
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.favorites = nil
    }
    
    init(
        userId: String,
        isAdmin: Bool,
        username: String? = "User",
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date,
        favorites: [String]? = nil
    ) {
        self.userId = userId
        self.isAdmin = isAdmin
        self.username = username
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.favorites = favorites
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAdmin = "is_admin"
        case username = "username"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case favorites = "favorites"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        favorites = try container.decodeIfPresent([String].self, forKey: .favorites)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.isAdmin, forKey: .isAdmin)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.isAnonymous, forKey: .isAnonymous)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.favorites, forKey: .favorites)
    }
}
