//
//  AppSecrets.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2026-09-12.
//

import Foundation

/// API credentials injected into the app bundle at build time from
/// `Config/Secrets.xcconfig` (see `Config/Secrets.example.xcconfig`).
///
/// No credentials live in source control. Values are surfaced through generated
/// Info.plist keys; a missing or unresolved value resolves to an empty string so
/// callers can report a configuration error instead of sending a request with a
/// blank credential.
enum AppSecrets {
    static let spotifyClientId = value(for: "SpotifyClientID")
    static let spotifyClientSecret = value(for: "SpotifyClientSecret")
    static let tmdbAPIKey = value(for: "TMDBAPIKey")

    private static func value(for key: String) -> String {
        let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        // An unexpanded build setting can end up as the literal "$(VAR)".
        return trimmed.hasPrefix("$(") ? "" : trimmed
    }
}
