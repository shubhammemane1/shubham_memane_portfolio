# Media Viewer & JSON Population Design

**Date:** 2026-04-12

## Overview

Two related features:
1. **JSON population** — given a Play Store or App Store URL, fetch app metadata and populate `portfolio.json`
2. **Media viewer** — support videos (YouTube + MP4) alongside screenshots in the project detail page, with a tap-to-open popup/lightbox

---

## 1. JSON Schema Changes

### `Project` model — new fields

```json
{
  "videos": ["https://youtube.com/watch?v=...", "https://cdn.example.com/preview.mp4"],
  "rating": 4.7,
  "downloads": "500K+"
}
```

- `screenshots: List<String>` — unchanged, image URLs only
- `videos: List<String>` — new, YouTube or direct MP4 URLs
- `rating: double?` — new, from Play Store
- `downloads: String?` — new, e.g. `"500K+"`

### `portfolio_data.dart` changes

Add `videos`, `rating`, `downloads` to `Project` class and `Project.fromJson`.

---

## 2. Play Store / App Store Data Population

Since Play Store pages are JS-rendered and can't be reliably fetched via HTTP, data is populated **manually by Claude** when given a URL:

- User provides a Play Store or App Store URL
- Claude fetches the page (best-effort), extracts: title, description, icon URL, screenshots, video URL, rating, downloads, store URLs
- Claude updates `portfolio.json` directly with the extracted data

If fetch fails (JS-rendered), Claude populates what it can from the URL ID and asks the user to fill in missing fields.

---

## 3. Project Detail Page — Media Section

### Layout

Replace `_ScreenshotsSection` with `_MediaSection`:

- Section title: **"Screenshots & Videos"** (or just "Screenshots" if no videos)
- Horizontal scrolling list showing:
  - **Image thumbnails** — tap opens image popup
  - **Video thumbnails** — shows screenshot/poster image with green play button overlay + "VIDEO" badge; tap opens video popup

### Popup / Lightbox — `_MediaDialog`

A full-screen `Dialog` with dark scrim background:

**Image popup:**
- Full-size `Image.network` with `BoxFit.contain`
- Close button (✕) top-right
- Counter label: "Screenshot 2 / 5"

**Video popup:**
- YouTube URL → embedded via `HtmlElementView` with `<iframe>` (web-only, no extra package)
- MP4 URL → `HtmlElementView` with `<video controls autoplay>` element
- Close button (✕) top-right

URL detection logic:
```dart
bool isYouTube(String url) =>
    url.contains('youtube.com') || url.contains('youtu.be');
```

### Video thumbnail poster

- If YouTube: extract thumbnail from `https://img.youtube.com/vi/{videoId}/hqdefault.jpg`
- If MP4: show a generic video placeholder (dark box with play icon, no poster)

---

## 4. Component Structure

```
_MediaSection          — replaces _ScreenshotsSection
  └── _MediaThumb      — single thumbnail (image or video)
_MediaDialog           — popup overlay
  ├── _ImageViewer     — image display with counter
  └── _VideoViewer     — HtmlElementView with iframe or video tag
```

---

## 5. Error Handling

- Image load failure → show `Icons.image_not_supported` placeholder (existing behavior)
- Video load failure → show error icon with "Video unavailable" label
- YouTube ID extraction failure → fall back to `url_launcher` (open in browser)

---

## 6. Out of Scope

- Swipe gestures between media items in popup
- Download button for images
- App Store scraping (manual entry only)
- Native mobile video player (Flutter web only)
