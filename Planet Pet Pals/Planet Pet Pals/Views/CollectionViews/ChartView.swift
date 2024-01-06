//
//  PostListView.swift
//  Planet Pet Pals
//
//  Created by Liene on 29/12/2023.
//

import SwiftUI

struct ChartView: View {
    @StateObject private var viewModel: ChartViewModel
    @State private var percentage: CGFloat = 0

    init(dataType: DataType) {
        _viewModel = StateObject(wrappedValue: ChartViewModel(dataType: dataType))
    }

    var body: some View {
        VStack {
            chart
            
            dateLabels
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "ChartView", key: "currentView")
            viewModel.fetchCountsPerDay()
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
        .frame(height: 200)
        .background(background)
        .overlay(yBackground.padding(.horizontal, 5), alignment: .leading)
    }
    
    private var dateLabels: some View {
        HStack {
            ForEach(viewModel.userCountsPerDay.indices, id: \.self) { index in
                if index % 5 == 0 {
                    Text(getDateString(from: viewModel.userCountsPerDay[index].date))
                        .font(.footnote)
                        .rotationEffect(.degrees(-45))
                        .fixedSize()
                        .foregroundColor(Color("Gondola"))
                        .font(.custom("Baloo2-Regular", size: 20))
                        .opacity(percentage)
                        .animation(.easeIn(duration: 0.5), value: percentage)
                }
            }
        }
        .frame(height: 80)
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
