//
//  PostManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/12/2023.
//

import SwiftUI
import Firebase
import MapKit

//struct PostArray: Codable {
//    let posts: [Post]
//    let total: Int
//}

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
    var views: Int?
    let dateCreated: Date

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
        views: Int,
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
        self.views = 0
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
        case views = "views"
        case dateCreated = "date_created"
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
        views = try container.decodeIfPresent(Int.self, forKey: .views)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
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
        try container.encode(dateCreated, forKey: .dateCreated)
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
    
    func getAllPosts() async throws -> [Post] {
        try await getAllPostsQuery().getDocuments(as: Post.self)
    }
    
    func getAllPostsBy1(startAfter: DocumentSnapshot? = nil) async throws -> ([Post], DocumentSnapshot?) {
        var query = postsCollection.order(by: Post.CodingKeys.dateCreated.rawValue, descending: true).limit(to: 1)
        if let lastSnapshot = startAfter {
            query = query.start(afterDocument: lastSnapshot)
        }
        let (posts, lastDocument) = try await query.getDocumentsWithSnapshot(as: Post.self)
        return (posts, lastDocument)
    }
    
    func savePost(post: Post) async throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(post)
        let docRef = postsDocument(postId: post.postId)
        
        return try await withCheckedThrowingContinuation { continuation in
            docRef.setData(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private func getAllPostsQuery() -> Query {
        postsCollection
    }
    
    private func getAllPostsSortedByLikesQuery(descending: Bool) -> Query {
        postsCollection
            .order(by: Post.CodingKeys.likes.rawValue, descending: descending)
    }
    
    private func getAllPostsForTypesQuery(type: String) -> Query {
        postsCollection
            .whereField(Post.CodingKeys.type.rawValue, isEqualTo: type)
    }
    
    private func getAllPostsSortedByLikesAndTypeQuery(descending: Bool, type: String) -> Query {
        postsCollection
            .whereField(Post.CodingKeys.type.rawValue, isEqualTo: type)
            .order(by: Post.CodingKeys.likes.rawValue, descending: descending)
    }
    
    func getAllPosts(likesDescending descending: Bool?, forType type: String?, count: Int, lastDocument: DocumentSnapshot?)
    async throws -> (posts: [Post], lastDocument: DocumentSnapshot?) {
        var query: Query = getAllPostsQuery()
        
        if let descending, let type {
            query = getAllPostsSortedByLikesAndTypeQuery(descending: descending, type: type)
        } else if let descending {
            query = getAllPostsSortedByLikesQuery(descending: descending)
        } else if let type {
            query = getAllPostsForTypesQuery(type: type)
        }
        
        return try await query
            .startOptional(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    func getPostsByViews(count: Int, lastDocument: DocumentSnapshot?) async throws -> (posts: [Post], lastDocument: DocumentSnapshot?) {
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
    
    func getAllPostsCount() async throws -> Int {
        try await postsCollection
            .aggregateCount()
    }
    
    //MARK: Likes
    func incrementLikes(postId: String) async throws {
        let postRef = postsDocument(postId: postId)
        _ = try await Firestore.firestore().runTransaction { transaction, errorPointer in
            do {
                let postSnapshot = try transaction.getDocument(postRef)
                guard let oldLikes = postSnapshot.data()?["likes"] as? Int else {
                    errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve likes from snapshot \(postSnapshot)"
                    ])
                    return nil
                }
                transaction.updateData(["likes": oldLikes + 1], forDocument: postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
            }
            return nil
        }
    }
    
    func decrementLikes(postId: String) async throws {
        let postRef = postsDocument(postId: postId)
        _ = try await Firestore.firestore().runTransaction { transaction, errorPointer in
            do {
                let postSnapshot = try transaction.getDocument(postRef)
                guard let oldLikes = postSnapshot.data()?["likes"] as? Int else {
                    errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve likes from snapshot \(postSnapshot)"
                    ])
                    return nil
                }
                transaction.updateData(["likes": oldLikes - 1], forDocument: postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
            }
            return nil
        }
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).posts
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (posts: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let posts = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (posts, snapshot.documents.last)
    }
    
    func startOptional(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else {
            return self
        }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
}
