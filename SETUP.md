# Local Environment Setup — macOS

This guide walks you through setting up the full MuscleWiki project on a Mac, covering both the iOS app and the Python backend.

---

## Prerequisites

| Tool | Minimum version | Install |
|---|---|---|
| macOS | Sonoma 14.0+ | System update |
| Xcode | 16.0+ | Mac App Store |
| Command Line Tools | Xcode 16+ | `xcode-select --install` |
| Homebrew | latest | [brew.sh](https://brew.sh) |
| Python | 3.11+ | `brew install python` |
| XcodeGen | 2.40+ | `brew install xcodegen` |
| Git | 2.39+ | bundled with CLT |

---

## 1. Install Core Tooling

### Xcode

Install Xcode from the **Mac App Store** (not the command-line tools alone — the full IDE is required to build the iOS app).

After installing, open Xcode once to accept the license agreement, then install the command-line tools:

```bash
xcode-select --install
```

Verify:

```bash
xcodebuild -version
# Xcode 16.x
# Build version 16xxx
```

### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the printed instructions to add Homebrew to your `PATH` (Apple Silicon Macs require an extra step).

Verify:

```bash
brew --version
```

### Python 3.11+

```bash
brew install python
```

Verify:

```bash
python3 --version
# Python 3.11.x or higher
```

### XcodeGen

```bash
brew install xcodegen
```

Verify:

```bash
xcodegen --version
# XcodeGen 2.40.x
```

---

## 2. Clone the Repository

```bash
git clone https://github.com/ysaipranav/MuscleWiki.git
cd MuscleWiki
```

---

## 3. iOS App Setup

### Generate the Xcode project

XcodeGen reads `ios/project.yml` and creates the `.xcodeproj` file. Run this once, and again any time `project.yml` changes.

```bash
cd ios
xcodegen generate
```

Expected output:

```
⚙️  Generating project MuscleWikiApp
✅  Created project at MuscleWikiApp.xcodeproj
```

### Open in Xcode

```bash
open MuscleWikiApp.xcodeproj
```

### Select a simulator or device

In the Xcode toolbar, click the device picker and choose any **iPhone** or **iPad** running **iOS 17.0+**. Recommended: **iPhone 16** simulator.

### Run the app

Press **Cmd+R** or click the **▶ Run** button.

The app loads all exercise data from the bundled JSON — no internet required.

### Run tests

| Test suite | Shortcut |
|---|---|
| Unit tests (`ExerciseModelTests`, `DataServiceTests`, `ExerciseStoreTests`) | **Cmd+U** |
| UI tests (`MuscleWikiAppUITests`) | Product → Test |

Or from the terminal:

```bash
# Unit tests
xcodebuild test \
  -scheme MuscleWikiApp \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:MuscleWikiAppTests

# UI tests
xcodebuild test \
  -scheme MuscleWikiApp \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:MuscleWikiAppUITests
```

---

## 4. Backend Setup

### Create a virtual environment

```bash
cd backend          # from repo root
python3 -m venv venv
source venv/bin/activate
```

Your prompt will show `(venv)` when the environment is active. To deactivate later: `deactivate`.

### Install dependencies

```bash
pip install -r requirements.txt
```

This installs Flask (API), requests + beautifulsoup4 (scraper), and pandas (CSV export).

### Run the API server locally

```bash
# From repo root, with venv active
python backend/api.py
```

The server starts at **http://localhost:5000**. Test it:

```bash
curl http://localhost:5000/exercises/attributes
curl "http://localhost:5000/exercises?muscle=Biceps&difficulty=Beginner"
curl http://localhost:5000/exercises/0
```

### (Optional) Re-run the scraper

Only needed if you want to refresh the exercise dataset from musclewiki.com. The bundled `backend/data/workout-data.json` already contains 954 exercises.

```bash
# From repo root, with venv active
python backend/muscleWiki.py
```

This crawls every exercise page (takes several minutes) and overwrites:
- `backend/data/workout-data.json`
- `backend/data/workout-attributes.json`

After scraping, copy the updated files into the iOS app bundle:

```bash
cp backend/data/workout-data.json       ios/MuscleWikiApp/Resources/workout-data.json
cp backend/data/workout-attributes.json ios/MuscleWikiApp/Resources/workout-attributes.json
```

### (Optional) Regenerate the CSV export

```bash
python backend/utils.py
# → backend/data/workout-data.csv
```

---

## 5. Project Structure Reference

```
MuscleWiki/
├── backend/
│   ├── api.py                  # Flask REST API
│   ├── muscleWiki.py           # Web scraper
│   ├── utils.py                # JSON → CSV
│   ├── requirements.txt        # Python deps
│   └── data/
│       ├── workout-data.json          # 954 exercises
│       ├── workout-attributes.json    # Filter options
│       └── workout-data.csv           # CSV export
├── ios/
│   ├── project.yml             # XcodeGen spec
│   ├── MuscleWikiApp/          # Swift source + resources
│   ├── MuscleWikiAppTests/     # Unit tests
│   └── MuscleWikiAppUITests/   # UI tests
├── vercel.json                 # Vercel deployment config
├── README.md                   # Project overview
├── SETUP.md                    # This file
└── .gitignore
```

---

## 6. Common Issues

### `xcodegen: command not found`

Homebrew may not be on your `PATH`. Add the following to `~/.zshrc` (Apple Silicon):

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then reload: `source ~/.zshrc`

### Simulator not listed in Xcode

Open **Xcode → Settings → Platforms** and download the latest iOS simulator runtime.

### `ModuleNotFoundError` when running Python scripts

Ensure your virtual environment is active (`source backend/venv/bin/activate`) before running any backend scripts.

### Port 5000 already in use

macOS AirPlay Receiver can occupy port 5000. Disable it in **System Settings → General → AirDrop & Handoff**, or run Flask on a different port:

```bash
FLASK_RUN_PORT=5001 python backend/api.py
```

### `xcodebuild` fails with "No signing certificate"

For local simulator builds, signing is not required. In Xcode, set:
**Signing & Capabilities → Team → None**, and **Automatically manage signing → off**.

---

## 7. Useful Commands Cheatsheet

```bash
# iOS
cd ios && xcodegen generate      # Regenerate .xcodeproj after project.yml changes
open ios/MuscleWikiApp.xcodeproj # Open in Xcode

# Backend
source backend/venv/bin/activate # Activate Python env
python backend/api.py            # Run API (http://localhost:5000)
python backend/muscleWiki.py     # Re-scrape all exercises
python backend/utils.py          # Export JSON → CSV
deactivate                       # Exit Python env

# Data sync (after scraping)
cp backend/data/workout-data.json       ios/MuscleWikiApp/Resources/workout-data.json
cp backend/data/workout-attributes.json ios/MuscleWikiApp/Resources/workout-attributes.json
```
