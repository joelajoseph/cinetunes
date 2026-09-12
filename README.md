# CineTunes

> **Archived project.** This is an early iOS app I built to learn SwiftUI and
> working with third-party APIs. It is no longer maintained and is kept here for
> reference.
>
> Originally built as part of the Develop the Future Co-op final showcase.

CineTunes answers a small question: *what music is in this movie?* Search for a
film, see its soundtrack, and open the tracks in Spotify.

## Why this was archived

**Spotify changed its developer policy in February 2026.** Development Mode apps
now require the app owner to hold an active **Spotify Premium** subscription, and
test users are capped at five.

That was the end of this project. The entire point was reading a film's
soundtrack out of Spotify, and paying for a Premium subscription to keep a
learning project alive wasn't worth it.

The app still works end to end against TMDB though. Only the Spotify half is gated
behind a subscription, which is why the screenshots below stop at "Missing
Spotify credentials".

## What it does

1. **Search a movie** — queries the TMDB API and
   lists matching films with poster, release date, and plot summary.
2. **Find the soundtrack** — looks the film up on Spotify and lists the tracks
   from the best-matching album.
3. **Open or save** — tap the Spotify icon on a track to open it in the app, or
   tap the heart to add it to your liked soundtracks.

The search screen handles all four states explicitly: an initial prompt before
searching, a spinner while loading, a "no results" message naming the query, and
an error view with a **Try Again** button.


## How it's put together

```
CineTunes/
├── CineTunes/          SwiftUI views, app entry point, asset catalog
├── Models/             Data models, API services, favourites store, secrets reader
├── Config/             xcconfig files; credentials injected at build time
└── CineTunes.xcodeproj
```

Credentials flow from `Secrets.xcconfig` → build settings → generated
`Info.plist` keys → the `AppSecrets` reader, so no API key is ever written into
a Swift file.

- **SwiftUI**, iOS 17.5+, iPhone and iPad
- **async/await** throughout; `SpotifyService` is an `actor`, so its cached token
  is safe across concurrent calls
- **URLSession + Codable** with typed errors that surface in the UI rather than
  being swallowed
- **State** via `FavouritesManager`, an `ObservableObject` injected through the
  SwiftUI environment
- Networking is split from the views: `MovieService` (TMDB) and `SpotifyService`
  (Spotify), both consumed from `@MainActor` view code

## Screenshots

Searching for a film returns real results from TMDB:

<p align="center">
  <img src="Screenshots/02-search-results.png" width="290" alt="Search results for Inception, showing posters, release dates and plot summaries">
</p>

Opening one shows the film's details and plot, then stops at the Spotify
credential wall — which is where this project ended:

<p align="center">
  <img src="Screenshots/03-soundtrack.png" width="290" alt="Film detail screen reporting that Spotify credentials are missing">
</p>

The rest is navigation plus the three screens that were never built:

<p align="center">
  <img src="Screenshots/01-home-idle.png" width="180" alt="Home screen before searching">
  <img src="Screenshots/04-library.png" width="180" alt="Library screen">
  <img src="Screenshots/07-discover.png" width="180" alt="Discover placeholder screen">
</p>

---