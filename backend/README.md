# MuscleWiki — Backend

A Python/Flask REST API serving exercise data scraped from [musclewiki.com](https://musclewiki.com/). Deployed as a serverless function on Vercel.

**Live API:** `https://workoutapi.vercel.app`

---

## Directory Structure

```
backend/
├── api.py              # Flask REST API (served by Vercel)
├── muscleWiki.py       # Web scraper — run to refresh data
├── utils.py            # Converts workout-data.json → workout-data.csv
├── requirements.txt    # All Python dependencies
└── data/
    ├── workout-data.json          # 954 exercises (primary dataset)
    ├── workout-attributes.json    # Filter option index
    └── workout-data.csv           # CSV export of workout-data.json
```

---

## Local Development

```bash
# 1. Create and activate a virtual environment
python3 -m venv venv
source venv/bin/activate       # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the API server (from repo root)
python backend/api.py
# → http://localhost:5000
```

---

## API Reference

### `GET /`

Health check.

```json
{ "message": "Muscle Wiki API" }
```

---

### `GET /exercises`

Returns all exercises. Supports optional query parameters to filter results.

**Query parameters** (all optional, combinable):

| Parameter | Type | Description | Example |
|---|---|---|---|
| `name` | string | Case-insensitive substring match on exercise name | `?name=curl` |
| `muscle` | string | Matches any muscle tier (Primary/Secondary/Tertiary) | `?muscle=Biceps` |
| `category` | string | Exact match (case-insensitive) | `?category=Barbell` |
| `difficulty` | string | Exact match (case-insensitive) | `?difficulty=Beginner` |
| `force` | string | Exact match (case-insensitive) | `?force=Pull` |

**Example request:**

```
GET /exercises?muscle=Chest&difficulty=Beginner&category=Bodyweight
```

**Example response:**

```json
[
  {
    "id": 42,
    "exercise_name": "Push Up",
    "Category": "Bodyweight",
    "Difficulty": "Beginner",
    "Force": "Push",
    "Grips": "Neutral",
    "target": {
      "Primary": ["Chest"],
      "Secondary": ["Triceps", "Shoulders"]
    },
    "steps": ["Step 1...", "Step 2..."],
    "videoURL": [
      "https://media.musclewiki.com/.../front.mp4#t=0.1",
      "https://media.musclewiki.com/.../side.mp4#t=0.1"
    ],
    "youtubeURL": "https://www.youtube.com/embed/...",
    "details": "Detailed coaching notes..."
  }
]
```

---

### `GET /exercises/<id>`

Returns a single exercise by its numeric ID.

```
GET /exercises/42
```

Returns `404` with `{ "error": "Exercise not found" }` if not found.

---

### `GET /exercises/attributes`

Returns the complete list of available filter values.

```json
{
  "categories": ["Barbell", "Dumbbells", "Kettlebells", "Cables", "Band",
                 "Machine", "Plate", "TRX", "Bodyweight", "Yoga", "Stretches"],
  "difficulties": ["Beginner", "Intermediate", "Advanced"],
  "forces": ["Pull", "Push", "Hold"],
  "muscles": ["Biceps", "Forearms", "Shoulders", "Triceps", "Quads",
              "Glutes", "Lats", "Mid back", "Lower back", "Hamstrings",
              "Chest", "Abdominals", "Obliques", "Traps", "Calves"]
}
```

---

## Exercise Data Model

```json
{
  "id":            0,
  "exercise_name": "Barbell Curl",
  "Category":      "Barbell",
  "Difficulty":    "Beginner",
  "Force":         "Pull",
  "Grips":         "Underhand",
  "target": {
    "Primary":   ["Biceps"],
    "Secondary": ["Forearms"],
    "Tertiary":  []
  },
  "steps":      ["Step 1...", "Step 2..."],
  "videoURL":   ["https://...front.mp4#t=0.1", "https://...side.mp4#t=0.1"],
  "youtubeURL": "https://www.youtube.com/embed/<id>",
  "details":    "Coach notes and tips...",
  "Aka":        "Bicep Curl"
}
```

---

## Refreshing Data with the Scraper

The scraper crawls [musclewiki.com/directory](https://musclewiki.com/directory) and regenerates the data files. Run it only when you need to update the dataset (e.g., new exercises added to the source site).

```bash
# From repo root, with venv activated
python backend/muscleWiki.py
```

Outputs written to `backend/data/`:
- `workout-data.json` — full exercise dataset
- `workout-attributes.json` — filter option index

After scraping, copy the updated JSON files into the iOS app bundle:

```bash
cp backend/data/workout-data.json       ios/MuscleWikiApp/Resources/workout-data.json
cp backend/data/workout-attributes.json ios/MuscleWikiApp/Resources/workout-attributes.json
```

To also regenerate the CSV export:

```bash
python backend/utils.py
# → backend/data/workout-data.csv
```

**Note:** Scraping 954 exercises takes several minutes due to per-page HTTP requests.

---

## Deployment to Vercel

The API is configured to deploy via the root-level `vercel.json`.

```bash
# Install Vercel CLI
npm install -g vercel

# Authenticate
vercel login

# Deploy (preview)
vercel

# Deploy to production
vercel --prod
```

The `@vercel/python` builder packages `backend/api.py` and its `data/` directory as a serverless function. No environment variables are required.
