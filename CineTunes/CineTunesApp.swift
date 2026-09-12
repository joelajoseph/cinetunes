//
//  CineTunesApp.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-04-27.
//

import SwiftUI

@main
struct CineTunesApp: App {
    @StateObject private var favouritesManager = FavouritesManager()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(favouritesManager)
        }
    }
}
