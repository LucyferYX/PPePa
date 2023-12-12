//
//  Planet_Pet_PalsApp.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI
import Firebase

@main
struct PPePa: App {
    @StateObject var dataManager = DataManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
//    init() {
//        FirebaseApp.configure()
//        print("Firebase is configured.")
//    }

    var body: some Scene {
        WindowGroup {
//            MainMenuView().environmentObject(dataManager)
            RootView().environmentObject(dataManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase is configured.")
        return true
    }
}


// Viewing the project without launching simulator
//struct Preview: PreviewProvider {
//    static var previews: some View {
//        MainMenuView()
//    }
//}
