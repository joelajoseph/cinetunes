//
//  ContentView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-04-27.
//

import SwiftUI

struct ContentView: View {
    private enum SearchState {
        case idle
        case loading
        case loaded([Movie])
        case empty(String)
        case failed(String)
    }

    @State private var searchQuery = ""
    @State private var searchState: SearchState = .idle
    @FocusState private var isSearchFocused: Bool

    private let movieService = MovieService()

    var body: some View {
        NavigationStack {
            VStack {
                searchBar

                switch searchState {
                case .idle:
                    messageView(
                        icon: "film.stack",
                        title: "Find a soundtrack",
                        message: "Search for a movie to see what music it features."
                    )
                case .loading:
                    Spacer()
                    ProgressView("Searching…")
                        .foregroundColor(.gray)
                    Spacer()
                case .loaded(let movies):
                    List(movies) { movie in
                        NavigationLink(
                            destination: SoundtrackView(
                                movieTitle: movie.originalTitle,
                                movieOverview: movie.overview,
                                posterPath: movie.posterPath
                            )
                        ) {
                            MovieRow(movie: movie)
                        }
                    }
                    .listStyle(.plain)
                case .empty(let query):
                    messageView(
                        icon: "magnifyingglass",
                        title: "No results",
                        message: "No movies matched “\(query)”. Try a different title."
                    )
                case .failed(let message):
                    errorView(message: message)
                }
            }
        }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search for a movie...", text: $searchQuery)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit { search() }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .scaleEffect(isSearchFocused ? 1.03 : 1.0) // ✅ slight zoom on focus
        .shadow(color: isSearchFocused ? .gray.opacity(0.4) : .clear, radius: 6)
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }

    // MARK: - States

    private func messageView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Try Again") {
                search()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Search

    @MainActor
    private func search() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchState = .idle
            return
        }

        searchState = .loading

        Task {
            do {
                let movies = try await movieService.searchMovies(query: query)
                searchState = movies.isEmpty ? .empty(query) : .loaded(movies)
            } catch {
                searchState = .failed(error.localizedDescription)
            }
        }
    }
}

private struct MovieRow: View {
    let movie: Movie

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Poster Image
            if let poster = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w200\(poster)") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 90)
                .cornerRadius(8)
                .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 60, height: 90)
                    .cornerRadius(8)
            }

            // Movie Info
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.originalTitle)
                    .font(.headline)
                if let year = movie.releaseDate {
                    Text("Released: \(year)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Text(movie.overview)
                    .font(.body)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 6)
    }
}
