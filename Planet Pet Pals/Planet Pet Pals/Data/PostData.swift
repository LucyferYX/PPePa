//
//  PostData.swift
//  Planet Pet Pals
//
//  Created by Liene on 08/12/2023.
//

import SwiftUI
import CoreLocation

struct Post: Identifiable {
    var id: String
    var title: String
    var description: String
    var type: String
    var image: String
    var location: CLLocationCoordinate2D
    var views: Int
    var likes: Int
}
