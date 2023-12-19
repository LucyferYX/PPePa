//
//  PostsView.swift
//  Planet Pet Pals
//
//  Created by Liene on 19/12/2023.
//

import SwiftUI

struct PostCellView: View {
    let post: Post
    
    var body: some View {
        HStack {
            
            AsyncImage(url: URL(string: post.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 70)
            .shadow(color: Colors.walnut.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack {
                Text(post.title)
                    .font(.headline)
                Text(post.description)
                Label {
                    Text(post.type)
                } icon: {
                    Image(systemName: "pawprint.fill")
                }
            }
            .foregroundColor(.secondary)
        }
    }
}
