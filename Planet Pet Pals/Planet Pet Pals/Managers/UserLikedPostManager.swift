//
//  UserLikedPostManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 24/12/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserLikedPost: Codable, Equatable {
    let id: String
    let postId: String
    let dateCreated: Date
    
    static func == (lhs: UserLikedPost, rhs: UserLikedPost) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case postId = "post_id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        postId = try container.decode(String.self, forKey: .postId)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(postId, forKey: .postId)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
}

