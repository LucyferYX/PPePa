//
//  RootViewModel.swift
//  Planet Pet Pals
//
//  Created by Liene on 06/01/2024.
//

import SwiftUI

class RootViewModel: ObservableObject {
    @Published var showMaintenanceView: Bool = false
    @Published var documentExists: Bool = true
    @Published var showAlert: Bool = false
    
    // Function for checking maintenance status
    func checkMaintenance() async {
        do {
            let isUnderMaintenance = try await MaintenanceManager.shared.getMaintenanceFlag(docId: "1")
            DispatchQueue.main.async {
                self.showMaintenanceView = isUnderMaintenance
                print("Maintenance is set to: \(isUnderMaintenance ? "true" : "false")")
            }
        } catch {
            print("Error in checkMaintenance: \(error)")
            DispatchQueue.main.async {
                self.documentExists = false
                self.showAlert = !self.documentExists
            }
        }
    }
}
