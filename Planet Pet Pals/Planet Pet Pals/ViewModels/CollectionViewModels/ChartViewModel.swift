//
//  ChartViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI

protocol DateCreatable: Codable {
    var dateCreated: Date { get }
}

extension DBUserModel: DateCreatable {}
extension Post: DateCreatable {}

enum DataType {
    case users
    case posts
}

final class ChartViewModel: ObservableObject {
    @Published var userCountsPerDay: [(date: Date, count: Int)] = []
    @Published var maxY: Int = 0
    @Published var minY: Int = Int.max
    var dataType: DataType

    init(dataType: DataType) {
        self.dataType = dataType
        fetchCountsPerDay()
    }

    func fetchCountsPerDay() {
        Task {
            do {
                let data: [DateCreatable]
                switch dataType {
                case .users:
                    data = try await UserManager.shared.getAllUsers()
                case .posts:
                    data = try await PostManager.shared.getAllPosts()
                }

                var counts: [Date: Int] = [:]

                // Determine the date range
                let calendar = Calendar.current
                let startDate = calendar.date(byAdding: .day, value: -30, to: Date())! // 10 days ago
                let endDate = Date() // today

                // Initialize counts for each day in the range to 0
                var date = startDate
                while date <= endDate {
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    let dateWithoutTime = calendar.date(from: components)!
                    counts[dateWithoutTime] = 0
                    date = calendar.date(byAdding: .day, value: 1, to: date)!
                }

                // Count the users created each day
                for datum in data {
                    let dateCreated = datum.dateCreated
                        let components = calendar.dateComponents([.year, .month, .day], from: dateCreated)
                        let dateWithoutTime = calendar.date(from: components)
                    if let dateWithoutTime = dateWithoutTime, counts.keys.contains(dateWithoutTime) {
                        counts[dateWithoutTime]! += 1
                    }
                    
                }

                let countsCopy = counts
                DispatchQueue.main.async {
                    self.userCountsPerDay = countsCopy.sorted(by: { $0.key < $1.key }).map { (date: $0.key, count: $0.value) }
                    self.maxY = self.userCountsPerDay.max(by: { $0.count < $1.count })?.count ?? 0
                    self.minY = self.userCountsPerDay.min(by: { $0.count < $1.count })?.count ?? 0
                }
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }

}
