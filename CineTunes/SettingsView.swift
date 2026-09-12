//
//  SettingsView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-06-09.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: LikedSoundtracksView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)

                            Text("Liked Soundtracks")
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }

                    NavigationLink(destination: FavouriteMoviesView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "film.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            Text("Favourite Movies")
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
