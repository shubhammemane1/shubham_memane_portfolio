# Portfolio Project Context & Session History

## Project Overview
**Project Name**: Shubham Memane Portfolio  
**Type**: Flutter Web Portfolio  
**Architecture**: Clean Architecture with Design System  
**Created**: 2024  
**Status**: Active Development

---

## Project Structure

```
shubhammemaneportfolio/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_config.dart          # App configuration settings
│   │   ├── router/
│   │   │   └── app_router.dart          # go_router: / and /project/:slug
│   │   ├── services/
│   │   │   └── portfolio_service.dart   # Loads assets/data/portfolio.json
│   │   ├── state/
│   │   │   └── mouse_notifier.dart      # Mouse position for tilt/parallax
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Design system & theme
│   │   └── utils/
│   │       └── responsive.dart          # Responsive breakpoints helper
│   ├── domain/
│   │   └── models/
│   │       └── portfolio_data.dart      # Data models (fromJson support)
│   └── presentation/
│       ├── pages/
│       │   ├── home_page.dart           # Main scrollable page
│       │   └── project_detail_page.dart # /project/:slug — full detail view
│       └── widgets/
│           ├── nav_bar.dart             # Top navigation bar
│           ├── hero_section.dart        # Animated intro + typewriter
│           ├── particle_canvas.dart     # Canvas particle background
│           ├── parallax_rings.dart      # Mouse-reactive ring decorations
│           ├── skills_section.dart      # Skills with progress bars
│           ├── projects_section.dart    # Project cards grid
│           ├── tilt_card.dart           # 3D tilt card on mouse move
│           ├── project_icon_button.dart # GitHub/live/store icon button
│           ├── media_section.dart       # Image + YouTube thumbnail grid
│           ├── media_dialog.dart        # Full-screen media viewer dialog
│           ├── experience_section.dart  # Timeline work history
│           └── contact_section.dart     # Social links
├── assets/
│   ├── data/
│   │   └── portfolio.json              # All portfolio content (edit here)
│   └── images/                         # Image assets
├── web/                                # Web configuration
├── pubspec.yaml                        # Dependencies
├── README.md                           # Documentation
├── CUSTOMIZATION.md                    # Customization guide
└── PROJECT_CONTEXT.md                  # This file
```

---

## Design System Configuration

### Color Scheme (Current)
```dart
// Primary Colors
primary: Color(0xFF10B981)      // Green
secondary: Color(0xFF14B8A6)    // Teal
accent: Color(0xFF06B6D4)       // Cyan

// Light Mode
lightBackground: Color(0xFFFAFAFA)
lightSurface: Color(0xFFFFFFFF)
lightText: Color(0xFF1F2937)
lightTextSecondary: Color(0xFF6B7280)

// Dark Mode (Pure Black Theme)
darkBackground: Color(0xFF000000)    // Pure Black
darkSurface: Color(0xFF0F0F0F)       // Dark Gray
darkText: Color(0xFFFFFFFF)          // White
darkTextSecondary: Color(0xFFB0B0B0) // Light Gray

// Semantic Colors
success: Color(0xFF10B981)
warning: Color(0xFFF59E0B)
error: Color(0xFFEF4444)
```

### Typography
- **Display Fonts**: Poppins (Bold, 48-72px)
- **Heading Fonts**: Poppins (Semi-bold, 24-40px)
- **Body Fonts**: Inter (Regular/Medium, 14-20px)

### Spacing Scale
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px
- xxxl: 64px

### Border Radius
- sm: 8px
- md: 12px
- lg: 16px
- xl: 24px
- full: 9999px

### Responsive Breakpoints
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

---

## Customizations Applied

### Session 1 - Initial Setup
1. ✅ Created complete Flutter web portfolio with clean architecture
2. ✅ Implemented design system with consistent colors, typography, spacing
3. ✅ Added responsive layout for mobile, tablet, desktop
4. ✅ Integrated animations (scroll animations, hover effects, typewriter)
5. ✅ Created all sections: Hero, Skills, Projects, Experience, Contact
6. ✅ Added dark/light mode toggle

