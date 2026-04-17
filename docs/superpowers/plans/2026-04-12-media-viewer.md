# Media Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add video support (YouTube + MP4) to the project detail page with a tap-to-open popup viewer, and extend the Project model with `videos`, `rating`, and `downloads` fields.

**Architecture:** Separate `screenshots` (images) and `videos` (URLs) lists in JSON/model. A new `_MediaSection` widget renders both as thumbnails in a horizontal strip. Tapping opens `_MediaDialog` — an image viewer or a platform-native video player via `HtmlElementView` (Flutter web only, no extra packages).

**Tech Stack:** Flutter web, `dart:html` (deprecated but functional in Dart 3.x), `dart:ui_web`, existing packages only.

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `lib/domain/models/portfolio_data.dart` | Modify | Add `videos`, `rating`, `downloads` to `Project` |
| `assets/data/portfolio.json` | Modify | Add `videos`, `rating`, `downloads` to each project |
| `lib/presentation/widgets/media_section.dart` | Create | `_MediaThumb`, `_MediaSection` |
| `lib/presentation/widgets/media_dialog.dart` | Create | `_MediaDialog`, `_ImageViewer`, `_VideoViewer` |
| `lib/presentation/pages/project_detail_page.dart` | Modify | Replace `_ScreenshotsSection` with `_MediaSection`; use real rating/downloads |
| `test/presentation/widgets/media_section_test.dart` | Create | Widget tests for media section |

---

### Task 1: Extend Project model

**Files:**
- Modify: `lib/domain/models/portfolio_data.dart`

- [ ] **Step 1: Add fields to `Project` class**

Replace the `Project` class fields and constructor in `portfolio_data.dart`:

```dart
class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final String? imageUrl;
  final String? liveUrl;
  final String? githubUrl;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final IconData? icon;
  final String slug;
  final List<String> screenshots;
  final List<String> videos;       // NEW
  final String? longDescription;
  final double? rating;            // NEW
  final String? downloads;         // NEW

  Project({
    required this.title,
    required this.description,
    required this.technologies,
    this.imageUrl,
    this.liveUrl,
    this.githubUrl,
    this.playStoreUrl,
    this.appStoreUrl,
    this.icon,
    required this.slug,
    this.screenshots = const [],
    this.videos = const [],
    this.longDescription,
    this.rating,
    this.downloads,
  });
```

- [ ] **Step 2: Update `Project.fromJson`**

Replace the `fromJson` factory:

```dart
  factory Project.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    return Project(
      title: title,
      description: json['description'] as String,
      technologies: (json['technologies'] as List<dynamic>).cast<String>(),
      imageUrl: json['imageUrl'] as String?,
      liveUrl: json['liveUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      playStoreUrl: json['playStoreUrl'] as String?,
      appStoreUrl: json['appStoreUrl'] as String?,
      icon: _iconFromString(json['icon'] as String?),
      slug: json['slug'] as String? ?? _slugify(title),
      screenshots: (json['screenshots'] as List<dynamic>?)?.cast<String>() ?? const [],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? const [],
      longDescription: json['longDescription'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      downloads: json['downloads'] as String?,
    );
  }
```

- [ ] **Step 3: Verify hot reload compiles**

Run: `flutter analyze lib/domain/models/portfolio_data.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/domain/models/portfolio_data.dart
git commit -m "feat: add videos, rating, downloads to Project model"
```

---

### Task 2: Update portfolio.json

**Files:**
- Modify: `assets/data/portfolio.json`

- [ ] **Step 1: Add new fields to each project**

For each project entry, add these fields (use `null` / empty array if unknown):

```json
"videos": [],
"rating": 4.7,
"downloads": "500K+"
```

Full example for the Riise project:

