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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Default language set to english
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, .init(identifier: selectedLanguage))
        }
    }
}

// Configure Firebase upon launching (CONF01)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        print("Firebase is configured.")
        return true
    }
}

// Viewing the project without launching simulator
//struct Preview: PreviewProvider {
//    static var previews: some View {
//        MainMenuView(showSignInView: .constant(false))
//    }
//}
