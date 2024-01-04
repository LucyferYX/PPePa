//
//  MaintenanceManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 03/01/2024.
//

import SwiftUI
import FirebaseFirestore

final class MaintenanceManager {
    static let shared = MaintenanceManager()
    private init() {}
    private let maintenanceCollection = Firestore.firestore().collection("Maintenance")
    
    private func maintenanceDocument(docId: String) -> DocumentReference {
        maintenanceCollection.document(docId)
    }
    
    func getMaintenanceFlag(docId: String) async throws -> Bool {
        let document = try await maintenanceDocument(docId: docId).getDocument(source: .server)
        let flag = document.get("flag") as? Bool ?? false
        return flag
    }
}

