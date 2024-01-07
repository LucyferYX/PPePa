//
//  DBPostModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 01/01/2024.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct Post: Codable, Identifiable, Equatable {
    var id: String { postId }
    let postId: String
    let userId: String
    let title: String
    let type: String
    let description: String
    let geopoint: GeoPoint
    let image: String
    var likes: Int?
    var isReported: Bool
    let dateCreated: Date
    var isUserDeleted: Bool?

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
    }

    init(
        postId: String,
        userId: String,
        title: String,
        type: String,
        description: String,
        geopoint: GeoPoint,
        image: String,
        likes: Int,
        isReported: Bool,
        dateCreated: Date
    ) {
        self.postId = postId
        self.userId = userId
        self.title = title
        self.type = type
        self.description = description
        self.geopoint = geopoint
        self.image = image
        self.likes = 0
        self.isReported = false
        self.dateCreated = dateCreated
    }

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case title = "title"
        case type = "type"
        case description = "description"
        case geopoint = "geopoint"
        case image = "image"
        case likes = "likes"
        case isReported = "is_reported"
        case dateCreated = "date_created"
        case isUserDeleted = "is_user_deleted"
    }

    // For comparing 2 posts
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try container.decode(String.self, forKey: .postId)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(String.self, forKey: .type)
        description = try container.decode(String.self, forKey: .description)
        geopoint = try container.decode(GeoPoint.self, forKey: .geopoint)
        image = try container.decode(String.self, forKey: .image)
        likes = try container.decodeIfPresent(Int.self, forKey: .likes)
        isReported = try container.decode(Bool.self, forKey: .isReported)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        isUserDeleted = try container.decodeIfPresent(Bool.self, forKey: .isUserDeleted)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(postId, forKey: .postId)
        try container.encode(userId, forKey: .userId)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(geopoint, forKey: .geopoint)
        try container.encode(image, forKey: .image)
        try container.encode(likes, forKey: .likes)
        try container.encode(isReported, forKey: .isReported)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(isUserDeleted, forKey: .isUserDeleted)
    }
}

