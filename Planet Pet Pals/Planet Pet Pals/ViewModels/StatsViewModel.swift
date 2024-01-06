//
//  StatsViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var mostLikedPost: Post?

    func fetchMostLikedPost() async {
        do {
            mostLikedPost = try await PostManager.shared.getMostLikedPost()
        } catch {
            print("Failed to fetch most liked post: \(error)")
        }
    }
}
