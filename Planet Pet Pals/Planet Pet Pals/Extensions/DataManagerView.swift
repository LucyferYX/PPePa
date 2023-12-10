//
//  DataManagerView.swift
//  Planet Pet Pals
//
//  Created by Liene on 08/12/2023.
//

import SwiftUI
import Firebase
import CoreLocation

class DataManager: ObservableObject {
    @Published var posts: [Post] = []
    
    init() {
        fetchPosts()
        print("fetchposts init accessed")
    }
    
    func fetchPosts() {
        print("fetchPosts called")
        posts.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Post")
        ref.getDocuments { snapshot, error in
            print("Firestore query completed")
            guard error == nil else {
                print("Error fetching documents: \(error!.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                print("Number of documents fetched: \(snapshot.documents.count)")
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let image = data["image"] as? String ?? ""
                    let likes = data["likes"] as? Int ?? 0
                    let views = data["views"] as? Int ?? 0
                    let geoPoint = data["location"] as? GeoPoint
                    let location = CLLocationCoordinate2D(latitude: geoPoint?.latitude ?? 0, longitude: geoPoint?.longitude ?? 0)
                    
                    let post = Post(id: id, title: title, description: description, type: type, image: image, location: location, views: views, likes: likes)
                    self.posts.append(post)
                    print("Fetched post: \(post)")
                    print("Current post count: \(self.posts.count)")
                }
            }
        }
        print("fetchPosts function completed")
    }
    
    
    func newPost(title: String, description: String, type: String, image: String, location: CLLocationCoordinate2D, views: Int, likes: Int) {
        let db = Firestore.firestore()
        let ref = db.collection("Post")
        let id = UUID().uuidString
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        
        ref.document(id).setData([
            "id": id,
            "title": title,
            "description": description,
            "type": type,
            "image": image,
            "location": geoPoint,
            "views": views,
            "likes": likes
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("New post added with ID: \(id)")
            }
        }
    }

//    func newPost() {
//        let db = Firestore.firestore()
//        let ref = db.collection("Post")
//        ref.setData(<#T##Data#>) { error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }
//    }

}
