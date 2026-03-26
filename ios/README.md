# MuscleWiki — iOS App

A fully offline native iOS app for browsing 954 exercises, built with **Swift 6**, **SwiftUI**, and the latest Apple frameworks.

---

## Requirements

| Tool | Version |
|---|---|
| Xcode | 16.0+ |
| iOS deployment target | 17.0+ |
| XcodeGen | 2.40+ |
| Swift | 6.0 |

---

## Getting Started

### 1. Install XcodeGen

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

```bash
cd ios
xcodegen generate
```

This reads `project.yml` and produces `MuscleWikiApp.xcodeproj`.

### 3. Open in Xcode

```bash
open MuscleWikiApp.xcodeproj
```

Select a simulator or connected device (iOS 17+) and press **Run** (`Cmd+R`).

---

## Project Structure

```
ios/
├── project.yml                        # XcodeGen spec (Swift 6, iOS 17+)
├── MuscleWikiApp/
│   ├── App/
│   │   ├── MuscleWikiApp.swift        # @main entry — injects store + SwiftData container
│   │   └── Info.plist
│   ├── Models/
│   │   ├── Exercise.swift             # Codable exercise + MuscleTarget structs
│   │   └── FavoriteExercise.swift     # @Model for SwiftData persistence
│   ├── Services/
│   │   ├── DataService.swift          # actor — async JSON loading from bundle
│   │   ├── NetworkMonitor.swift       # @Observable NWPathMonitor wrapper
│   │   └── SpotlightService.swift     # actor — CoreSpotlight indexing
│   ├── Store/
│   │   └── ExerciseStore.swift        # @Observable store — filter state + search
│   ├── Views/
│   │   ├── ContentView.swift          # TabView root + offline banner
│   │   ├── ExerciseListView.swift     # Browse tab — searchable list + filter button
│   │   ├── FilterView.swift           # Bottom sheet — multi-select filters
│   │   ├── ExerciseDetailView.swift   # Detail — video, steps, muscles, favorite
│   │   ├── BrowseView.swift           # Browse-by-muscle tab
│   │   ├── MuscleMapView.swift        # Tappable muscle group grid
│   │   ├── FavoritesView.swift        # Saved exercises tab
│   │   ├── VideoPlayerView.swift      # AVPlayer — front/side demo videos
│   │   └── YouTubePlayerView.swift    # WKWebView — full tutorial embed
│   ├── Components/
│   │   ├── ExerciseRowView.swift      # List row — name, category bar, badges
│   │   ├── BadgeView.swift            # Capsule badge (category, difficulty, force)
│   │   └── MuscleChipView.swift       # Muscle tier chips + MuscleGroupSection
│   ├── Extensions/
│   │   └── Color+App.swift            # Semantic difficulty/category colors
│   └── Resources/
│       ├── workout-data.json          # Bundled dataset — 954 exercises
│       ├── workout-attributes.json    # Bundled filter options
│       ├── PrivacyInfo.xcprivacy      # App Store privacy manifest
│       └── Assets.xcassets/           # App icon, accent color
├── MuscleWikiAppTests/                # Unit tests (Swift Testing framework)
│   ├── ExerciseModelTests.swift
│   ├── DataServiceTests.swift
│   └── ExerciseStoreTests.swift
└── MuscleWikiAppUITests/              # UI tests (XCUITest)
    └── MuscleWikiAppUITests.swift
```

---

## Architecture

### Data Flow

```
App launch
    │
    ▼
DataService (actor)
    │  async load from bundle (workout-data.json)
    ▼
ExerciseStore (@Observable, @MainActor)
    │  holds [Exercise], filter state, search text
    ▼
SwiftUI views
    │  read store via @Environment(ExerciseStore.self)
    ▼
SpotlightService (actor, background)
    │  indexes 954 exercises into CoreSpotlight
    ▼
FavoriteExercise (@Model)
    │  SwiftData container persists favorites on-device
```

