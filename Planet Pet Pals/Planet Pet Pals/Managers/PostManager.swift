//
//  PostManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/12/2023.
//

import SwiftUI
import Firebase
import MapKit

struct PostArray: Codable {
    let posts: [Post]
    let total: Int
}

struct Post: Codable, Identifiable {
    var id: String { postId }
    let postId: String
    let userId: String
    let title: String
    let type: String
    let description: String
    let image: String
    var likes: Int?
    var views: Int?
    
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
        image: String,
        likes: Int,
        views: Int
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
        likes = try container.decodeIfPresent(Int.self, forKey: .likes)
        views = try container.decodeIfPresent(Int.self, forKey: .views)
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
    
    func getPost(postId: String) async throws -> Post {
        try await postsDocument(postId: postId).getDocument(as: Post.self)
    }
    
    private func getAllPosts() async throws -> [Post] {
        try await postsCollection.getDocuments(as: Post.self)
    }
    
    private func getAllPostsSortedByLikes(descending: Bool) async throws -> [Post] {
        try await postsCollection
            .order(by: Post.CodingKeys.likes.rawValue, descending: descending)
            .getDocuments(as: Post.self)
    }
    
    private func getAllPostsForTypes(type: String) async throws -> [Post] {
        try await postsCollection
            .whereField(Post.CodingKeys.type.rawValue, isEqualTo: type)
            .getDocuments(as: Post.self)
    }
    
    private func getAllPostsSortedByLikesAndType(descending: Bool, type: String) async throws -> [Post] {
        try await postsCollection
            .whereField(Post.CodingKeys.type.rawValue, isEqualTo: type)
            .order(by: Post.CodingKeys.likes.rawValue, descending: descending)
            .getDocuments(as: Post.self)
    }
    
    func getAllPosts(likesDescending descending: Bool?, forType type: String?) async throws -> [Post] {
        if let descending, let type {
            return try await getAllPostsSortedByLikesAndType(descending: descending, type: type)
        } else if let descending {
            return try await getAllPostsSortedByLikes(descending: descending)
        } else if let type {
            return try await getAllPostsForTypes(type: type)
        }
        
        return try await getAllPosts()
    }
    
    func getPostsByViews(count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument {
            return try await postsCollection
                .order(by: Post.CodingKeys.views.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                .order(by: Post.CodingKeys.views.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        }
    }
    
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).products
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (products, snapshot.documents.last)
    }
}
