# 3D Motion Effects Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add bold 3D parallax, mouse-driven card tilt, and animated particle canvas to the Flutter web portfolio.

**Architecture:** A `ValueNotifier<Offset>` in `_HomePageState` holds the normalized mouse position (-1..1). The hero reads it to drive parallax rings, glow, and content tilt. A reusable `TiltCard` widget tracks local mouse events to apply `Matrix4` perspective transforms. A `CustomPainter` + `Ticker` renders the particle canvas at 60fps independently.

**Tech Stack:** Flutter web, `dart:ui` (ImageFilter, Canvas), `dart:math`, no new packages.

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/core/state/mouse_notifier.dart` | Create | `ValueNotifier<Offset>` typedef |
| `lib/presentation/widgets/tilt_card.dart` | Create | Reusable 3D tilt + shine wrapper |
| `lib/presentation/widgets/particle_canvas.dart` | Create | Ticker-driven particle + grid painter |
| `lib/presentation/widgets/parallax_rings.dart` | Create | 3 depth-layered concentric rings |
| `lib/presentation/pages/home_page.dart` | Modify | Column→Stack layout; global MouseRegion; mouseNotifier |
| `lib/presentation/widgets/nav_bar.dart` | Modify | BackdropFilter glassmorphism; Positioned overlay |
| `lib/presentation/widgets/hero_section.dart` | Modify | Integrate ParticleCanvas, ParallaxRings, glow, content tilt |
| `lib/presentation/widgets/projects_section.dart` | Modify | Remove AnimatedContainer transform; wrap in TiltCard |
| `lib/presentation/widgets/skills_section.dart` | Modify | Convert _SkillCategory to StatefulWidget; wrap in TiltCard |
| `test/presentation/widgets/tilt_card_test.dart` | Create | Widget tree structure tests |
| `test/presentation/widgets/particle_canvas_test.dart` | Create | Smoke tests |

---

## Task 1: MouseNotifier typedef

**Files:**
- Create: `lib/core/state/mouse_notifier.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/core/state/mouse_notifier.dart
import 'package:flutter/widgets.dart';

/// Normalized mouse position relative to viewport center.
/// dx and dy are in range -1.0 to 1.0.
typedef MouseNotifier = ValueNotifier<Offset>;
```

- [ ] **Step 2: Verify it compiles**

```bash
cd /Users/shubhammeamane/Documents/Practice/shubhammemaneportfolio
flutter analyze lib/core/state/mouse_notifier.dart
```
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/state/mouse_notifier.dart
git commit -m "feat: add MouseNotifier typedef for global mouse tracking"
```

---

## Task 2: TiltCard widget

