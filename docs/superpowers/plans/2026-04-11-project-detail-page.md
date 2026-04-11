# Project Detail Page (Play Store Style) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Play Store-style project detail page that opens when a project card is clicked, using go_router at `/project/:slug` with a Hero animation.

**Architecture:** Add `go_router` for URL-based routing. `Project` model gains `slug`, `screenshots`, `longDescription`. A new `ProjectDetailPage` renders a Play Store layout (gradient header, action bar, screenshot carousel, about, tech stack, fake stats). Hero animation flies the project icon from card to detail header.

**Tech Stack:** Flutter 3.11+, go_router ^14.0.0, palette_generator (existing), font_awesome_flutter (existing)

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `pubspec.yaml` | Modify | Add go_router dependency |
| `assets/data/portfolio.json` | Modify | Add slug, screenshots, longDescription per project |
| `lib/domain/models/portfolio_data.dart` | Modify | Add slug, screenshots, longDescription to Project |
| `lib/presentation/widgets/project_icon_button.dart` | Create | Public shared icon-link button (extracted from projects_section) |
| `lib/core/router/app_router.dart` | Create | GoRouter with `/` and `/project/:slug` routes |
| `lib/main.dart` | Modify | Switch to MaterialApp.router |
| `lib/presentation/widgets/projects_section.dart` | Modify | Make card tappable + Hero on icon |
| `lib/presentation/pages/project_detail_page.dart` | Create | Full Play Store-style detail page |
| `test/project_model_test.dart` | Create | Unit tests for new Project fields |
| `test/project_detail_page_test.dart` | Create | Widget smoke tests |

---

### Task 1: Add go_router dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add go_router**

In `pubspec.yaml` under `dependencies:`, add after `palette_generator`:

```yaml
  go_router: ^14.0.0
```

- [ ] **Step 2: Install**

```bash
flutter pub get
```

Expected: output includes `+ go_router 14.x.x`

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add go_router dependency"
```

---

### Task 2: Extend Project model

**Files:**
- Modify: `lib/domain/models/portfolio_data.dart`
- Create: `test/project_model_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/project_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/domain/models/portfolio_data.dart';

