# 3D & Motion-Sensitive Portfolio Design Spec
**Date:** 2026-04-04  
**Status:** Approved

---

## Overview

Add bold, dramatic 3D and motion-sensitive effects to the existing Flutter web portfolio. The goal is a futuristic, high-impact look using three layered techniques: particle/grid hero background, mouse-driven parallax depth, and 3D card tilting. No new packages required.

---

## Effects & Scope

### 1. Hero Section — Particles + Grid + Parallax Rings

**What:**
- A `CustomPainter` canvas behind the hero content renders 80 floating green particles (`#10B981`) that slowly drift and connect with faint lines when close. Particles gently dodge the cursor (repulsion within 120px radius).
- A grid overlay (drawn in the same `CustomPainter`, horizontal + vertical lines) masked by a radial gradient so lines fade at the edges. Grid cell size: 50×50 logical pixels, line color `#10B98120`.
- Three concentric `AnimatedBuilder`-driven ring widgets at diameters 50%, 35%, and 20% of the hero width. Each ring is positioned absolutely in a `Stack` and translates at a different parallax factor as the mouse moves — creating a depth illusion.
- A radial green glow blob (a `Container` with `BoxDecoration` radial gradient, 400px diameter) that follows the cursor using an `AnimatedPositioned`-style transform.
- The hero text block (`hi, I'm` / name / typewriter / bio / CTA) subtly tilts as a whole via `Transform` with `Matrix4.identity()..setEntry(3,2,0.001)` — max 3° X, 2° Y — as the mouse moves across the viewport.

**Data:** Mouse position tracked globally via `MouseRegion` wrapping the entire page (see Architecture section).

**Intensity:**
- Particle glow: `Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 6)` (≈ CSS shadowBlur 12px), bright opacity `0.2–0.8`
- Particle drift speed: `0.3–0.7 logical px/frame`
- Line connections: visible within 100px, max opacity 0.15
- Ring parallax factors: ring 1 (outermost) = 0.04, ring 2 = 0.025, ring 3 (innermost) = 0.01, multiplied by the normalized viewport-center delta (range -1..1 → max pixel offsets 30px, 18px, 8px at screen edge)

---

### 2. Project Cards — 3D Tilt

**What:**
- Each `_ProjectCard` uses `TiltCard` wrapper (see `tilt_card.dart` interface below).
- The existing `AnimatedContainer` with `transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0)` is **removed and replaced entirely** by `TiltCard`.
- On hover: card transforms with `Matrix4` perspective (800px) + `rotateX` + `rotateY`, max **14°** each axis, toward cursor. `translateZ(20px)` + `scale(1.02)` lifts the card.
- Dynamic box shadow shifts opposite to tilt direction.
- A "shine" gradient overlay (radial white at 4–6% opacity) follows the cursor position within the card — simulates a light reflection. `showShine: true`.
- Smooth spring-back on mouse leave: `AnimationController` duration 300ms, `Curves.easeOutCubic`. The `TiltCard` owns its own `TickerProvider` (it is `StatefulWidget` with `SingleTickerProviderStateMixin`).
- **Border/glow on hover:** border `#10B98155`, outer glow `0 0 40px #10B98122`.

---

### 3. Skill Cards — 3D Tilt (Lighter)

**What:**
- Same `TiltCard` wrapper, `maxTiltDegrees: 5`, `showShine: false`.
- The existing `_SkillCategory` widget **must be converted from `StatelessWidget` to `StatefulWidget`** before `TiltCard` is embedded (required because the enclosing context needs to handle the `isVisible` flag mutation — `TiltCard` itself handles its own state internally).
- On hover: `translateZ(10px)`, border `#10B98133`, glow `0 0 20px #10B98111`.

---

### 4. Nav Bar — Glassmorphism

**What:**
- Add `ClipRect` + `BackdropFilter(filter: ImageFilter.blur(sigmaX:16, sigmaY:16))` to create frosted glass effect.
- Bottom border: `Border(bottom: BorderSide(color: Color(0x1A10B981), width: 1))`.
- Background: `Colors.black.withOpacity(0.6)`.
- **Layout requirement:** For `BackdropFilter` to blur the content behind the NavBar, the NavBar must be a `Stack` overlay on top of the scrollable content — not a `Column` sibling before it. The existing `Column([NavBar, Expanded(SingleChildScrollView)])` layout in `home_page.dart` must be changed to a `Stack([SingleChildScrollView(...), Positioned(top:0, NavBar)])`.

---

## Architecture

### Layout Change in `home_page.dart`

Current layout:
```
Scaffold
  body: Column
    NavBar
    Expanded → SingleChildScrollView → Column (sections)
```

New layout:
```
Scaffold
  body: MouseRegion (global, covers full Scaffold body)
    Stack
      SingleChildScrollView
        Column
          SizedBox(height: 64)   ← FIRST child only; compensates for Positioned NavBar height
          HeroSection
          SkillsSection
          ProjectsSection
          ExperienceSection
          ContactSection
          Footer
      Positioned(top:0, left:0, right:0)
        NavBar  ← floats over scroll content, BackdropFilter blurs content below it
```

The `SizedBox(height: 64)` appears exactly once, as the **first** child of the sections `Column`. It is not repeated between sections.

### Global Mouse State

A single `ValueNotifier<Offset>` declared as a field on `_HomePageState`, named `_mouseNotifier`. It holds the normalized mouse position relative to viewport center (`dx` and `dy` in range -1.0 to 1.0).