**Files:**
- Create: `lib/presentation/widgets/tilt_card.dart`
- Create: `test/presentation/widgets/tilt_card_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/presentation/widgets/tilt_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/presentation/widgets/tilt_card.dart';

void main() {
  testWidgets('TiltCard renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TiltCard(
            child: Text('hello'),
          ),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('TiltCard contains a MouseRegion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TiltCard(
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
    expect(find.byType(MouseRegion), findsWidgets);
  });

  testWidgets('TiltCard with showShine false renders child without shine overlay', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TiltCard(
            showShine: false,
            child: Text('no-shine'),
          ),
        ),
      ),
    );
    expect(find.text('no-shine'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
flutter test test/presentation/widgets/tilt_card_test.dart
```
Expected: `Error: 'TiltCard' is not defined` (file doesn't exist yet).

- [ ] **Step 3: Implement TiltCard**

```dart
// lib/presentation/widgets/tilt_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDegrees;
  final bool showShine;
  final Color hoverBorderColor;
  final Color hoverGlowColor;
  final double perspective;
  final double borderRadius;

  const TiltCard({
    required this.child,
    this.maxTiltDegrees = 14,
    this.showShine = true,
    this.hoverBorderColor = const Color(0x5510B981),
    this.hoverGlowColor = const Color(0x2210B981),
    this.perspective = 800,
    this.borderRadius = 16,
    super.key,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  late Animation<double> _tiltXAnim;
  late Animation<double> _tiltYAnim;

  double _tiltX = 0;
  double _tiltY = 0;
  Offset _shinePos = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tiltXAnim = const AlwaysStoppedAnimation(0);
    _tiltYAnim = const AlwaysStoppedAnimation(0);
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHover(PointerHoverEvent event, BoxConstraints constraints) {
    _resetController.stop();
    final dx = (event.localPosition.dx / constraints.maxWidth) * 2 - 1;
    final dy = (event.localPosition.dy / constraints.maxHeight) * 2 - 1;
    setState(() {
      _tiltX = -dy * widget.maxTiltDegrees;
      _tiltY = dx * widget.maxTiltDegrees;
      _shinePos = Offset(
        event.localPosition.dx / constraints.maxWidth,
        event.localPosition.dy / constraints.maxHeight,
      );
      _isHovered = true;
    });
  }

  void _onExit(PointerExitEvent _) {
    final fromX = _tiltX;
    final fromY = _tiltY;
    _tiltXAnim = Tween<double>(begin: fromX, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _tiltX = _tiltXAnim.value;
          _tiltY = _tiltYAnim.value;
        });
      });
    _tiltYAnim = Tween<double>(begin: fromY, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _resetController
      ..reset()
      ..forward().then((_) => setState(() => _isHovered = false));
  }

  Matrix4 _buildMatrix() {
    final tx = _tiltX * math.pi / 180;
    final ty = _tiltY * math.pi / 180;
    return Matrix4.identity()
      ..setEntry(3, 2, 1 / widget.perspective)
      ..rotateX(tx)
      ..rotateY(ty)
      ..translate(0.0, 0.0, _isHovered ? 20.0 : 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (e) => _onHover(e, constraints),
          onExit: _onExit,
          child: Transform(
            transform: _buildMatrix(),
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: _isHovered
                      ? widget.hoverBorderColor
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.hoverGlowColor,
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(widget.borderRadius),
                child: Stack(
                  children: [
                    widget.child,
                    if (widget.showShine && _isHovered)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(
                                  _shinePos.dx * 2 - 1,
                                  _shinePos.dy * 2 - 1,
                                ),
                                radius: 1.2,
                                colors: [
                                  Colors.white.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
flutter test test/presentation/widgets/tilt_card_test.dart
```
Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/tilt_card.dart test/presentation/widgets/tilt_card_test.dart
git commit -m "feat: add TiltCard widget with 3D mouse-driven tilt and shine"
```

---

## Task 3: ParticleCanvas widget

**Files:**
- Create: `lib/presentation/widgets/particle_canvas.dart`
- Create: `test/presentation/widgets/particle_canvas_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/presentation/widgets/particle_canvas_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/presentation/widgets/particle_canvas.dart';
import 'package:shubhammemaneportfolio/core/state/mouse_notifier.dart';

void main() {
  testWidgets('ParticleCanvas renders without error', (tester) async {
    final notifier = MouseNotifier(Offset.zero);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParticleCanvas(mouseNotifier: notifier),
        ),
      ),
    );
    expect(find.byType(ParticleCanvas), findsOneWidget);
    notifier.dispose();
  });

  testWidgets('ParticleCanvas contains a CustomPaint', (tester) async {
    final notifier = MouseNotifier(Offset.zero);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParticleCanvas(mouseNotifier: notifier),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
    notifier.dispose();
  });
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
flutter test test/presentation/widgets/particle_canvas_test.dart
```
Expected: `Error: 'ParticleCanvas' is not defined`.

- [ ] **Step 3: Implement ParticleCanvas**

```dart
// lib/presentation/widgets/particle_canvas.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/state/mouse_notifier.dart';

