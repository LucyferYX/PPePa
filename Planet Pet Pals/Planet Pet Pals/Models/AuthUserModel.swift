//
//  AuthUserModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 07/01/2024.
//

import SwiftUI
import FirebaseAuth

struct AuthUserModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}