```dart
// In _HomePageState:
final _mouseNotifier = ValueNotifier<Offset>(Offset.zero);

// MouseRegion onHover callback:
void _onMouseMove(PointerHoverEvent event) {
  final size = MediaQuery.of(context).size;
  _mouseNotifier.value = Offset(
    (event.localPosition.dx - size.width / 2) / (size.width / 2),
    (event.localPosition.dy - size.height / 2) / (size.height / 2),
  );
}
```

`HeroSection` receives `mouseNotifier` as a constructor parameter. `NavBar` does **not** receive `mouseNotifier` — the glassmorphism effect is purely layout-based and requires no mouse data. Lower sections (`ProjectsSection`, `SkillsSection`) do not receive it — they use local `MouseRegion` within `TiltCard`.

### `TiltCard` Widget Interface

```dart
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDegrees;    // 14 for project cards, 5 for skill cards
  final bool showShine;           // true for project cards, false for skill cards
  final Color hoverBorderColor;   // Color(0x5510B981) for projects, Color(0x3310B981) for skills
  final Color hoverGlowColor;     // Color(0x2210B981) for projects, Color(0x1110B981) for skills
  final double perspective;       // 800 for projects, 600 for skills

  const TiltCard({
    required this.child,
    this.maxTiltDegrees = 14,
    this.showShine = true,
    this.hoverBorderColor = const Color(0x5510B981),
    this.hoverGlowColor = const Color(0x2210B981),
    this.perspective = 800,
    super.key,
  });
}
```

`TiltCard` is `StatefulWidget` with `SingleTickerProviderStateMixin`. It owns the `AnimationController` for spring-back. It wraps `child` in a `MouseRegion` + `Stack` (for the shine overlay if `showShine` is true).

### `ParticleCanvas` Repaint Strategy

- `ParticleCanvas` is a `StatefulWidget` with `SingleTickerProviderStateMixin`.
- It uses a raw `Ticker` (via `createTicker`) to drive updates. Each tick receives an elapsed `Duration`. Particle positions are updated in the ticker callback using wall-clock delta: `deltaMs = (elapsed - _lastElapsed).inMilliseconds`. At 60fps, deltaMs ≈ 16ms. Particle speed in the spec (`0.3–0.7 px/frame`) should be interpreted as `0.3–0.7 px per 16ms`, so multiply by `deltaMs / 16.0` to stay frame-rate independent.
- The ticker callback calls `setState(() {})` after updating particle positions. This triggers `CustomPainter.paint()` on the next frame.
- The `CustomPainter` does **not** use a `repaint` listenable — it relies entirely on `setState` rebuilds from the ticker.
- Inside `paint()`, the painter reads `mouseNotifier.value` directly (a simple field read — no listener). Mouse moves do not trigger extra repaints.

### New Files

| File | Purpose |
|------|---------|
| `lib/core/state/mouse_notifier.dart` | `ValueNotifier<Offset>` typedef + helper; no logic |
| `lib/presentation/widgets/particle_canvas.dart` | `CustomPainter` for particles + grid |
| `lib/presentation/widgets/parallax_rings.dart` | 3 concentric rings with depth motion |
| `lib/presentation/widgets/tilt_card.dart` | Reusable 3D tilt wrapper widget |

### Modified Files

| File | Change |
|------|--------|
| `lib/presentation/pages/home_page.dart` | Column → Stack layout; add global MouseRegion; provide mouseNotifier |
| `lib/presentation/widgets/hero_section.dart` | Add ParticleCanvas, ParallaxRings, glow blob, hero content tilt |
| `lib/presentation/widgets/projects_section.dart` | Remove AnimatedContainer transform; wrap _ProjectCard body in TiltCard |
| `lib/presentation/widgets/skills_section.dart` | Convert _SkillCategory to StatefulWidget; wrap in TiltCard |
| `lib/presentation/widgets/nav_bar.dart` | Add BackdropFilter + glass background |

---

## Mobile / Touch Degradation

All motion effects are mouse-driven and do not fire on touch devices (Flutter's `MouseRegion.onHover` is not triggered by touch). The following per-component behavior applies when no mouse is present:

| Component | Desktop (mouse) | Mobile / touch |
|-----------|-----------------|----------------|
| ParticleCanvas | Particles drift + dodge cursor | Particles drift only (no cursor repulsion) |
| ParallaxRings | Rings shift with mouse | Rings centered, static |
| Hero content tilt | Tilts with mouse | Static, no tilt |
| GlowBlob | Follows cursor | Centered, static |
| TiltCard (project) | Full 3D tilt + shine | No tilt, existing hover border/shadow on tap |
| TiltCard (skill) | Subtle 3D tilt | No tilt |
| NavBar BackdropFilter | Frosted glass | Frosted glass (same — layout-based, not mouse-based) |

No conditional platform code is required for most of these — they simply don't animate when no mouse events fire. The particle drift loop always runs (it's `Ticker`-driven, independent of mouse).

---

## What Does NOT Change

- Portfolio data (names, projects, skills, bio)
- Theme colors (keeping `#10B981` green palette)
- Typewriter animation in hero (`animated_text_kit`)
- Scroll-triggered fade-in animations on sections (`visibility_detector`)
- Contact section and experience section (no 3D effects — keeps page from feeling overwhelming)
- Existing `_isHovered` border/glow logic in project cards is subsumed by `TiltCard`

---

## Success Criteria

- Moving the mouse across the hero creates a clear, dramatic parallax depth effect with visible ring separation
- Hovering a project card produces a visible 3D tilt (≥10°) with light reflection and shadow shift
- Particle canvas runs at smooth 60fps with no jank (verified in Chrome DevTools)
- Effects work in Chrome/Safari/Firefox on Flutter web
- Mobile/tablet shows static particles + no tilt — no errors, no empty sections
- NavBar blurs the scroll content visible behind it