void main() {
  test('Project.fromJson parses slug, screenshots, longDescription', () {
    final json = {
      'title': 'Test App',
      'description': 'Short desc',
      'technologies': ['Flutter'],
      'slug': 'test-app',
      'screenshots': ['https://example.com/s1.png', 'https://example.com/s2.png'],
      'longDescription': 'Long detailed description.',
    };
    final project = Project.fromJson(json);
    expect(project.slug, 'test-app');
    expect(project.screenshots, ['https://example.com/s1.png', 'https://example.com/s2.png']);
    expect(project.longDescription, 'Long detailed description.');
  });

  test('Project.fromJson defaults screenshots to empty list when absent', () {
    final json = {
      'title': 'Test App',
      'description': 'Short desc',
      'technologies': ['Flutter'],
      'slug': 'test-app',
    };
    final project = Project.fromJson(json);
    expect(project.screenshots, isEmpty);
    expect(project.longDescription, isNull);
  });

  test('Project.fromJson auto-slugifies title when slug absent', () {
    final json = {
      'title': 'My Cool App',
      'description': 'desc',
      'technologies': <String>[],
    };
    final project = Project.fromJson(json);
    expect(project.slug, 'my-cool-app');
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/project_model_test.dart
```

Expected: FAIL — `The getter 'slug' isn't defined for the class 'Project'`

- [ ] **Step 3: Replace the Project class**

In `lib/domain/models/portfolio_data.dart`, replace the entire `Project` class (lines 75–127) with:

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
  final String? longDescription;

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
    this.longDescription,
  });

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
      longDescription: json['longDescription'] as String?,
    );
  }

  static String _slugify(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static IconData? _iconFromString(String? name) {
    switch (name) {
      case 'cartShopping':  return FontAwesomeIcons.cartShopping;
      case 'listCheck':     return FontAwesomeIcons.listCheck;
      case 'cloudSunRain':  return FontAwesomeIcons.cloudSunRain;
      case 'mobileScreen':  return FontAwesomeIcons.mobileScreen;
      case 'globe':         return FontAwesomeIcons.globe;
      case 'database':      return FontAwesomeIcons.database;
      case 'robot':         return FontAwesomeIcons.robot;
      case 'chartLine':     return FontAwesomeIcons.chartLine;
      case 'lock':          return FontAwesomeIcons.lock;
      case 'gamepad':       return FontAwesomeIcons.gamepad;
      default:              return null;
    }
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
flutter test test/project_model_test.dart
```

Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/models/portfolio_data.dart test/project_model_test.dart
git commit -m "feat: add slug, screenshots, longDescription to Project model"
```

---

### Task 3: Update portfolio.json

**Files:**
- Modify: `assets/data/portfolio.json`

- [ ] **Step 1: Replace the projects array**

In `assets/data/portfolio.json`, replace the entire `"projects": [...]` array with:

```json
"projects": [
  {
    "title": "E-Commerce App",
    "slug": "e-commerce-app",
    "description": "Full-featured e-commerce mobile application with payment integration, real-time inventory, and admin dashboard.",
    "longDescription": "A comprehensive e-commerce solution built with Flutter and Firebase. Features include user authentication, product browsing with filters, cart management, Stripe payment integration, real-time inventory tracking, and a full admin dashboard for managing products, orders, and users. The app delivers a smooth shopping experience with offline support and push notifications for order updates.",
    "technologies": ["Flutter", "Firebase", "Stripe", "Provider"],
    "imageUrl": "https://play-lh.googleusercontent.com/mYmcPxQifEvJcqxLoGLGvIOLk9OmuFmKNEvK3ruWdr6d8smfExlZ0VcDghdPzTAV6DjyYU5H935WF7hRdXfr_u4=w480-h960-rw",
    "githubUrl": "https://github.com/yourusername/project1",
    "liveUrl": null,
    "playStoreUrl": "https://play.google.com/store/apps/details?id=com.mosl.mobile&pcampaignid=web_share",
    "appStoreUrl": "https://apps.apple.com/app/ecommerce/id000000001",
    "screenshots": [
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw"
    ]
  },
  {
    "title": "Task Management System",
    "slug": "task-management-system",
    "description": "Collaborative task management platform with real-time updates, team collaboration, and analytics.",
    "longDescription": "A real-time collaborative task management platform built with Flutter and Node.js. Teams can create projects, assign tasks, set deadlines, and track progress through an analytics dashboard. Features Socket.io for live updates, Kanban board view, priority queues, file attachments, and in-app notifications.",
    "technologies": ["Flutter", "Node.js", "MongoDB", "Socket.io"],
    "imageUrl": "https://play-lh.googleusercontent.com/0RQBmvs1OZjQRTdCEuBoaK-teNXGmvg9T3TVsQjMD44IDUg4PmgcC1RMmq0C2M2D7sqw-tuQLvTIpTvMwZov=w480-h960-rw",
    "githubUrl": "https://github.com/yourusername/project2",
    "liveUrl": null,
    "playStoreUrl": "https://play.google.com/store/apps/details?id=com.example.tasks",
    "appStoreUrl": null,
    "screenshots": [
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw"
    ]
  },
  {
    "title": "MO Trader",
    "slug": "mo-trader",
    "description": "Professional trading platform with real-time market data and portfolio management.",
    "longDescription": "MO Trader is a professional trading platform for Motilal Oswal, built with Flutter. It provides real-time market data, stock charting, portfolio management, and one-tap trading execution. Handles high-frequency data updates with optimized rendering, features a dark-themed trading UI, and integrates secure authentication with biometric support.",
    "technologies": ["Flutter", "Node.js", "MongoDB", "Socket.io"],
    "imageUrl": "https://play-lh.googleusercontent.com/sdTW65mkcT7OaG6Rq_tpZcO8eslU1kWsI6saA773XR0rrxJaGIG2UeCGW8cS6PLfeg=w480-h960-rw",
    "githubUrl": "https://github.com/yourusername/project2",
    "liveUrl": null,
    "playStoreUrl": "https://play.google.com/store/apps/details?id=mosl.powerapp.com&hl=en_IN",
    "appStoreUrl": null,
    "icon": "listCheck",
    "screenshots": [
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw"
    ]
  },
  {
    "title": "Weather App",
    "slug": "weather-app",
    "description": "Beautiful weather application with location-based forecasts, interactive maps, and weather alerts.",
    "longDescription": "A beautiful weather application built with Flutter using the OpenWeather API for accurate location-based forecasts, 7-day predictions, hourly breakdowns, and severe weather alerts. Google Maps integration shows interactive radar overlays. Features animated weather icons, widget support, and an Apple Watch companion app.",
    "technologies": ["Flutter", "OpenWeather API", "Google Maps"],
    "imageUrl": "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/07/e4/1a/07e41a06-4a4e-ed7c-b0ec-c12ac64e55d7/AppIcon-0-1x_U007emarketing-0-6-0-sRGB-85-220.png/400x400ia-75.webp",
    "githubUrl": "https://github.com/yourusername/project3",
    "liveUrl": null,
    "playStoreUrl": null,
    "appStoreUrl": "https://apps.apple.com/app/weather/id000000003",
    "icon": "cloudSunRain",
    "screenshots": [
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw"
    ]
  },
  {
    "title": "Torus: Banking, Trading, Demat",
    "slug": "torus-banking-trading-demat",
    "description": "All-in-one financial platform with banking, trading, and demat account management.",
    "longDescription": "Torus is a comprehensive fintech application combining banking, stock trading, and demat account management in a single Flutter app. Features include UPI payments, mutual fund investments, IPO applications, equity trading with real-time quotes, account statements, and secure KYC onboarding. Available on both iOS and Android.",
    "technologies": ["Flutter", "OpenWeather API", "Google Maps"],
    "imageUrl": "https://play-lh.googleusercontent.com/86EGsZORy_B4u4rw3o3qACNbTONQ0ju6ah6Bobrd89-VCcwm9_Pff_vAuBpm7IG0jgg=w480-h960-rw",
    "githubUrl": "https://github.com/yourusername/project3",
    "liveUrl": null,
    "playStoreUrl": "https://play.google.com/store/apps/details?id=com.torus.digital&pcampaignid=web_share",
    "appStoreUrl": "https://apps.apple.com/in/app/torus-banking-trading-demat/id6523421422",
    "icon": "cloudSunRain",
    "screenshots": [
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw",
      "https://play-lh.googleusercontent.com/J8FUh1-NuNXac9LPcDW-dQSlt5EOSPGaG4Ad-OrF1-ryy_uzly4cvZyMN3CpB-wIKqmaZLQY7tLBgYz7cL8OEA=w5120-h2880-rw"
    ]
  }
]
```

- [ ] **Step 2: Commit**

```bash
git add assets/data/portfolio.json
git commit -m "feat: add slug, screenshots, longDescription to portfolio data"
```

---

### Task 4: Extract shared ProjectIconButton widget

**Files:**
- Create: `lib/presentation/widgets/project_icon_button.dart`
- Modify: `lib/presentation/widgets/projects_section.dart`

- [ ] **Step 1: Create the shared widget**

Create `lib/presentation/widgets/project_icon_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';

class ProjectIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const ProjectIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: FaIcon(icon, size: 16, color: AppColors.primary),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
```

- [ ] **Step 2: Update projects_section.dart**

In `lib/presentation/widgets/projects_section.dart`:

1. Add import at the top (after existing imports):
```dart
import 'project_icon_button.dart';
```

2. Replace all 4 occurrences of `_IconButton(` with `ProjectIconButton(`.

3. Delete the entire `_IconButton` class at the bottom of the file (the class that starts with `class _IconButton extends StatelessWidget`).

- [ ] **Step 3: Verify compilation**

```bash
flutter build web --no-tree-shake-icons 2>&1 | tail -3
```

Expected: `Built build/web`

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/project_icon_button.dart lib/presentation/widgets/projects_section.dart
git commit -m "refactor: extract ProjectIconButton as shared widget"
```

---

### Task 5: Create router and update main.dart

**Files:**
- Create: `lib/core/router/app_router.dart`
- Create: `lib/presentation/pages/project_detail_page.dart` (stub)
- Modify: `lib/main.dart`

- [ ] **Step 1: Create stub ProjectDetailPage**

Create `lib/presentation/pages/project_detail_page.dart` (stub — will be replaced in Task 7):

```dart
import 'package:flutter/material.dart';
import '../../domain/models/portfolio_data.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(project.title)),
    );
  }
}
```

- [ ] **Step 2: Create app_router.dart**

Create `lib/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import '../../domain/models/portfolio_data.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/project_detail_page.dart';

