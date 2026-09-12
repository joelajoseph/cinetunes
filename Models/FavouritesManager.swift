//
//  FavouritesManager.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-06-08.
//

import Foundation

final class FavouritesManager: ObservableObject {
    @Published var favouriteTracks: [Track] = []

    func isFavourited(_ track: Track) -> Bool {
        favouriteTracks.contains(track)
    }

    func toggleFavourite(_ track: Track) {
        if isFavourited(track) {
            favouriteTracks.removeAll { $0 == track }
        } else {
            favouriteTracks.append(track)
        }
    }
}