### Key Patterns

| Pattern | Where used |
|---|---|
| `@Observable` (Observation framework) | `ExerciseStore`, `NetworkMonitor` |
| `actor` isolation | `DataService`, `SpotlightService` |
| `async/await` structured concurrency | All data loading |
| `SwiftData` (`@Model`, `@Query`) | `FavoriteExercise`, `FavoritesView` |
| `NavigationStack` + `navigationDestination` | All tabs |
| `.searchable` + `.presentationDetents` | List search, filter sheet |
| `NWPathMonitor` | `NetworkMonitor` — live connectivity |
| `AVPlayer` | Demo video (looping, muted, front/side) |
| `WKWebView` (`UIViewRepresentable`) | YouTube tutorial embed |
| `CSSearchableIndex` | Home screen Spotlight search |

---

## Features

### Exercises Tab
- `.searchable` bar searches all 954 exercises by name
- Filter button opens a bottom sheet (`.presentationDetents`) with multi-select toggles for **Category**, **Difficulty**, **Force**, and **Muscle Group**
- Active filter count badge on the filter button
- Clear-filters banner when filters are active
- `ContentUnavailableView` empty state for no results

### Browse Tab
- `LazyVGrid` of 15 tappable muscle group tiles
- Each tile shows live exercise count
- Tapping a tile sets the muscle filter and jumps to the Exercises tab

### Exercise Detail
- Looping `AVPlayer` demo video with front/side angle toggle
- Numbered step-by-step instructions
- Muscle targets grouped by tier (Primary / Secondary / Tertiary) with color-coded chips
- Category, difficulty, force, and grip capsule badges
- Collapsible YouTube tutorial section (disabled offline)
- Heart button to save/unsave to Favorites (persisted via SwiftData)

### Favorites Tab
- Reverse-chronological list of saved exercises (SwiftData `@Query`)
- Swipe-to-delete + `EditButton` for bulk management

### Offline Support
- All exercise data (JSON) is bundled — **zero network needed** to browse
- `NWPathMonitor` detects connectivity changes in real time
- Animated banner slides in from the top when offline
- Demo video shows a `wifi.slash` placeholder and auto-resumes on reconnect
- YouTube section is disabled and labelled "Offline" when disconnected

### Home Screen Search
- All 954 exercises are indexed into CoreSpotlight on first launch
- Tapping a Spotlight result deep-links directly to the exercise detail view

---

## Running Tests

### Unit Tests

```bash
# In Xcode: Cmd+U
# Or via xcodebuild:
xcodebuild test \
  -scheme MuscleWikiApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -testPlan MuscleWikiAppTests
```

Test suites (Swift Testing `@Suite`):
- `ExerciseModelTests` — JSON decoding, optional fields, `allMuscles`, `difficultyColorName`
- `DataServiceTests` — bundle loading, field completeness, unique IDs
- `ExerciseStoreTests` — filter logic (search, category, difficulty, force, muscle, AND-combining, clear)

### UI Tests

```bash
xcodebuild test \
  -scheme MuscleWikiApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -testPlan MuscleWikiAppUITests
```

Covered flows: list loads, search, tap-to-detail, filter apply/reset, favorite save/remove, Browse tab muscle tap, VoiceOver label presence.

---

## Updating the Exercise Dataset

When the backend scraper produces new data:

```bash
# From repo root
cp backend/data/workout-data.json       ios/MuscleWikiApp/Resources/workout-data.json
cp backend/data/workout-attributes.json ios/MuscleWikiApp/Resources/workout-attributes.json
```

Then rebuild the app — `DataService` loads these files from the bundle at launch.

---

## App Store Submission Notes

- `PrivacyInfo.xcprivacy` declares no tracking and no collected data types
- No `NSCameraUsageDescription`, `NSLocationUsageDescription`, or other sensitive entitlements required
- Required capability: `arm64` only
- Supported orientations: portrait + landscape (all rotations on iPad)
