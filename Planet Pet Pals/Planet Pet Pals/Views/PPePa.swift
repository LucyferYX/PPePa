//
//  Planet_Pet_PalsApp.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 04/10/2023.
//

import SwiftUI

@main
struct PPePa: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

// Viewing the project without launching simulator
struct Preview: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
