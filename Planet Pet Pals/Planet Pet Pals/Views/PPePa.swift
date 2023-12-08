//
//  Planet_Pet_PalsApp.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI
import FirebaseCore

@main
struct PPePa: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var userAuth = UserAuth()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
//            if userAuth.isLoggedIn {
                MainMenuView()
//            } else {
//                LoginView()
//            }
        }
        //.environmentObject(userAuth)
    }
}


//class UserAuth: ObservableObject {
//    @Published var isLoggedIn: Bool {
//        didSet {
//            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
//        }
//    }
//
//    init() {
//        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//}


// Viewing the project without launching simulator
struct Preview: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
