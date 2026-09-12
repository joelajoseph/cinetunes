//
//  LikedSoundtracksView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-06-09.
//

import SwiftUI

struct LikedSoundtracksView: View {
    @EnvironmentObject private var favouritesManager: FavouritesManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if favouritesManager.favouriteTracks.isEmpty {
                    Text("You haven’t liked any tracks yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(favouritesManager.favouriteTracks) { track in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.name)
                                            .font(.headline)
                                            .lineLimit(1)

                                        Text(track.artist)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    if let url = URL(string: track.spotifyURL) {
                                        Link(destination: url) {
                                            Image("spotify_icon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationTitle("Liked Soundtracks")
        .navigationBarTitleDisplayMode(.inline)
    }
}
