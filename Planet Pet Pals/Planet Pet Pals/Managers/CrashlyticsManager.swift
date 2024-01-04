//
//  CrashlyticsManager.swift
//  Planet Pet Pals
//
//  Created by Liene on 03/01/2024.
//

import SwiftUI
import FirebaseCrashlytics

final class CrashlyticsManager {
    static let shared = CrashlyticsManager()
    private init() {}
    
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    func setValue(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)

    }
}
