# Flutter Spaceflight News App

A production-ready Flutter application built for a take-home assignment. It fetches real spaceflight news articles from the [Spaceflight News API](https://api.spaceflightnewsapi.net/v4/articles), provides pagination, offline caching, and handles all key states.

## Setup Instructions
1. Ensure you have Flutter SDK installed (version 3.x+).
2. Clone or open this repository.
3. From the project root, run:
   ```
   flutter pub get
   flutter run
   ```
4. Run on an Android emulator/device (tested on Android 12+).

---

## Architecture Overview

This project follows **Clean Architecture** combined with the **BLoC** state management pattern.

```
lib/
├── core/
│   ├── network/          # Dio HTTP client
│   └── local_storage/    # SQLite database helper
├── features/news/
│   ├── data/
│   │   ├── models/           # NewsModel (JSON serialization)
│   │   ├── datasources/      # Remote (Dio) + Local (sqflite)
│   │   └── repositories/     # Repository implementation
│   ├── domain/
│   │   ├── repositories/     # Abstract contract
│   │   └── usecases/         # GetNewsUseCase
│   └── presentation/
│       ├── bloc/             # NewsBloc, NewsEvent, NewsState
│       └── pages/            # NewsListPage, NewsDetailPage
├── injection_container.dart  # GetIt dependency injection
└── main.dart
```

### Key Decisions & Trade-offs

| Decision | Rationale |
|---|---|
| **BLoC** for state management | Predictable unidirectional data flow, great for pagination and async state |
| **sqflite** for offline caching | Mature, battle-tested SQL-based local storage. `hive` is faster, but SQL is more queryable |
| **GetIt** for dependency injection | Lightweight service locator; avoids boilerplate of Provider/Riverpod for a small project |
| **Dio** for networking | Interceptors, timeout configuration, and better error types than `http` |
| **Single NewsState** class | One `copyWith` state rather than separate `Loading/Loaded/Error` classes — simpler to manage progressive states like pagination |

### API
- **Spaceflight News API v4** – Free, no API key required.
- Base URL: `https://api.spaceflightnewsapi.net/v4/`
- Pagination via `?limit=10&offset=N`

### Offline Strategy
- On success: clears page-one cache and re-caches the fresh batch
- On failure (first page): silently returns the SQLite cache
- On failure (pagination): shows a snackbar, reverts offset counter

### Known Limitations
- Cached data is stored as a flat list; pagination beyond page 1 is not cached
- No search or filtering
- No unit tests included in this submission
- `url_launcher` requires a browser app installed on the device

---

## Animations
- **Staggered list entrance**: Each item fades and slides in with a slight delay
- **Page transition**: Custom fade+slide when navigating to the detail screen  
- **Hero transition**: The article thumbnail expands into the full-width image on the detail screen
