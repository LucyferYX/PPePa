//
//  PostManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 18/12/2023.
//

import SwiftUI
import FirebaseFirestore

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
    
    func getAllUserPosts(userId: String) async throws -> [Post] {
        let query = postsCollection.whereField(Post.CodingKeys.userId.rawValue, isEqualTo: userId)
        return try await query.getDocuments(as: Post.self)
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
    
    func deletePost(postId: String) async throws {
        try await postsCollection.document(postId).delete()
    }
    
    func updatePostsForDeletedUser(userId: String?) async throws {
        guard let userId = userId else { return }

        let postsByUser = postsCollection.whereField(Post.CodingKeys.userId.rawValue, isEqualTo: userId)
        let snapshot = try await postsByUser.getDocuments()
        let batch = Firestore.firestore().batch()

        snapshot.documents.forEach { document in
            let postRef = postsCollection.document(document.documentID)
            batch.updateData([Post.CodingKeys.isUserDeleted.rawValue: true], forDocument: postRef)
        }

        try await batch.commit()
    }
    
    func reportPost(postId: String) async throws {
        let data: [String: Any] = [
            Post.CodingKeys.isReported.rawValue : true
        ]
        try await postsDocument(postId: postId).updateData(data)
    }
    
    func updatePostReportStatus(postId: String, isReported: Bool) async throws {
        let data: [String: Any] = [
            Post.CodingKeys.isReported.rawValue : isReported
        ]
        try await postsDocument(postId: postId).updateData(data)
    }
    
    func getMostLikedPost() async throws -> Post? {
        let query = getAllPostsSortedByLikesQuery(descending: true).limit(to: 1)
        let posts = try await query.getDocuments(as: Post.self)
        return posts.first
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
        
        let (newPosts, lastDocument) = try await query
            .startOptional(afterDocument: lastDocument)
            .limit(to: count)
            .getDocumentsWithSnapshot(as: Post.self)
        
        var posts: [Post] = []
        for post in newPosts {
            if !posts.contains(where: { $0.id == post.id }) {
                posts.append(post)
            }
        }
        
        return (posts, lastDocument)
    }

    func getPostsByDate(count: Int, lastDocument: DocumentSnapshot?) async throws -> (posts: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await postsCollection
                .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
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
    
    //MARK: Listener for user own posts
    private var myPostsListener: ListenerRegistration? = nil

    func addListenerForMyPosts(userId: String, completion: @escaping (_ posts: [Post]) -> Void) {
        self.myPostsListener = postsCollection
            .whereField(Post.CodingKeys.userId.rawValue, isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents for my posts found")
                    return
                }

                let posts: [Post] = documents.compactMap({try? $0.data(as: Post.self)})
                completion(posts)
            }
    }

    func removeListenerForMyPosts() {
        self.myPostsListener?.remove()
    }

    
    //MARK: Listener for deleted posts
    private var deletedUsersPostsListener: ListenerRegistration? = nil

    func addListenerForDeletedUsersPosts(completion: @escaping (_ posts: [Post]) -> Void) {
        self.deletedUsersPostsListener = postsCollection
            .whereField(Post.CodingKeys.isUserDeleted.rawValue, isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents for deleted users posts found")
                    return
                }

                let posts: [Post] = documents.compactMap({try? $0.data(as: Post.self)})
                completion(posts)
            }
    }

    func removeListenerForDeletedUsersPosts() {
        self.deletedUsersPostsListener?.remove()
    }

    
    //MARK: Listener for reports
    private var reportedPostsListener: ListenerRegistration? = nil

    func addListenerForReportedPosts(completion: @escaping (_ posts: [Post]) -> Void) {
        self.reportedPostsListener = postsCollection
            .whereField(Post.CodingKeys.isReported.rawValue, isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents for reported posts found")
                    return
                }

                let posts: [Post] = documents.compactMap({try? $0.data(as: Post.self)})
                completion(posts)
            }
    }

    func removeListenerForReportedPosts() {
        self.reportedPostsListener?.remove()
    }
    
    
    // MARK: Listener for post
    private var postListener: ListenerRegistration? = nil

    func addListenerForPost(postId: String, completion: @escaping (_ post: Post?) -> Void) {
        self.postListener = postsDocument(postId: postId)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("No document for post found")
                    return
                }

                let post = try? document.data(as: Post.self)
                completion(post)
            }
    }

    func removeListenerForPost() {
        self.postListener?.remove()
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
