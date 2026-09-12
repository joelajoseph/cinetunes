//
//  SpotifyService.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-05-28.
//

import Foundation

struct SpotifyAlbum: Codable {
    let name: String
    let externalURLs: [String: String]
    let id: String

    enum CodingKeys: String, CodingKey {
        case name
        case externalURLs = "external_urls"
        case id
    }
}

struct SpotifySearchResponse: Codable {
    struct Albums: Codable {
        let items: [SpotifyAlbum]
    }
    let albums: Albums
}

struct SpotifyTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

enum SpotifyError: LocalizedError {
    case missingCredentials
    case noAccessToken
    case invalidURL
    case requestFailed(statusCode: Int)
    case transport(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Missing Spotify credentials. Set SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET in Config/Secrets.xcconfig."
        case .noAccessToken:
            return "Spotify didn't return an access token."
        case .invalidURL:
            return "Couldn't build the Spotify request."
        case .requestFailed(let statusCode):
            return "Spotify returned an error (status \(statusCode))."
        case .transport(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Couldn't read the response from Spotify."
        }
    }
}

/// An actor so the cached `accessToken` can't be read and written from
/// different threads at the same time.
actor SpotifyService {
    private let clientId = AppSecrets.spotifyClientId
    private let clientSecret = AppSecrets.spotifyClientSecret

    private var accessToken: String?

    // Step 1: Get access token
    func authenticate() async throws {
        guard !clientId.isEmpty, !clientSecret.isEmpty else {
            throw SpotifyError.missingCredentials
        }

        var request = URLRequest(url: try Self.url("https://accounts.spotify.com/api/token"))
        request.httpMethod = "POST"
        let credentials = Data("\(clientId):\(clientSecret)".utf8).base64EncodedString()
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        let data = try await send(request)
        guard let response = try? JSONDecoder().decode(SpotifyTokenResponse.self, from: data) else {
            throw SpotifyError.invalidResponse
        }
        accessToken = response.accessToken
    }

    // Step 2: Search albums using the cached token
    func searchAlbums(query: String) async throws -> [SpotifyAlbum] {
        let token = try await validToken()
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        var request = URLRequest(url: try Self.url("https://api.spotify.com/v1/search?q=\(encoded)&type=album&limit=3"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let data = try await send(request)
        guard let decoded = try? JSONDecoder().decode(SpotifySearchResponse.self, from: data) else {
            throw SpotifyError.invalidResponse
        }
        return decoded.albums.items
    }

    // Step 3: Fetch the album tracks
    func fetchAlbumTracks(albumId: String) async throws -> [Track] {
        let token = try await validToken()
        var request = URLRequest(url: try Self.url("https://api.spotify.com/v1/albums/\(albumId)"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let data = try await send(request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tracksDict = json["tracks"] as? [String: Any],
              let items = tracksDict["items"] as? [[String: Any]] else {
            throw SpotifyError.invalidResponse
        }

        return items.compactMap { item in
            guard let name = item["name"] as? String,
                  let urlDict = item["external_urls"] as? [String: String],
                  let spotifyURL = urlDict["spotify"],
                  let artists = item["artists"] as? [[String: Any]],
                  let artistName = artists.first?["name"] as? String else { return nil }

            return Track(name: name, artist: artistName, spotifyURL: spotifyURL)
        }
    }

    // MARK: - Helpers

    private func validToken() async throws -> String {
        if let token = accessToken { return token }
        try await authenticate()
        guard let token = accessToken else { throw SpotifyError.noAccessToken }
        return token
    }

    private static func url(_ string: String) throws -> URL {
        guard let url = URL(string: string) else { throw SpotifyError.invalidURL }
        return url
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw SpotifyError.transport(error)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw SpotifyError.requestFailed(statusCode: http.statusCode)
        }
        return data
    }
}
