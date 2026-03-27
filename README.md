# MuscleWiki

An unofficial exercise database built from [musclewiki.com](https://musclewiki.com/), available as both a **native iOS app** and a **REST API**.

- **954 exercises** with videos, step-by-step instructions, muscle targets, and difficulty ratings
- **100% offline iOS app** — all data is bundled; no network required to browse
- **REST API** deployed on Vercel for third-party integrations

---

## Repository Structure

```
MuscleWiki/
├── backend/                  # Python REST API + data scraper
│   ├── api.py                # Flask API server
│   ├── muscleWiki.py         # One-time web scraper
│   ├── utils.py              # JSON → CSV converter
│   ├── requirements.txt      # Python dependencies
│   └── data/
│       ├── workout-data.json          # 954 exercises (source of truth)
│       ├── workout-attributes.json    # Filter options
│       └── workout-data.csv           # CSV export
├── ios/                      # Native iOS app (Swift 6 / SwiftUI)
│   ├── project.yml           # XcodeGen project spec
│   ├── MuscleWikiApp/        # App source
│   ├── MuscleWikiAppTests/   # Unit tests
│   └── MuscleWikiAppUITests/ # UI tests
├── vercel.json               # Vercel deployment config
└── .gitignore
```

---

## iOS App

A fully offline SwiftUI app targeting **iOS 17+**, built with **Swift 6** and the latest Apple frameworks.

### Key Features

| Feature | Implementation |
|---|---|
| Browse 954 exercises | `ExerciseListView` with `.searchable` + lazy `List` |
| Filter by category, difficulty, force, muscle | `FilterView` bottom sheet, multi-select |
| Browse by muscle group | Interactive `MuscleMapView` grid with exercise counts |
| Exercise details | Steps, muscle targets, difficulty/category badges |
| Demo videos | Inline `AVPlayer` (front + side angle, looping) |
| Full tutorials | YouTube embed via `WKWebView` |
| Favorites | `SwiftData` persistence, swipe-to-delete |
| Offline support | `NWPathMonitor` banner; videos degrade gracefully |
| Home screen search | `CoreSpotlight` indexing of all exercises |
| Accessibility | Full VoiceOver labels, Dynamic Type |

### Quick Start

```bash
# Install XcodeGen (requires Homebrew)
brew install xcodegen

# Generate the Xcode project
cd ios
xcodegen generate

# Open in Xcode
open MuscleWikiApp.xcodeproj
```

Requirements: **Xcode 16+**, **iOS 17+ device or simulator**

See [`ios/README.md`](ios/README.md) for full setup and architecture documentation.

---

## REST API

A lightweight Flask API deployed serverlessly on Vercel, serving the same exercise dataset.

**Base URL:** `https://workoutapi.vercel.app`

### Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/` | Health check |
| `GET` | `/exercises` | List all exercises (supports filters) |
| `GET` | `/exercises/<id>` | Get a single exercise by ID |
| `GET` | `/exercises/attributes` | Available filter values |

### Filter Parameters

`GET /exercises?muscle=Biceps&category=Barbell&difficulty=Beginner&force=Pull&name=curl`

| Parameter | Example values |
|---|---|
| `muscle` | `Biceps`, `Chest`, `Quads`, `Glutes`, … |
| `category` | `Barbell`, `Dumbbells`, `Bodyweight`, `Cables`, … |
| `difficulty` | `Beginner`, `Intermediate`, `Advanced` |
| `force` | `Push`, `Pull`, `Hold` |
| `name` | any substring of the exercise name |

See [`backend/README.md`](backend/README.md) for local development, scraper usage, and deployment instructions.

---

## Data Flow

```
musclewiki.com
      │
      ▼
backend/muscleWiki.py   ← run once to refresh data
      │
      ▼
backend/data/
  workout-data.json          ─────────────────────────┐
  workout-attributes.json    ─────────────────────────┤
      │                                               │
      ▼                                               ▼
backend/api.py              ios/MuscleWikiApp/Resources/
(Vercel REST API)           (bundled in app — offline)
```

---

## License

Data sourced from [musclewiki.com](https://musclewiki.com/). This project is unofficial and not affiliated with MuscleWiki.