GoRouter createRouter({
  required PortfolioData portfolioData,
  required VoidCallback onThemeToggle,
  required bool Function() isDarkMode,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(
          portfolioData: portfolioData,
          onThemeToggle: onThemeToggle,
          isDarkMode: isDarkMode(),
        ),
      ),
      GoRoute(
        path: '/project/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final project = portfolioData.projects.firstWhere(
            (p) => p.slug == slug,
            orElse: () => portfolioData.projects.first,
          );
          return ProjectDetailPage(project: project);
        },
      ),
    ],
  );
}
```

- [ ] **Step 3: Replace main.dart**

Replace the entire contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/portfolio_service.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await PortfolioService.load();
  runApp(MyApp(portfolioData: data));
}

class MyApp extends StatefulWidget {
  final portfolioData;

  const MyApp({super.key, required this.portfolioData});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;
  late final _router = createRouter(
    portfolioData: widget.portfolioData,
    onThemeToggle: _toggleTheme,
    isDarkMode: () => _isDarkMode,
  );

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shubham Memane - Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
```

NOTE: Fix the untyped `portfolioData` field — replace `final portfolioData;` with:
```dart
import 'domain/models/portfolio_data.dart';
// ...
final PortfolioData portfolioData;
```

Full corrected `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/portfolio_service.dart';
import 'core/router/app_router.dart';
import 'domain/models/portfolio_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await PortfolioService.load();
  runApp(MyApp(portfolioData: data));
}

class MyApp extends StatefulWidget {
  final PortfolioData portfolioData;

  const MyApp({super.key, required this.portfolioData});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;
  late final _router = createRouter(
    portfolioData: widget.portfolioData,
    onThemeToggle: _toggleTheme,
    isDarkMode: () => _isDarkMode,
  );

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shubham Memane - Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
```

