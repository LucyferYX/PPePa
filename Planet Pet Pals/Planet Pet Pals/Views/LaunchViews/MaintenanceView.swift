//
//  MaintenanceView.swift
//  Planet Pet Pals
//
//  Created by Liene on 27/12/2023.
//

import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        ZStack {
            Color("Walnut")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("This app is under maintenance!")
                    .font(.custom("Baloo2-Bold", size: 30))
                    .foregroundColor(Color("Snow"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text("Please check again shortly.")
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(Color("Snow"))
                    .multilineTextAlignment(.center)
                    .opacity(0.75)
                Text("Thank you for your understanding.")
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(Color("Snow"))
                    .multilineTextAlignment(.center)
                    .opacity(0.75)
            }
            .padding(.horizontal)
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "MaintenanceView", key: "currentView")
        }
    }
}