class ParticleCanvas extends StatefulWidget {
  final MouseNotifier mouseNotifier;

  const ParticleCanvas({required this.mouseNotifier, super.key});

  @override
  State<ParticleCanvas> createState() => _ParticleCanvasState();
}

class _ParticleCanvasState extends State<ParticleCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  static const int _particleCount = 80;
  static const double _connectionDistance = 100;
  static const double _repulsionRadius = 120;
  static const Color _particleColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < _particleCount; i++) {
        _particles.add(_Particle.random(_random, size));
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final deltaMs = (elapsed - _lastElapsed).inMilliseconds.clamp(1, 32);
    _lastElapsed = elapsed;

    final size = context.size ?? Size.zero;
    final mouse = widget.mouseNotifier.value;
    // Convert normalized -1..1 to pixel position
    final mousePx = Offset(
      (mouse.dx + 1) / 2 * size.width,
      (mouse.dy + 1) / 2 * size.height,
    );

    for (final p in _particles) {
      p.update(deltaMs.toDouble(), size, mousePx, _repulsionRadius);
    }

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        connectionDistance: _connectionDistance,
        color: _particleColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, opacity;
  bool glowing;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.glowing,
  });

  factory _Particle.random(math.Random rnd, Size bounds) {
    final speed = 0.3 + rnd.nextDouble() * 0.4; // 0.3–0.7 px per 16ms
    final angle = rnd.nextDouble() * 2 * math.pi;
    return _Particle(
      x: rnd.nextDouble() * bounds.width,
      y: rnd.nextDouble() * bounds.height,
      vx: math.cos(angle) * speed,
      vy: math.sin(angle) * speed,
      size: rnd.nextDouble() * 2 + 1,
      opacity: rnd.nextDouble() * 0.6 + 0.2,
      glowing: rnd.nextDouble() > 0.6,
    );
  }

  void update(double deltaMs, Size bounds, Offset mouse, double repulsionRadius) {
    final scale = deltaMs / 16.0;
    x += vx * scale;
    y += vy * scale;

    // Bounce off walls
    if (x < 0 || x > bounds.width) vx = -vx;
    if (y < 0 || y > bounds.height) vy = -vy;
    x = x.clamp(0, bounds.width);
    y = y.clamp(0, bounds.height);

    // Mouse repulsion
    final dx = x - mouse.dx;
    final dy = y - mouse.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < repulsionRadius && dist > 0) {
      final force = (repulsionRadius - dist) / repulsionRadius * 1.5 * scale;
      x += (dx / dist) * force;
      y += (dy / dist) * force;
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double connectionDistance;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.connectionDistance,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawConnections(canvas);
    _drawParticles(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    // Draw grid lines with radial opacity fade from center
    const step = 50.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxDist = math.sqrt(cx * cx + cy * cy);

    double _gridOpacity(double x, double y) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);
      return (1 - dist / maxDist).clamp(0.0, 1.0) * 0.10;
    }

    for (double x = 0; x < size.width; x += step) {
      final opacity = _gridOpacity(x, cy);
      canvas.drawLine(
        Offset(x, 0), Offset(x, size.height),
        Paint()..color = color.withOpacity(opacity)..strokeWidth = 0.5,
      );
    }
    for (double y = 0; y < size.height; y += step) {
      final opacity = _gridOpacity(cx, y);
      canvas.drawLine(
        Offset(0, y), Offset(size.width, y),
        Paint()..color = color.withOpacity(opacity)..strokeWidth = 0.5,
      );
    }
  }

  void _drawConnections(Canvas canvas) {
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].x - particles[j].x;
        final dy = particles[i].y - particles[j].y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < connectionDistance) {
          final opacity = (1 - dist / connectionDistance) * 0.15;
          canvas.drawLine(
            Offset(particles[i].x, particles[i].y),
            Offset(particles[j].x, particles[j].y),
            Paint()
              ..color = color.withOpacity(opacity)
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final paint = Paint()..color = color.withOpacity(p.opacity);
      if (p.glowing) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      }
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
flutter test test/presentation/widgets/particle_canvas_test.dart
```
Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/particle_canvas.dart test/presentation/widgets/particle_canvas_test.dart
git commit -m "feat: add ParticleCanvas with ticker-driven particles and grid"
```

---

## Task 4: ParallaxRings widget

**Files:**
- Create: `lib/presentation/widgets/parallax_rings.dart`

- [ ] **Step 1: Create ParallaxRings**

```dart
// lib/presentation/widgets/parallax_rings.dart
import 'package:flutter/material.dart';
import '../../core/state/mouse_notifier.dart';

/// Three concentric rings that move at different parallax depths
/// as the mouse moves, creating a sense of 3D layering.
class ParallaxRings extends StatelessWidget {
  final MouseNotifier mouseNotifier;

  const ParallaxRings({required this.mouseNotifier, super.key});

  // Parallax factors: outermost moves most (appears closest)
  static const _factors = [0.04, 0.025, 0.01];
  static const _diameters = [500.0, 350.0, 200.0];
  static const _opacities = [0.12, 0.2, 0.35];
  static const Color _ringColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: mouseNotifier,
      builder: (context, mouse, _) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final screenW = MediaQuery.of(context).size.width;
            final screenH = MediaQuery.of(context).size.height;
            final offsetX = mouse.dx * screenW / 2 * _factors[i];
            final offsetY = mouse.dy * screenH / 2 * _factors[i];
            return Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Container(
                width: _diameters[i],
                height: _diameters[i],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _ringColor.withOpacity(_opacities[i]),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/presentation/widgets/parallax_rings.dart
```
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/widgets/parallax_rings.dart
git commit -m "feat: add ParallaxRings widget with depth-layered mouse parallax"
```

---

## Task 5: NavBar glassmorphism

**Files:**
- Modify: `lib/presentation/widgets/nav_bar.dart`

The current NavBar is a `Container` with a solid background. Replace the `Container`'s decoration with a `ClipRect` + `BackdropFilter` glass effect. **Note:** `BackdropFilter` only works when the NavBar is positioned over scroll content in a `Stack` (done in Task 6). The change here just sets up the decoration; it will visually activate after the layout change.

- [ ] **Step 1: Update nav_bar.dart**

Add `dart:ui` import and replace the outer `Container` decoration:

```dart
// lib/presentation/widgets/nav_bar.dart
import 'dart:ui';                          // ADD THIS LINE
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const NavBar({super.key, required this.onThemeToggle, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ClipRect(                        // REPLACES outer Container
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.value(context, mobile: AppSpacing.lg, desktop: AppSpacing.xxxl),
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: const Border(
              bottom: BorderSide(color: Color(0x1A10B981), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '<SM />',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (Responsive.isDesktop(context))
                Row(
                  children: [
                    _NavItem(label: 'About', onTap: () {}),
                    _NavItem(label: 'Skills', onTap: () {}),
                    _NavItem(label: 'Projects', onTap: () {}),
                    _NavItem(label: 'Experience', onTap: () {}),
                    _NavItem(label: 'Contact', onTap: () {}),
                    const SizedBox(width: AppSpacing.md),
                    _ThemeToggle(onToggle: onThemeToggle, isDark: isDarkMode),
                  ],
                )
              else
                _ThemeToggle(onToggle: onThemeToggle, isDark: isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
}

// _NavItem and _ThemeToggle — keep exactly as they are
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/widgets/nav_bar.dart
```
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/widgets/nav_bar.dart
git commit -m "feat: add glassmorphism BackdropFilter to NavBar"
```

---

## Task 6: Home page layout — Stack + global MouseRegion

**Files:**
- Modify: `lib/presentation/pages/home_page.dart`

Change the `Column([NavBar, Expanded(scroll)])` to `Stack([scroll, Positioned(NavBar)])`. Add `MouseNotifier` field and global `MouseRegion`.

- [ ] **Step 1: Update home_page.dart**

```dart
// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import '../../core/constants/portfolio_data.dart';
import '../../core/state/mouse_notifier.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/contact_section.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomePage({super.key, required this.onThemeToggle, required this.isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MouseNotifier _mouseNotifier = MouseNotifier(Offset.zero);

  void _onMouseMove(PointerHoverEvent event) {
    final size = MediaQuery.of(context).size;
    _mouseNotifier.value = Offset(
      (event.localPosition.dx - size.width / 2) / (size.width / 2),
      (event.localPosition.dy - size.height / 2) / (size.height / 2),
    );
  }

  @override
  void dispose() {
    _mouseNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onHover: _onMouseMove,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 64), // space for Positioned NavBar
                  HeroSection(
                    personalInfo: portfolioData.personalInfo,
                    mouseNotifier: _mouseNotifier,
                  ),
                  SkillsSection(skills: portfolioData.skills),
                  ProjectsSection(projects: portfolioData.projects),
                  ExperienceSection(experiences: portfolioData.experiences),
                  ContactSection(contactInfo: portfolioData.contactInfo),
                  const _Footer(),
                ],
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: NavBar(
                onThemeToggle: widget.onThemeToggle,
                isDarkMode: widget.isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Text(
        '© 2024 Shubham Memane. Built with Flutter',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[600]
              : Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/pages/home_page.dart
```
Expected: no issues. HeroSection will show a compile error about `mouseNotifier` — that's expected and fixed in Task 7.

- [ ] **Step 3: Hot restart and verify NavBar floats correctly**

```bash
flutter run -d chrome
```
Visually confirm: NavBar stays at top while scrolling, glassmorphism blur is visible behind it, content doesn't hide under NavBar on page load.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/pages/home_page.dart
git commit -m "feat: restructure HomePage to Stack layout with global MouseRegion"
```

---

## Task 7: Hero section — integrate all 3D effects

**Files:**
- Modify: `lib/presentation/widgets/hero_section.dart`

Add `mouseNotifier` parameter. Convert to `StatelessWidget` accepting `mouseNotifier`. Wrap content in a `Stack`: `[ParticleCanvas, ParallaxRings, GlowBlob, HeroContent]`.

- [ ] **Step 1: Update hero_section.dart**

```dart
// lib/presentation/widgets/hero_section.dart
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/state/mouse_notifier.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../domain/models/portfolio_data.dart';
import 'particle_canvas.dart';
import 'parallax_rings.dart';

class HeroSection extends StatelessWidget {
  final PersonalInfo personalInfo;
  final MouseNotifier mouseNotifier;

  const HeroSection({
    super.key,
    required this.personalInfo,
    required this.mouseNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Particle canvas (fills entire hero)
          Positioned.fill(
            child: ParticleCanvas(mouseNotifier: mouseNotifier),
          ),

          // Layer 2: Parallax depth rings
          Positioned.fill(
            child: ParallaxRings(mouseNotifier: mouseNotifier),
          ),

          // Layer 3: Glow blob follows mouse
          _GlowBlob(mouseNotifier: mouseNotifier),

          // Layer 4: Hero content — tilts with mouse
          _HeroContent(
            personalInfo: personalInfo,
            mouseNotifier: mouseNotifier,
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final MouseNotifier mouseNotifier;

  const _GlowBlob({required this.mouseNotifier});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<Offset>(
      valueListenable: mouseNotifier,
      builder: (context, mouse, _) {
        final cx = size.width / 2 + mouse.dx * size.width / 2;
        final cy = size.height / 2 + mouse.dy * size.height / 2;
        return Positioned(
          left: cx - 200,
          top: cy - 200,
          child: IgnorePointer(
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x2010B981), Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroContent extends StatelessWidget {
  final PersonalInfo personalInfo;
  final MouseNotifier mouseNotifier;

  const _HeroContent({
    required this.personalInfo,
    required this.mouseNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: mouseNotifier,
      builder: (context, mouse, child) {
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(mouse.dx * 3 * 3.14159 / 180)
          ..rotateX(-mouse.dy * 2 * 3.14159 / 180);
        return Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.value(
              context, mobile: AppSpacing.lg, desktop: AppSpacing.xxxl),
          vertical: AppSpacing.xxxl,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)), child: child),
                ),
                child: Text(
                  'Hi, I\'m',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)), child: child),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0x8810B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    personalInfo.name,
                    style: Responsive.value(
                      context,
                      mobile: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white),
                      desktop: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1200),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) =>
                    Opacity(opacity: value, child: child),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I\'m a ',
                      style: Responsive.value(
                        context,
                        mobile: Theme.of(context).textTheme.headlineSmall,
                        desktop: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          personalInfo.title,
                          textStyle: Responsive.value(
                            context,
                            mobile:
                                Theme.of(context).textTheme.headlineSmall,
                            desktop:
                                Theme.of(context).textTheme.headlineMedium,
                          )?.copyWith(color: AppColors.primary),
                          speed: const Duration(milliseconds: 100),
                        ),
                        TypewriterAnimatedText(
                          'Problem Solver',
                          textStyle: Responsive.value(
                            context,
                            mobile:
                                Theme.of(context).textTheme.headlineSmall,
                            desktop:
                                Theme.of(context).textTheme.headlineMedium,
                          )?.copyWith(color: AppColors.secondary),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1400),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)), child: child),
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Text(
                    personalInfo.bio,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(scale: value, child: child),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                    shadowColor: AppColors.primary.withOpacity(0.5),
                    elevation: 12,
                  ),
                  child: const Text('View My Work',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/widgets/hero_section.dart
```
Expected: no issues.

- [ ] **Step 3: Hot restart and verify hero effects**

```bash
flutter run -d chrome
```
Visually verify:
- Particles drift and connect with faint lines
- Grid is visible in hero area
- Green glow follows the cursor
- Rings shift at different depths as mouse moves
- Hero text block tilts subtly with mouse

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/hero_section.dart
git commit -m "feat: add particle canvas, parallax rings, glow, and content tilt to hero"
```

---

## Task 8: Project cards — 3D TiltCard

**Files:**
- Modify: `lib/presentation/widgets/projects_section.dart`

Remove existing `AnimatedContainer` with `_isHovered` translate transform and hover border/shadow. Replace the entire `_ProjectCardState.build` with `TiltCard` wrapping the card content.

- [ ] **Step 1: Update _ProjectCard in projects_section.dart**

Replace the `_ProjectCardState` class (the `build` method and `_isHovered` field):

```dart
// In projects_section.dart — replace _ProjectCardState entirely:

class _ProjectCardState extends State<_ProjectCard> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (widget.index * 200)),
      tween: Tween(begin: 0, end: widget.isVisible ? 1 : 0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TiltCard(
        maxTiltDegrees: 14,
        showShine: true,
        perspective: 800,
        hoverBorderColor: const Color(0x5510B981),
        hoverGlowColor: const Color(0x2210B981),
        child: SizedBox(
          width: Responsive.value(
              context, mobile: double.infinity, tablet: 350, desktop: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.accent.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(FontAwesomeIcons.code,
                      size: 64, color: Colors.white.withOpacity(0.9)),
                ),
              ),
              Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.project.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.project.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: widget.project.technologies.map((tech) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(tech,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        if (widget.project.liveUrl != null)
                          _IconButton(
                              icon: FontAwesomeIcons.arrowUpRightFromSquare,
                              onTap: () => _launchUrl(widget.project.liveUrl!)),
                        if (widget.project.liveUrl != null &&
                            widget.project.githubUrl != null)
                          const SizedBox(width: AppSpacing.sm),
                        if (widget.project.githubUrl != null)
                          _IconButton(
                              icon: FontAwesomeIcons.github,
                              onTap: () =>
                                  _launchUrl(widget.project.githubUrl!)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
```

Also add the import at the top of `projects_section.dart`:
```dart
import 'tilt_card.dart';
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/widgets/projects_section.dart
```
Expected: no issues.

- [ ] **Step 3: Hot restart and verify card tilt**

Move the mouse over project cards. Verify:
- Card tilts toward cursor (~14° max)
- White shine moves with cursor
- Green border glow appears on hover
- Card springs back smoothly on mouse leave

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/projects_section.dart
git commit -m "feat: replace project card hover with 3D TiltCard tilt and shine"
```

---

## Task 9: Skill cards — TiltCard (light)

**Files:**
- Modify: `lib/presentation/widgets/skills_section.dart`

Convert `_SkillCategory` from `StatelessWidget` to `StatefulWidget`. Wrap its content in `TiltCard` with lighter settings.

- [ ] **Step 1: Update skills_section.dart**

Add import and convert `_SkillCategory`:

```dart
// Add import at top of skills_section.dart:
import 'tilt_card.dart';
```

Replace the `_SkillCategory` class:

```dart
// Replace _SkillCategory (StatelessWidget → StatefulWidget):

class _SkillCategory extends StatefulWidget {
  final String category;
  final List<Skill> skills;
  final bool isVisible;

  const _SkillCategory(
      {required this.category, required this.skills, required this.isVisible});

  @override
  State<_SkillCategory> createState() => _SkillCategoryState();
}

class _SkillCategoryState extends State<_SkillCategory> {
  @override
  Widget build(BuildContext context) {
    return TiltCard(
      maxTiltDegrees: 5,
      showShine: false,
      perspective: 600,
      hoverBorderColor: const Color(0x3310B981),
      hoverGlowColor: const Color(0x1110B981),
      child: Container(
        width: Responsive.value(
            context, mobile: double.infinity, tablet: 300, desktop: 350),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            ...widget.skills.map((skill) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(skill.name,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween(
                              begin: 0,
                              end: widget.isVisible ? skill.proficiency : 0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 8,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkBackground
                                  : Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/widgets/skills_section.dart
```
Expected: no issues.

- [ ] **Step 3: Hot restart and verify skill card tilt**

Hover over skill cards. Verify:
- Subtle 5° tilt toward cursor
- No shine overlay
- Green border glow (lighter than project cards)
- Smooth spring-back

- [ ] **Step 4: Full analyze pass**

```bash
flutter analyze lib/
```
Expected: no issues across the whole project.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/skills_section.dart
git commit -m "feat: add subtle 3D TiltCard to skill category cards"
```

---

## Task 10: Final verification

- [ ] **Step 1: Run all widget tests**

```bash
flutter test
```
Expected: all tests pass.

- [ ] **Step 2: Build for web**

```bash
flutter build web
```
Expected: build succeeds with no errors.

- [ ] **Step 3: Serve and do a full visual pass in Chrome**

```bash
flutter run -d chrome --release
```

Verify each effect:
- [ ] Mouse moves in hero → particles dodge cursor, rings shift at 3 depths, glow follows
- [ ] Hero text tilts subtly with mouse movement
- [ ] NavBar blurs scroll content visible behind it
- [ ] Project card hover → 14° 3D tilt + shine + glow border
- [ ] Project card mouse leave → smooth spring-back 300ms
- [ ] Skill card hover → 5° tilt + light border
- [ ] Scroll-triggered fade-in on all sections still works
- [ ] Typewriter animation in hero still works
- [ ] Dark/light theme toggle still works
- [ ] No jank or frame drops in Chrome DevTools Performance tab

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete 3D motion effects — particles, parallax, card tilt"
```
