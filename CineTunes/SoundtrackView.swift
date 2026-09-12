//
//  SoundtrackView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-05-28.
//

import SwiftUI

struct Track: Identifiable, Equatable, Hashable {
    // The Spotify URL is unique per track; name + artist collides for reprises,
    // live versions, and duplicate titles, which breaks ForEach identity.
    var id: String { spotifyURL }
    let name: String
    let artist: String
    let spotifyURL: String
}

struct SoundtrackView: View {
    @EnvironmentObject private var favouritesManager: FavouritesManager

    let movieTitle: String
    let movieOverview: String
    let posterPath: String?

    @State private var tracks: [Track] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    // `@State` keeps one service (and its cached token) alive across re-renders.
    @State private var spotifyService = SpotifyService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Movie Poster + Info
                HStack(alignment: .top, spacing: 16) {
                    if let path = posterPath,
                       let url = URL(string: "https://image.tmdb.org/t/p/w300\(path)") {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130)
                                .cornerRadius(12)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                                .frame(width: 130, height: 180)
                                .cornerRadius(12)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(movieTitle)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(movieOverview)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(5)
                            .truncationMode(.tail)
                            .frame(maxHeight: 180, alignment: .top)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Track List
                if isLoading {
                    ProgressView("Loading Soundtrack...")
                        .padding()
                } else if let errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Couldn't load the soundtrack.")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button("Try Again") {
                            Task { await fetchTracks() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if tracks.isEmpty {
                    Text("No soundtrack found on Spotify.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(tracks) { track in
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

                                    HStack(spacing: 16) {
                                        if let url = URL(string: track.spotifyURL) {
                                            Link(destination: url) {
                                                Image("spotify_icon")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                            }
                                            .buttonStyle(.plain)
                                        }

                                        Button(action: {
                                            favouritesManager.toggleFavourite(track)
                                        }) {
                                            Image(systemName: favouritesManager.isFavourited(track) ? "heart.fill" : "heart")
                                                .resizable()
                                                .frame(width: 20, height: 18)
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationTitle(movieTitle)
        .navigationBarTitleDisplayMode(.inline)
        // `.task` runs on the main actor and is cancelled if the view disappears.
        .task { await fetchTracks() }
    }

    @MainActor
    private func fetchTracks() async {
        isLoading = true
        errorMessage = nil

        do {
            let query = movieTitle + " soundtrack"
            if let album = try await spotifyService.searchAlbums(query: query).first {
                tracks = try await spotifyService.fetchAlbumTracks(albumId: album.id)
            } else {
                tracks = []
            }
        } catch {
            errorMessage = error.localizedDescription
            tracks = []
        }

        isLoading = false
    }
}
