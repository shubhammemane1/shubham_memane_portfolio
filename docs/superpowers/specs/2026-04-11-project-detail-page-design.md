# Project Detail Page — Play Store Style

**Date:** 2026-04-11  
**Status:** Approved

---

## Overview

When a user clicks a project card on the portfolio home page, they navigate to a full-screen Play Store-style project detail page. Navigation uses `go_router` with slug-based URLs (e.g. `/project/e-commerce-app`) so links are shareable and work on direct access/refresh. A Hero animation flies the app icon from the card to the detail page header.

---

## Data & Model Changes

### `Project` model (portfolio_data.dart)
Add two new fields:
- `slug` — `String` — URL-safe identifier, e.g. `"e-commerce-app"`. Required.
- `screenshots` — `List<String>` — list of image URLs for the carousel. Defaults to empty list.
- `longDescription` — `String?` — detailed description. Falls back to `description` if null.

### `portfolio.json`
Each project entry gets:
- `"slug"`: a URL-safe string (kebab-case of the title)
- `"screenshots"`: array of 4× the placeholder URL `https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw`
- `"longDescription"`: optional extended description string

### Fake stats (hardcoded in UI, not in JSON)
Displayed as chips in the action bar. Values are decorative:
- Rating: `"4.5 ★"`
- Downloads: `"10K+"`
- Category: per-project string (e.g. "Finance", "Productivity")

---

## Navigation & Routing

### Package
Add `go_router` to `pubspec.yaml`.

### Routes
| Path | Page |
|------|------|
| `/` | `HomePage` (existing, unchanged) |
| `/project/:slug` | `ProjectDetailPage` (new) |

### Router setup
- `MyApp` switches from `MaterialApp(home:)` to `MaterialApp.router(routerConfig:)`.
- Router is initialized with the loaded `PortfolioData` so the `/project/:slug` route can look up a project by slug at build time.
- If slug not found, redirect to `/`.

### Card tap
`_ProjectCard` becomes tappable (wrap with `GestureDetector` or `InkWell`). On tap: `context.go('/project/${project.slug}')`.

### Hero tag
The app icon image (or icon widget) on the card is wrapped in `Hero(tag: 'project-icon-${project.slug}', ...)`. The same `Hero` wraps the icon in the detail page header.

---

## Project Detail Page Layout

File: `lib/presentation/pages/project_detail_page.dart`

### Structure (top to bottom, inside `SingleChildScrollView`):

#### 1. Header zone (~280px tall, full width)
- Background: `LinearGradient` using extracted palette colors (same logic as card — `PaletteGenerator`)
- Top-left: `BackButton` / arrow icon → `context.go('/')` 
- Center: Hero-animated app icon (110×110, rounded corners)
- Below icon: project `title` (bold, large)
- Below title: one-line `description` (muted color, small)

#### 2. Action bar
- Horizontal `Wrap` of buttons, centered
- Buttons shown only if URL is non-null: GitHub, Live Demo, Play Store, App Store
- Two read-only stat chips: Rating (`"4.5 ★"`), Downloads (`"10K+"`)
- Same `_IconButton` style as existing card (reuse the widget)

#### 3. Screenshots carousel
- Section heading: `"Screenshots"`
- Horizontal `ListView` (scroll direction: horizontal, height ~220px)
- Each screenshot: `ClipRRect` rounded image, ~130px wide, with a small shadow

#### 4. About section
- Section heading: `"About this project"`
- Body text: `longDescription ?? description`

#### 5. Technologies section
- Section heading: `"Technologies"`
- Same chip `Wrap` as existing card

#### 6. Footer
- Centered `TextButton`: `"← Back to Portfolio"` → `context.go('/')`

### Theming
- Uses `AppColors`, `AppSpacing`, `AppRadius` throughout — matches existing dark/light theme.
- Background: `Theme.of(context).scaffoldBackgroundColor`
- No `NavBar` on this page (back button replaces it)

---

## File Changes Summary

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `go_router` dependency |
| `assets/data/portfolio.json` | Add `slug`, `screenshots`, `longDescription` to each project |
| `lib/domain/models/portfolio_data.dart` | Add `slug`, `screenshots`, `longDescription` fields to `Project` |
| `lib/main.dart` | Replace `MaterialApp(home:)` with `MaterialApp.router(routerConfig:)`, build router |
| `lib/presentation/widgets/projects_section.dart` | Make `_ProjectCard` tappable, add Hero to icon |
| `lib/presentation/pages/project_detail_page.dart` | New file — full Play Store-style detail page |

---

## Error Handling
- Invalid slug in URL → redirect to `/`
- Missing image → existing gradient fallback (same as card)
- Empty screenshots list → screenshots section hidden
