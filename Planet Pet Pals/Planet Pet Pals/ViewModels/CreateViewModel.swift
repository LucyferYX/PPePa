//
//  CreateViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 31/12/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

@MainActor
class CreateViewModel: ObservableObject {
    @Published private(set) var user: DatabaseUser? = nil
    @Published private(set) var image: UIImage? = nil
    
    @Published var isUploading = false
    @Published var uploadCompleted = false
    @Published var showUnsupportedFormatAlert = false
    
    func fetchUser() async {
        do {
            if let userId = Auth.auth().currentUser?.uid {
                let fetchedUser = try await UserManager.shared.getUser(userId: userId)
                DispatchQueue.main.async {
                    self.user = fetchedUser
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    func loadImage(item: PhotosPickerItem?) async {
        if let item = item {
            do {
                if let imageData = try await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.image = uiImage
                        }
                    }
                } else {
                    print("Failed to load image data")
                    DispatchQueue.main.async {
                        self.showUnsupportedFormatAlert = true
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
                DispatchQueue.main.async {
                    self.showUnsupportedFormatAlert = true
                }
            }
        }
    }

    
    func saveImage(item: PhotosPickerItem, title: String, type: String, description: String, location: CLLocationCoordinate2D) async throws {
        guard let user = user else {
            print("User is nil")
            return
        }
        DispatchQueue.main.async {
            self.isUploading = true
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Failed to load image data")
                DispatchQueue.main.async {
                    self.showUnsupportedFormatAlert = true
                }
                return
            }
            print("Image data loaded")
            
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("Image uploaded to storage: \(path), \(name)")
            
            let imageUrl = try await StorageManager.shared.getDownloadUrl(userId: user.userId, path: name)
            print("Image download URL: \(imageUrl)")
            
            let post = Post(postId: UUID().uuidString, userId: user.userId, title: title, type: type, description: description, geopoint: GeoPoint(latitude: location.latitude, longitude: location.longitude), image: imageUrl, likes: 0, views: 0)
            try await PostManager.shared.savePost(post: post)
            print("Post saved successfully")
            DispatchQueue.main.async {
                self.uploadCompleted = true
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            print("Failed to upload post: \(error)")
        }
        DispatchQueue.main.async {
            self.isUploading = false
            self.uploadCompleted = false
        }
    }
}
