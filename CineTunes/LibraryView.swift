//
//  LibraryView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-06-08.
//

import SwiftUI

struct LibraryView: View {
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
                            Image(systemName: "video.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            Text("Favourite Movies")
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }

                    NavigationLink(destination: RecentlyPlayedView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "clock.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            Text("Recently Played")
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Library")
        }
    }
}
