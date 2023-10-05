//
//  LoadingView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 05/10/2023.
//

import SwiftUI

class LoadingState: ObservableObject {
    @Published var isLoading = true
}

struct LoadingView: View {
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: 300, height: 20)
                .opacity(0.3)
                .foregroundColor(.gray)
            Rectangle()
                .frame(width: progress * 300, height: 20)
                .foregroundColor(.green)
        }
        .onAppear {
            for i in 1...100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)/100) {
                    withAnimation(.easeInOut) {
                        self.progress += 0.01
                    }
                }
            }
        }
    }
}

//struct LoadingView: View {
//    @State private var progress: CGFloat = 0.0
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//            Rectangle()
//                .frame(width: 300, height: 20)
//                .opacity(0.3)
//                .foregroundColor(.gray)
//            Rectangle()
//                .frame(width: progress * 300, height: 20)
//                .foregroundColor(.green)
//        }
//        .onAppear {
//            for i in 1...100 {
//                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)/100) {
//                    withAnimation(.easeInOut) {
//                        self.progress += 0.01
//                    }
//                }
//            }
//        }
//    }
//}