```json
{
  "title": "Riise",
  "slug": "riise",
  "description": "Know your portfolio with True Wealth. Invest via Demat Account with real-time market insights.",
  "longDescription": "Riise by Motilal Oswal lets you track and grow your wealth with a True Wealth view of your entire portfolio. Invest in stocks, mutual funds, and IPOs through a seamlessly integrated Demat account. Features real-time market data, portfolio analytics, secure biometric login, and actionable investment insights to help you make smarter financial decisions.",
  "technologies": ["Flutter", "Firebase", "Dart", "REST APIs"],
  "imageUrl": "https://play-lh.googleusercontent.com/mYmcPxQifEvJcqxLoGLGvIOLk9OmuFmKNEvK3ruWdr6d8smfExlZ0VcDghdPzTAV6DjyYU5H935WF7hRdXfr_u4=s512-rw",
  "githubUrl": null,
  "liveUrl": null,
  "playStoreUrl": "https://play.google.com/store/apps/details?id=com.mosl.mobile",
  "appStoreUrl": null,
  "screenshots": [
    "https://play-lh.googleusercontent.com/vmt5K2rdLCCCZMW8uPijoLF4UrLOWeoxQtw4Xy1eRoLx-IV2w1B8QOhFCso-l6KSFYGZ1l0AqLrhw6YkCb7P",
    "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA",
    "https://play-lh.googleusercontent.com/FJOIblR_cxssqjfygtATX9Jge2o9DdYVwwN7X_lurDkTH4u2XgGRk0Q2iWBtjxFVfzOiFivljAcKXzf2PoGbOw",
    "https://play-lh.googleusercontent.com/R_u5EAVngarrjJxh6SmBZYHvN7pDd_bVg2EYXdt1P4_mIR8f6EUvetZSd4dExHJkHba_1nrzo1OrKKc1PTLaLQ",
    "https://play-lh.googleusercontent.com/Jkf_mxmQMxA-H0qFTJ2rnLr9Ycxn2tMpnoPGuIrOnbVm8Br-xFChsWr01I6Ui1DYX7f6QKAKx-u5b2bpHdAcew",
    "https://play-lh.googleusercontent.com/ZeJpJ6Tm3lkgstgbrv7Vh24i4WngU2Idti3yIYVB2pQaUOJTe59G3lomcfBqzUl3XkRz64CyWF_sjto0KSupEcU"
  ],
  "videos": [],
  "rating": 4.7,
  "downloads": "500K+"
}
```

Apply the same pattern (`"videos": [], "rating": null, "downloads": null`) to all other projects that don't have known values.

- [ ] **Step 2: Validate JSON**

Run: `python3 -c "import json; json.load(open('assets/data/portfolio.json')); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add assets/data/portfolio.json
git commit -m "feat: add videos, rating, downloads fields to portfolio.json"
```

---

### Task 3: Create media_section.dart

**Files:**
- Create: `lib/presentation/widgets/media_section.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/presentation/widgets/media_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/presentation/widgets/media_section.dart';

void main() {
  testWidgets('shows Screenshots title when no videos', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaSection(screenshots: ['https://example.com/a.jpg'], videos: []),
      ),
    ));
    expect(find.text('Screenshots'), findsOneWidget);
    expect(find.text('Screenshots & Videos'), findsNothing);
  });

  testWidgets('shows Screenshots & Videos title when videos present', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaSection(
          screenshots: ['https://example.com/a.jpg'],
          videos: ['https://youtube.com/watch?v=abc123'],
        ),
      ),
    ));
    expect(find.text('Screenshots & Videos'), findsOneWidget);
  });

  testWidgets('shows video badge on video thumbnails', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaSection(
          screenshots: [],
          videos: ['https://youtube.com/watch?v=abc123'],
        ),
      ),
    ));
    expect(find.text('VIDEO'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

Run: `flutter test test/presentation/widgets/media_section_test.dart`
Expected: FAIL — `MediaSection` not found.

- [ ] **Step 3: Create the widget file**

Create `lib/presentation/widgets/media_section.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'media_dialog.dart';

