//
//  MovieService.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-04-27.
//

import Foundation

enum MovieServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case requestFailed(statusCode: Int)
    case transport(Error)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing TMDB API key. Set TMDB_API_KEY in Config/Secrets.xcconfig."
        case .invalidURL:
            return "Couldn't build the search request."
        case .requestFailed(let statusCode):
            return "TMDB returned an error (status \(statusCode))."
        case .transport(let error):
            return error.localizedDescription
        case .decoding:
            return "Couldn't read the response from TMDB."
        }
    }
}

final class MovieService {
    private let apiKey = AppSecrets.tmdbAPIKey

    func searchMovies(query: String) async throws -> [Movie] {
        guard !apiKey.isEmpty else {
            throw MovieServiceError.missingAPIKey
        }

        // 1. Prepare the query
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(encoded)&include_adult=false&language=en-US&page=1") else {
            throw MovieServiceError.invalidURL
        }

        // 2. Set up request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // 3. Make the request
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MovieServiceError.transport(error)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw MovieServiceError.requestFailed(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(MovieResponse.self, from: data).results
        } catch {
            throw MovieServiceError.decoding(error)
        }
    }
}
