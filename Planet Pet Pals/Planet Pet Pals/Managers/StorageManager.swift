//
//  StorageManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/12/2023.
//

import SwiftUI
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    private var profileImagesReference: StorageReference {
        storage.child("Profile")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("Users").child(userId)
    }
    
    func getData(userId: String, path: String) async throws -> Data {
        try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
    
    func getProfileImages() async throws -> [String] {
        let profileImagesReference = storage.child("Profile")
        let listResult = try await profileImagesReference.listAll()
        return listResult.items.map { $0.name }
    }
    
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)

        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }

        return (returnedPath, returnedName)
    }

    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage(data: data, userId: userId)
    }
    
    func getDownloadUrl(userId: String, path: String) async throws -> String {
        let imageRef = userReference(userId: userId).child(path)
        return try await withCheckedThrowingContinuation { continuation in
            imageRef.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url.absoluteString)
                }
            }
        }
    }

}