// MediaItem and showMediaDialog are defined in media_dialog.dart (one-way dependency)

class MediaSection extends StatelessWidget {
  final List<String> screenshots;
  final List<String> videos;

  const MediaSection({
    super.key,
    required this.screenshots,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final allMedia = [
      ...screenshots.map((url) => MediaItem(url: url, isVideo: false)),
      ...videos.map((url) => MediaItem(url: url, isVideo: true)),
    ];

    if (allMedia.isEmpty) return const SizedBox.shrink();

    final title = videos.isEmpty ? 'Screenshots' : 'Screenshots & Videos';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 450,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allMedia.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) => _MediaThumb(
                item: allMedia[index],
                onTap: () => showMediaDialog(
                  context: context,
                  items: allMedia,
                  initialIndex: index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _MediaThumb({required this.item, required this.onTap});

  String get _posterUrl {
    if (!item.isVideo) return item.url;
    final videoId = _extractYouTubeId(item.url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return '';
  }

  static String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
    return uri.queryParameters['v'];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 260,
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _posterUrl.isNotEmpty
                  ? Image.network(
                      _posterUrl,
                      width: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _placeholderBox(),
                    )
                  : _placeholderBox(),
              if (item.isVideo) ...[
                Container(color: Colors.black45),
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 30),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('VIDEO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
        width: 260,
        height: 450,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          item.isVideo ? Icons.play_circle_outline : Icons.image_not_supported,
          color: AppColors.primary,
          size: 48,
        ),
      );
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/presentation/widgets/media_section_test.dart`
Expected: all 3 PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/media_section.dart \
        test/presentation/widgets/media_section_test.dart
git commit -m "feat: add MediaSection widget with image and video thumbnails"
```

---

### Task 4: Create media_dialog.dart

**Files:**
- Create: `lib/presentation/widgets/media_dialog.dart`

- [ ] **Step 1: Write the failing test**

Add to `test/presentation/widgets/media_section_test.dart`:

```dart
testWidgets('tapping thumbnail opens dialog', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: MediaSection(
        screenshots: ['https://example.com/a.jpg'],
        videos: [],
      ),
    ),
  ));
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();
  expect(find.byType(Dialog), findsOneWidget);
});
```

Run: `flutter test test/presentation/widgets/media_section_test.dart`
Expected: FAIL — `MediaDialog` not found.

- [ ] **Step 2: Create media_dialog.dart**

Create `lib/presentation/widgets/media_dialog.dart`:

```dart
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../core/theme/app_theme.dart';

/// Shared data class used by both media_section.dart and media_dialog.dart.
/// Defined here so media_section.dart can import media_dialog.dart (one-way).
class MediaItem {
  final String url;
  final bool isVideo;
  const MediaItem({required this.url, required this.isVideo});
}

void showMediaDialog({
  required BuildContext context,
  required List<MediaItem> items,
  required int initialIndex,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => MediaDialog(items: items, initialIndex: initialIndex),
  );
}

final _registeredViewIds = <String>{};

void _registerVideoView(String viewId, String url) {
  if (_registeredViewIds.contains(viewId)) return;
  _registeredViewIds.add(viewId);
  ui_web.platformViewRegistry.registerViewFactory(viewId, (_) {
    if (_isYouTube(url)) {
      final videoId = _extractYouTubeId(url) ?? '';
      return html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1'
        ..style.cssText = 'width:100%;height:100%;border:none;'
        ..allowFullscreen = true;
    } else {
      return html.VideoElement()
        ..src = url
        ..controls = true
        ..autoplay = true
        ..style.cssText = 'width:100%;height:100%;background:#000;';
    }
  });
}

bool _isYouTube(String url) =>
    url.contains('youtube.com') || url.contains('youtu.be');

String? _extractYouTubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  return uri.queryParameters['v'];
}

class MediaDialog extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;

  const MediaDialog({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<MediaDialog> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  MediaItem get _current => widget.items[_index];

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  void _next() {
    if (_index < widget.items.length - 1) setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Content
          Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            decoration: BoxDecoration(
              color: const Color(0xFF0f172a),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      _current.isVideo
                          ? 'Video'
                          : 'Screenshot ${_index + 1} / ${widget.items.where((i) => !i.isVideo).length}',
                      style: const TextStyle(
                          color: Color(0xFF94a3b8), fontSize: 13),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e293b),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Color(0xFF94a3b8), size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Media content
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _current.isVideo
                        ? _VideoViewer(url: _current.url)
                        : _ImageViewer(url: _current.url),
                  ),
                ),
                // Navigation arrows
                if (widget.items.length > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _index > 0 ? _prev : null,
                        icon: const Icon(Icons.chevron_left),
                        color: AppColors.primary,
                        disabledColor: const Color(0xFF334155),
                      ),
                      Text(
                        '${_index + 1} / ${widget.items.length}',
                        style: const TextStyle(
                            color: Color(0xFF64748b), fontSize: 12),
                      ),
                      IconButton(
                        onPressed:
                            _index < widget.items.length - 1 ? _next : null,
                        icon: const Icon(Icons.chevron_right),
                        color: AppColors.primary,
                        disabledColor: const Color(0xFF334155),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String url;
  const _ImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.image_not_supported,
            color: AppColors.primary, size: 48),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;
  const _VideoViewer({required this.url});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-${widget.url.hashCode}';
    _registerVideoView(_viewId, widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/presentation/widgets/media_section_test.dart`
Expected: all 4 PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/media_dialog.dart
git commit -m "feat: add MediaDialog with image viewer and HtmlElementView video player"
```

---

### Task 5: Wire up in project_detail_page.dart

**Files:**
- Modify: `lib/presentation/pages/project_detail_page.dart`

- [ ] **Step 1: Replace `_ScreenshotsSection` with `MediaSection`**

In `project_detail_page.dart`:

1. Add import at top:
```dart
import '../widgets/media_section.dart';
```

2. In `ProjectDetailPage.build()`, replace:
```dart
if (widget.project.screenshots.isNotEmpty)
  _ScreenshotsSection(screenshots: widget.project.screenshots),
```
with:
```dart
if (widget.project.screenshots.isNotEmpty || widget.project.videos.isNotEmpty)
  MediaSection(
    screenshots: widget.project.screenshots,
    videos: widget.project.videos,
  ),
```

3. Delete the entire `_ScreenshotsSection` class (lines ~289–339).

- [ ] **Step 2: Use real rating/downloads from JSON**

In `_ProjectDetailPageState`, update `_stats` getter to prefer JSON values over fake stats:

```dart
(String, String, String) get _stats {
  final fake = _fakeStats[widget.project.slug] ?? ('Utility', '10K+', '4.5');
  final rating = widget.project.rating != null
      ? widget.project.rating!.toStringAsFixed(1)
      : fake.$3;
  final downloads = widget.project.downloads ?? fake.$2;
  return (fake.$1, downloads, rating);
}
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/presentation/pages/project_detail_page.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/pages/project_detail_page.dart
git commit -m "feat: replace ScreenshotsSection with MediaSection, use real rating/downloads"
```

---

### Task 6: Build and verify

- [ ] **Step 1: Run all tests**

Run: `flutter test`
Expected: all tests PASS.

- [ ] **Step 2: Build web release**

Run: `flutter build web --release`
Expected: `✓ Built build/web`

- [ ] **Step 3: Smoke test locally**

```bash
cd build/web && python3 -m http.server 8080
```
Open `http://localhost:8080`, navigate to any project, verify:
- Screenshots appear in horizontal strip
- Video thumbnails show play icon + VIDEO badge
- Tapping image opens image popup with close button and nav arrows
- Tapping video opens video popup and plays

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete media viewer with video support"
```
