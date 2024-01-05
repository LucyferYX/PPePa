//
//  PostListView.swift
//  Planet Pet Pals
//
//  Created by Liene on 29/12/2023.
//

import SwiftUI

class ChartViewModel: ObservableObject {
    @Published var userCountsPerDay: [(date: Date, count: Int)] = []
    @Published var maxY: Int = 0
    @Published var minY: Int = Int.max

    func fetchUserCountsPerDay() {
        Task {
            do {
                let users = try await UserManager.shared.getAllUsers()
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
                for user in users {
                    if let dateCreated = user.dateCreated {
                        let components = calendar.dateComponents([.year, .month, .day], from: dateCreated)
                        let dateWithoutTime = calendar.date(from: components)
                        if let dateWithoutTime = dateWithoutTime, counts.keys.contains(dateWithoutTime) {
                            counts[dateWithoutTime]! += 1
                        }
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



struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    @State private var percentage: CGFloat = 0

    var body: some View {
        VStack {
            chart
                .frame(height: 200)
                .background(background)
                .overlay(yBackground.padding(.horizontal, 5), alignment: .leading)
            
            dateLabels
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "ChartView", key: "currentView")
            viewModel.fetchUserCountsPerDay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.linear(duration: 3.0)) {
                    percentage = 1.0
                }
            }
        }
    }
}

extension ChartView {
    private var chart: some View {
        GeometryReader { geometry in
            Path { path in
                for index in viewModel.userCountsPerDay.indices {
                    let xPosition = geometry.size.width / CGFloat(viewModel.userCountsPerDay.count) * CGFloat(index)
                    let yAxis = CGFloat(viewModel.userCountsPerDay.max(by: { $0.count < $1.count })?.count ?? 0)
                    let yPosition = (1 - CGFloat(viewModel.userCountsPerDay[index].count) / yAxis) * geometry.size.height
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(Color("Orchid"), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: Color("Orchid"), radius: 10, x: 0.0, y: 10)
            .shadow(color: Color("Orchid").opacity(0.5), radius: 10, x: 0.0, y: 20)
            .shadow(color: Color("Orchid").opacity(0.2), radius: 10, x: 0.0, y: 30)
        }
    }
    
    private var dateLabels: some View {
        HStack {
            ForEach(viewModel.userCountsPerDay.indices, id: \.self) { index in
                if index % 5 == 0 {
                    Text(getDateString(from: viewModel.userCountsPerDay[index].date))
                        .font(.footnote)
                        .rotationEffect(.degrees(-45))
                        .fixedSize()
                        .foregroundColor(.black)
                        .font(.custom("Baloo2-Regular", size: 20))
                        .opacity(percentage)
                        .animation(.easeIn(duration: 0.5), value: percentage)
                }
            }
        }
        .frame(height: 50)
    }
    
    private func getDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    private var background: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var yBackground: some View {
        VStack {
            if !viewModel.userCountsPerDay.isEmpty {
                Text("\(viewModel.maxY)")
                    .opacity(percentage)
                    .animation(.easeIn(duration: 0.5), value: percentage)
                Spacer()
                Text("\((viewModel.maxY + viewModel.minY) / 2)")
                    .opacity(percentage)
                    .animation(.easeIn(duration: 0.5), value: percentage)
                Spacer()
                Text("\(viewModel.minY)")
                    .opacity(percentage)
                    .animation(.easeIn(duration: 0.5), value: percentage)
            }
        }
    }
}


//struct PostListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostListView()
//    }
//}
