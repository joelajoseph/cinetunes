//
//  MainTabView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-06-08.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "music.note")
                }
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}