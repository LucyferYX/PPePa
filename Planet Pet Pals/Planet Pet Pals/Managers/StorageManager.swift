//
//  StorageManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 23/12/2023.
//

import SwiftUI
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    private var profileImagesReference: StorageReference {
        storage.child("profile_images")
    }
    private func userReference(userId: String) -> StorageReference {
        storage.child("Users").child(userId)
    }
    
    func getData(userId: String, path: String) async throws -> Data {
        try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
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
    
    //    func compressImage(image: UIImage, maxSizeKB: Int) -> Data? {
    //        let maxSizeBytes = maxSizeKB * 1024
    //        var compression: CGFloat = 1.0
    //        let step: CGFloat = 0.05
    //        var imageData = image.jpegData(compressionQuality: compression)
    //
    //        while (imageData?.count ?? 0) > maxSizeBytes && compression > 0 {
    //            compression -= step
    //            imageData = image.jpegData(compressionQuality: compression)
    //        }
    //
    //        return imageData
    //    }
    //
    //    func saveImage(image: UIImage, userId: String, maxSizeKB: Int) async throws -> (path: String, name: String) {
    //        guard let data = compressImage(image: image, maxSizeKB: maxSizeKB) else {
    //            throw URLError(.backgroundSessionWasDisconnected)
    //        }
    //
    //        let meta = StorageMetadata()
    //        meta.contentType = "image/jpeg"
    //
    //        let path = "\(UUID().uuidString).jpeg"
    //        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
    //
    //        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
    //            throw URLError(.badServerResponse)
    //        }
    //
    //        return (returnedPath, returnedName)
    //    }

}
