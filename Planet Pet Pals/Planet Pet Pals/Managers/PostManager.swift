//
//  PostManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/12/2023.
//

import SwiftUI
import Firebase
import MapKit

struct DatabasePost: Codable, Identifiable {
    var id: String { postId }
    let postId: String
    let userId: String
    let title: String
    let type: String
    let description: String
    let image: String
    var likes: Int
    var views: Int
    
    let geopoint: GeoPoint
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
        image: String
    ) {
        self.postId = postId
        self.userId = userId
        self.title = title
        self.type = type
        self.description = description
        self.geopoint = geopoint
        self.image = image
        self.likes = 0
        self.views = 0
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
        case views = "views"
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
        likes = try container.decode(Int.self, forKey: .likes)
        views = try container.decode(Int.self, forKey: .views)
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
        try container.encode(views, forKey: .views)
    }
}

class PostManager {
    static let shared = PostManager()
    private init() {}
    private let postsCollection = Firestore.firestore().collection("Posts")
    
    private func postsDocument(postId: String) -> DocumentReference {
        postsCollection.document(postId)
    }
    
    func createNewPost(post: DatabasePost) async throws {
        try postsDocument(postId: post.postId).setData(from: post, merge: false)
    }
    
    func deletePost(postId: String) async throws {
        try await postsDocument(postId: postId).delete()
    }
    
    func getPost(postId: String) async throws -> DatabasePost {
        try await postsDocument(postId: postId).getDocument(as: DatabasePost.self)
    }
    
    // ai
    func getAllPosts() async throws -> [DatabasePost] {
        let snapshot = try await postsCollection.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DatabasePost.self) }
    }

    func updatePostLikes(postId: String, likes: Int) async throws {
        let data: [String: Any] = [
            DatabasePost.CodingKeys.likes.rawValue : likes
        ]
        try await postsDocument(postId: postId).updateData(data)
    }
    
    func updatePostViews(postId: String, views: Int) async throws {
        let data: [String: Any] = [
            DatabasePost.CodingKeys.views.rawValue : views
        ]
        try await postsDocument(postId: postId).updateData(data)
    }
}