- [ ] **Step 4: Verify compilation**

```bash
flutter build web --no-tree-shake-icons 2>&1 | tail -3
```

Expected: `Built build/web`

- [ ] **Step 5: Commit**

```bash
git add lib/core/router/app_router.dart lib/main.dart lib/presentation/pages/project_detail_page.dart
git commit -m "feat: add go_router with / and /project/:slug routes"
```

---

### Task 6: Make project cards tappable with Hero

**Files:**
- Modify: `lib/presentation/widgets/projects_section.dart`

- [ ] **Step 1: Add go_router import**

At the top of `lib/presentation/widgets/projects_section.dart`, add:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: Wrap TiltCard in GestureDetector**

In `_ProjectCardState.build()`, find the line `child: TiltCard(` inside the `TweenAnimationBuilder` and wrap it:

Replace:
```dart
child: TiltCard(
```

With:
```dart
child: GestureDetector(
  onTap: () => context.go('/project/${widget.project.slug}'),
  child: TiltCard(
```

Then add the closing `)` for `GestureDetector` after the closing `)` of `TiltCard(...)`. The structure should be:

```dart
child: GestureDetector(
  onTap: () => context.go('/project/${widget.project.slug}'),
  child: TiltCard(
    // ... all existing TiltCard content unchanged ...
  ),
),
```

- [ ] **Step 3: Add Hero around the icon/image widget**

Inside the `TiltCard`, find the `Container(height: 200, ...)` child widget. Its `child:` is currently:

