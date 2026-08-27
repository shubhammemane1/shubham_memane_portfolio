# Firebase Portfolio Backend Design

**Date:** 2026-08-27

## Overview

Move portfolio content and images off local bundled assets and an external
CDN hotlink (`play-lh.googleusercontent.com`, which rate-limits with HTTP
429) onto a Firebase project (`shubhammemaneportfolio-e4dd0`, already
created). The app fetches its data from Cloud Firestore at startup instead
of reading `assets/data/portfolio.json`, and images are served from
Firebase Storage instead of the Play Store CDN.

Trigger: the project's icon (`play-lh.googleusercontent.com/...`) started
returning 429 during normal dev hot-reload, breaking image display with no
code-side fix — the CDN isn't a sanctioned public hotlinking source and
throttles per-IP.

---

## 1. Firestore Data Model

Two document/collection groups, chosen so project data (which the user may
want to edit or add to later, per-item) lives separately from small static
site-wide info:

```
portfolio/
  meta                      (single doc)
    - personalInfo: { name, title, bio, imageUrl }
    - skills: [ { name, category, proficiency }, ... ]
    - experiences: [ { company, position, duration, description }, ... ]
    - education: [ { institution, degree, duration }, ... ]
    - contactInfo: { email, phone, github, linkedin, twitter, website }

projects/
  {slug}                    (one doc per project, doc ID = slug)
    - title, description, longDescription
    - technologies: [String]
    - imageUrl, screenshots: [String], videos: [String]  (Firebase Storage URLs)
    - liveUrl, githubUrl, playStoreUrl, appStoreUrl
    - icon (string key, same as today, e.g. "cartShopping")
    - rating, downloads
```

`projects` is a collection (not an array field) specifically so each
project can be added/edited independently from the Firebase console
without touching a single large blob.

## 2. Firebase Storage Layout

```
projects/{slug}/icon.webp
projects/{slug}/screenshot-1.webp
projects/{slug}/screenshot-2.webp
...
```

Existing downloaded icons (`assets/images/*.webp`, from the earlier fix)
are reused for the 4 Play Store icons; the rest are fetched fresh from
their current CDN URLs during migration.

## 3. Security Rules

Read-only from the client; all writes happen through the one-time
migration script (Admin SDK, bypasses rules) or manually via console.

**Firestore rules:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

**Storage rules:**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## 4. Migration Script

One-time Node.js script, `tool/migrate-to-firebase.js`, run manually via
`node tool/migrate-to-firebase.js`. Not part of the Flutter app — uses the
`firebase-admin` npm package (bypasses security rules via a service
account key), which Flutter's `cloud_firestore`/`firebase_storage` client
plugins can't do standalone outside a running Flutter engine.

Steps the script performs:
1. Read `assets/data/portfolio.json`.
2. For each project, download every image (icon + screenshots; reuse local
   `assets/images/*.webp` where already present), upload to Storage under
   `projects/{slug}/`, collect the resulting public download URLs.
3. Write `portfolio/meta` doc (personalInfo, skills, experiences,
   education, contactInfo) as-is.
4. Write one `projects/{slug}` doc per project, with `imageUrl`/
   `screenshots`/`videos` replaced by their new Storage URLs.

Auth: a service account JSON key downloaded from Firebase console
(Project Settings → Service Accounts), saved locally as
`tool/service-account.json` and added to `.gitignore` — never committed.

`assets/data/portfolio.json` remains in the repo as the seed source (and
fallback reference) but is no longer read by the running app.

## 5. Flutter App Changes

**New dependencies** (`pubspec.yaml`): `firebase_core`, `cloud_firestore`.
`firebase_storage` is **not** needed as a Flutter dependency — the app
only ever reads plain Storage download URLs already resolved into
Firestore doc fields, it never talks to the Storage API directly. The
migration script uploads to Storage via the Node `firebase-admin` SDK
instead (section 4), unrelated to `pubspec.yaml`.

**Setup:** `flutterfire configure` (interactive, run by the user) against
`shubhammemaneportfolio-e4dd0`, generating `lib/firebase_options.dart`.
`Firebase.initializeApp()` added to `main()` before `runApp`.

**`PortfolioService.load()`** (`lib/core/services/portfolio_service.dart`):
replace the `rootBundle.loadString` + `jsonDecode` body with:
- fetch `projects` collection (`FirebaseFirestore.instance.collection('projects').get()`)
- fetch `portfolio/meta` doc
- reconstruct the same `PortfolioData`/`Project`/etc. model objects via
  existing `fromJson` factories (Firestore doc data is already a
  `Map<String, dynamic>`, so the factories are reused unchanged — only the
  source of the map changes, not its shape)

Downstream widgets are untouched — the model layer's public shape doesn't
change.

## 6. Error Handling

No fallback exists today (`rootBundle.loadString` failing means the app
never launches). Same posture, adapted to network reality: on
`PortfolioService.load()` failure (offline, Firestore misconfigured), the
loading screen shows an error state with a retry button, rather than a
raw crash — Firestore reads are meaningfully more likely to fail
transiently (network) than a bundled asset ever was.

## 7. Testing

No existing tests cover `PortfolioService`/`PortfolioData`. Add
`test/core/services/portfolio_service_test.dart` using
`fake_cloud_firestore` (test-only package) to seed a fake Firestore
instance matching the doc shape above, and assert `PortfolioService.load()`
maps it into the correct `PortfolioData` object — covering the
fetch-and-reconstruct logic that's new in this change.

## 8. Rollout

1. Enable Firestore + Storage APIs on `shubhammemaneportfolio-e4dd0`
   (console or `firebase` CLI), in production mode (locked rules from the
   start, per section 3).
2. Run `flutterfire configure`.
3. Run the migration script once.
4. Ship the `PortfolioService` change.
5. Verify all 5 projects render correctly against live Firestore data
   before removing reliance on `assets/data/portfolio.json` conceptually
   (file itself stays in repo as seed record).