### Session 2 - Color Customizations
1. ✅ Changed dark mode to pure black background (#000000)
2. ✅ Changed secondary color from purple to teal (#14B8A6)
3. ✅ Changed primary color from purple/indigo to green (#10B981)
4. ✅ Updated project card gradient to use green → cyan instead of green → teal

### Session 3 - 3D Motion & Visual Effects
1. ✅ Added particle canvas background to Hero section
2. ✅ Added mouse-reactive parallax rings decoration
3. ✅ Added 3D tilt card effect on project cards
4. ✅ Added `mouse_notifier.dart` for global mouse position state

### Session 4 - Project Detail Page & Routing
1. ✅ Added `go_router` for client-side routing
2. ✅ Created `ProjectDetailPage` at `/project/:slug`
3. ✅ Added `slug` field to `Project` model
4. ✅ Added `longDescription`, `rating`, `downloads`, `media` fields
5. ✅ Added `ProjectIconButton` for store/GitHub/live links
6. ✅ Migrated portfolio data from Dart constants → `assets/data/portfolio.json`
7. ✅ Created `PortfolioService` for async JSON loading

### Session 5 - Media Viewer
1. ✅ Added `MediaSection` widget with image + YouTube thumbnail grid
2. ✅ Added `MediaDialog` full-screen viewer (images + YouTube embed)
3. ✅ Deduplicated `extractYouTubeId`, use URL-based `viewId`

---

## Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1              # Typography
  url_launcher: ^6.3.1              # External links
  font_awesome_flutter: ^10.7.0     # Icons
  animated_text_kit: ^4.3.0         # Text animations
  visibility_detector: ^0.4.0+2     # Scroll animations
  palette_generator: ^0.3.3         # Dynamic color from images
  go_router: ^14.0.0                # Client-side routing
```

---

## Features Implemented

### 1. Navigation Bar
- Responsive navigation with logo
- Dark/light mode toggle
- Smooth hover effects
- Mobile-friendly

### 2. Hero Section
- Animated fade-in and slide-up effects
- Typewriter effect for job titles
- Particle canvas background
- Mouse-reactive parallax rings
- Call-to-action button

### 3. Skills Section
- Skills grouped by category
- Animated progress bars
- Scroll-triggered animations
- Responsive card layout

### 4. Projects Section
- 3D tilt cards on mouse hover
- Gradient backgrounds (green → cyan)
- Rating stars + download count display
- Technology tags
- GitHub / Play Store / App Store / live demo icon buttons
- Click opens `/project/:slug` detail page
- Responsive grid layout

### 5. Project Detail Page
- Full `longDescription`
- Media gallery: image thumbnails + YouTube embeds
- Full-screen media viewer dialog
- Technology tags
- Back navigation via go_router

### 6. Experience Section
- Timeline-style layout
- Animated on scroll
- Company, position, duration, description
- Responsive design

### 7. Contact Section
- Social media links (Email, GitHub, LinkedIn, Twitter)
- Hover animations
- Icon buttons with Font Awesome
- URL launcher integration

### 8. Theme System
- Light and dark mode support
- Pure black dark mode for OLED screens
- Smooth theme transitions
- Consistent color palette

### 9. Data Layer
- All content in `assets/data/portfolio.json`
- `PortfolioService.load()` reads + parses JSON at startup
- `PortfolioData.fromJson()` on all models
- Projects identified by `slug` for routing

---

## Portfolio Data Structure

### Personal Info
```dart
PersonalInfo(
  name: String,
  title: String,
  bio: String,
  imageUrl: String? (optional)
)
```

### Skills
```dart
Skill(
  name: String,
  category: String,  // Mobile, Web, Backend, Language, Tools, Design
  proficiency: double  // 0.0 to 1.0
)
```

### Projects
```dart
Project(
  title: String,
  description: String,
  technologies: List<String>,
  imageUrl: String? (optional),
  liveUrl: String? (optional),
  githubUrl: String? (optional)
)
```

### Experience
```dart
Experience(
  company: String,
  position: String,
  duration: String,
  description: String
)
```

### Education
```dart
Education(
  institution: String,
  degree: String,
  duration: String
)
```

### Contact Info
```dart
ContactInfo(
  email: String,
  phone: String? (optional),
  github: String? (optional),
  linkedin: String? (optional),
  twitter: String? (optional),
  website: String? (optional)
)
```

---

## Current Configuration

### App Settings
- **Default Theme**: Dark Mode
- **Logo Text**: `<SM />`
- **App Title**: "Shubham Memane - Portfolio"

### Personal Information (Sample Data)
- **Name**: Shubham Memane
- **Title**: Full Stack Developer
- **Email**: shubham@example.com
- **GitHub**: https://github.com/shubhammemane
- **LinkedIn**: https://linkedin.com/in/shubhammemane

---

## Known Issues & Notes

### Deprecation Warnings (Non-Critical)
- `withOpacity()` method has deprecation warnings
- These are info-level warnings and don't affect functionality
- Can be updated to `withValues()` in future if needed

### White Screen Issue
- If white screen appears, check:
  1. All imports are correct
  2. `flutter pub get` has been run
  3. Browser cache is cleared
  4. Check browser console for errors

---

## How to Use This File

### For Future Sessions
1. Share this file with the AI assistant
2. AI will understand all customizations made
3. Continue from where you left off
4. Update this file with new changes

### For Customization
1. Refer to "Customizations Applied" section
2. Check "Design System Configuration" for current colors
3. See "Portfolio Data Structure" for data format
4. Use CUSTOMIZATION.md for step-by-step guide

---

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Build for production
flutter build web

# Analyze code
flutter analyze

# Check Flutter setup
flutter doctor
```

---

## Next Steps / TODO

### Potential Enhancements
- [ ] Add actual project images
- [ ] Add profile photo
- [ ] Implement smooth scroll to sections
- [ ] Add contact form
- [ ] Add blog section
- [ ] Add testimonials section
- [ ] Add resume download button
- [ ] Implement SEO optimization
- [ ] Add loading animations
- [ ] Add 404 page
- [ ] Implement analytics

### Deployment Options
- [ ] Firebase Hosting
- [ ] GitHub Pages
- [ ] Netlify
- [ ] Vercel

---

## File Modification History

### lib/core/theme/app_theme.dart
- Changed primary color to green (#10B981)
- Changed secondary color to teal (#14B8A6)
- Changed dark mode to pure black (#000000)
- Updated dark surface to #0F0F0F
- Updated dark text colors

### lib/presentation/widgets/projects_section.dart
- Changed gradient from green-teal to green-cyan
- Uses AppColors.primary and AppColors.accent

### lib/core/constants/app_config.dart
- Fixed dangling library doc comment

### assets/data/portfolio.json
- All portfolio content (personal info, skills, projects, experience, education, contact)
- Projects include: slug, longDescription, rating, downloads, media array
- Media items: `{ "type": "image"|"youtube", "url": "...", "caption": "..." }`

### lib/domain/models/portfolio_data.dart
- All models have `fromJson` factory constructors
- `Project.slug` used for routing

### lib/core/router/app_router.dart
- Routes: `/` → HomePage, `/project/:slug` → ProjectDetailPage

### lib/core/services/portfolio_service.dart
- `PortfolioService.load()` — async loads + parses JSON from assets

---

## Contact & Support

For questions about this project:
1. Check README.md for general documentation
2. Check CUSTOMIZATION.md for customization guide
3. Review code comments in individual files
4. Check Flutter documentation: https://flutter.dev

---

**Last Updated**: 2026-04-17  
**Version**: 1.5.0  
**Maintained By**: Shubham Memane

---

## Session Notes

### Session Summary
- Created complete Flutter web portfolio from scratch
- Implemented clean architecture with separation of concerns
- Added comprehensive design system
- Implemented all major sections with animations
- Customized color scheme to green/teal/cyan
- Implemented pure black dark mode
- Fixed all import issues
- Ready for customization and deployment

### Key Decisions Made
1. Used clean architecture for maintainability
2. Chose green as primary color for fresh, modern look
3. Implemented pure black dark mode for OLED optimization
4. Used Google Fonts (Poppins + Inter) for professional typography
5. Implemented scroll-triggered animations for engagement
6. Made fully responsive with mobile-first approach

---

**End of Context File**