```dart
child: Center(
  child: widget.project.imageUrl != null
      ? ClipRRect(...)
      : FaIcon(...),
),
```

Wrap the `ClipRRect`/`FaIcon` choice in a `Hero`:

```dart
child: Center(
  child: Hero(
    tag: 'project-icon-${widget.project.slug}',
    child: widget.project.imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: widget.project.imageUrl!.startsWith('http')
                ? Image.network(
                    widget.project.imageUrl!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => _buildGradientFallback(),
                  )
                : Image.asset(
                    widget.project.imageUrl!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => _buildGradientFallback(),
                  ),
          )
        : FaIcon(
            widget.project.icon ?? FontAwesomeIcons.code,
            size: 64,
            color: Colors.white.withValues(alpha: 0.9),
          ),
  ),
),
```

- [ ] **Step 4: Verify in browser**

```bash
flutter run -d chrome
```

Click a project card → navigates to `/project/<slug>` showing the stub page title. Icon buttons (GitHub, Play Store etc.) should still navigate to their URLs without triggering the card tap.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/projects_section.dart
git commit -m "feat: make project cards tappable with Hero animation"
```

---

### Task 7: Build full ProjectDetailPage

**Files:**
- Modify: `lib/presentation/pages/project_detail_page.dart`
- Create: `test/project_detail_page_test.dart`

- [ ] **Step 1: Write failing smoke tests**

Create `test/project_detail_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shubhammemaneportfolio/domain/models/portfolio_data.dart';
import 'package:shubhammemaneportfolio/presentation/pages/project_detail_page.dart';

