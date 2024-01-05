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
                    .padding(.bottom)
                Text("Please check again shortly.")
                    .font(.custom("Baloo2-SemiBold", size: 25))
                    .foregroundColor(Color("Snow"))
                    .multilineTextAlignment(.center)
                    .opacity(0.6)
            }
        }
        .onAppear {
            CrashlyticsManager.shared.setValue(value: "MaintenanceView", key: "currentView")
        }
    }
}