void main() {
  final testProject = Project(
    title: 'Test App',
    description: 'Short description',
    technologies: ['Flutter', 'Dart'],
    slug: 'test-app',
    screenshots: [],
    longDescription: 'A longer description for testing.',
  );

  Widget _wrap(Project project) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => ProjectDetailPage(project: project)),
    ]);
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders project title', (tester) async {
    await tester.pumpWidget(_wrap(testProject));
    await tester.pump();
    expect(find.text('Test App'), findsWidgets);
  });

  testWidgets('renders longDescription', (tester) async {
    await tester.pumpWidget(_wrap(testProject));
    await tester.pump();
    expect(find.text('A longer description for testing.'), findsOneWidget);
  });

  testWidgets('hides screenshots section when screenshots is empty', (tester) async {
    await tester.pumpWidget(_wrap(testProject));
    await tester.pump();
    expect(find.text('Screenshots'), findsNothing);
  });

  testWidgets('shows screenshots section when screenshots is non-empty', (tester) async {
    final withScreenshots = Project(
      title: 'Test App',
      description: 'desc',
      technologies: [],
      slug: 'test-app',
      screenshots: ['https://example.com/screen.png'],
    );
    await tester.pumpWidget(_wrap(withScreenshots));
    await tester.pump();
    expect(find.text('Screenshots'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/project_detail_page_test.dart
```

Expected: 2 tests FAIL (stub shows title but not longDescription or Screenshots heading)

- [ ] **Step 3: Replace project_detail_page.dart with full implementation**

Replace entire contents of `lib/presentation/pages/project_detail_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/portfolio_data.dart';
import '../widgets/project_icon_button.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Color _gradientStart = AppColors.primary;
  Color _gradientEnd = AppColors.accent;

  static const _fakeStats = <String, (String, String, String)>{
    'e-commerce-app':              ('Shopping',     '50K+',  '4.7'),
    'task-management-system':      ('Productivity', '20K+',  '4.5'),
    'mo-trader':                   ('Finance',      '100K+', '4.8'),
    'weather-app':                 ('Weather',      '30K+',  '4.6'),
    'torus-banking-trading-demat': ('Finance',      '80K+',  '4.9'),
  };

  (String, String, String) get _stats =>
      _fakeStats[widget.project.slug] ?? ('Utility', '10K+', '4.5');

  @override
  void initState() {
    super.initState();
    final url = widget.project.imageUrl;
    if (url != null && url.startsWith('http')) _extractColors(url);
  }

  Future<void> _extractColors(String url) async {
    try {
      final gen = await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        size: const Size(100, 100),
      );
      if (!mounted) return;
      final dominant = gen.dominantColor?.color;
      final muted = gen.mutedColor?.color ?? gen.vibrantColor?.color;
      if (dominant != null) {
        setState(() {
          _gradientStart = dominant;
          _gradientEnd = muted ?? dominant.withValues(alpha: 0.6);
        });
      }
    } catch (_) {}
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (category, downloads, rating) = _stats;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              project: widget.project,
              gradientStart: _gradientStart,
              gradientEnd: _gradientEnd,
            ),
            _ActionBar(
              project: widget.project,
              category: category,
              downloads: downloads,
              rating: rating,
              onLaunch: _launch,
            ),
            if (widget.project.screenshots.isNotEmpty)
              _ScreenshotsSection(screenshots: widget.project.screenshots),
            _AboutSection(
              text: widget.project.longDescription ?? widget.project.description,
              isDark: isDark,
            ),
            _TechSection(technologies: widget.project.technologies),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Project project;
  final Color gradientStart;
  final Color gradientEnd;

  const _Header({
    required this.project,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientStart.withValues(alpha: 0.9),
            gradientEnd.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'project-icon-${project.slug}',
                  child: project.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: project.imageUrl!.startsWith('http')
                              ? Image.network(
                                  project.imageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _IconFallback(icon: project.icon),
                                )
                              : Image.asset(
                                  project.imageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _IconFallback(icon: project.icon),
                                ),
                        )
                      : _IconFallback(icon: project.icon),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                  child: Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconFallback extends StatelessWidget {
  final IconData? icon;
  const _IconFallback({this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Center(
        child: FaIcon(
          icon ?? FontAwesomeIcons.code,
          size: 48,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Project project;
  final String category;
  final String downloads;
  final String rating;
  final void Function(String) onLaunch;

  const _ActionBar({
    required this.project,
    required this.category,
    required this.downloads,
    required this.rating,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          if (project.githubUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.github,
              tooltip: 'GitHub',
              onTap: () => onLaunch(project.githubUrl!),
            ),
          if (project.liveUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.arrowUpRightFromSquare,
              tooltip: 'Live Demo',
              onTap: () => onLaunch(project.liveUrl!),
            ),
          if (project.playStoreUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.googlePlay,
              tooltip: 'Play Store',
              onTap: () => onLaunch(project.playStoreUrl!),
            ),
          if (project.appStoreUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.appStoreIos,
              tooltip: 'App Store',
              onTap: () => onLaunch(project.appStoreUrl!),
            ),
          _StatChip(label: '$rating ★'),
          _StatChip(label: downloads),
          _StatChip(label: category),
        ],
      ),
    );
  }
}

class _ScreenshotsSection extends StatelessWidget {
  final List<String> screenshots;
  const _ScreenshotsSection({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Screenshots',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: screenshots.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  screenshots[index],
                  width: 130,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 130,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String text;
  final bool isDark;
  const _AboutSection({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this project',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _TechSection extends StatelessWidget {
  final List<String> technologies;
  const _TechSection({required this.technologies});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Technologies',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: technologies.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  tech,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxxl, horizontal: AppSpacing.lg),
      child: Center(
        child: TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to Portfolio'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
flutter test test/project_detail_page_test.dart
```

Expected: All 4 tests PASS

- [ ] **Step 5: Verify full app in browser**

```bash
flutter run -d chrome
```

Verify:
- Home page loads with project cards
- Clicking a card navigates to `/project/<slug>` with Play Store layout
- Header gradient matches card colors
- Hero animation plays on card icon
- Screenshots carousel scrolls horizontally
- About, Technologies, stat chips all visible
- Back arrow and "Back to Portfolio" button return to home
- Typing `/project/mo-trader` directly in browser address bar loads correctly

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/pages/project_detail_page.dart test/project_detail_page_test.dart
git commit -m "feat: implement Play Store-style project detail page"
```
