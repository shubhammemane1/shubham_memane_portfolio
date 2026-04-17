# Shubham Memane Portfolio

A fully responsive, modern Flutter web portfolio with clean architecture, design system, and smooth animations.

## ✨ Features

- 🎨 **Modern Design System** - Consistent colors, typography, and spacing
- 🌓 **Dark/Light Mode** - Toggle between themes with smooth transitions
- 📱 **Fully Responsive** - Works perfectly on mobile, tablet, and desktop
- ⚡ **Smooth Animations** - Engaging scroll animations and hover effects
- 🏗️ **Clean Architecture** - Organized code structure with separation of concerns
- 🎯 **Customizable** - Easy to update with your own information
- 🚀 **Performance Optimized** - Fast loading and smooth scrolling

## 🏛️ Architecture

```
lib/
├── core/
│   ├── constants/        # App configuration
│   ├── router/           # go_router setup (/, /project/:slug)
│   ├── services/         # PortfolioService (loads JSON asset)
│   ├── state/            # Mouse position notifier
│   ├── theme/            # Design system (colors, typography, spacing)
│   └── utils/            # Responsive helper
├── domain/
│   └── models/           # Data models (PortfolioData, Project, Skill…)
└── presentation/
    ├── pages/            # HomePage, ProjectDetailPage
    └── widgets/          # UI components (see Sections below)

assets/
├── data/
│   └── portfolio.json    # All portfolio content (edit here)
└── images/               # Image assets
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.11.0 or higher)
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

## 🎨 Customization

### 1. Update Your Information

Edit `assets/data/portfolio.json` — all portfolio content lives here:

```json
{
  "personalInfo": {
    "name": "Your Name",
    "title": "Your Title",
    "bio": "Your bio..."
  },
  "skills": [
    { "name": "Flutter", "category": "Mobile", "proficiency": 0.9 }
  ],
  "projects": [
    {
      "title": "Your Project",
      "slug": "your-project",
      "description": "Short description",
      "longDescription": "Full detail page description",
      "technologies": ["Flutter", "Firebase"],
      "githubUrl": "https://github.com/...",
      "liveUrl": "https://...",
      "rating": 4.5,
      "downloads": "10K+",
      "media": [
        { "type": "image", "url": "assets/images/screenshot.png", "caption": "Home screen" }
      ]
    }
  ],
  "experiences": [
    {
      "company": "Company Name",
      "position": "Your Position",
      "duration": "2020 - Present",
      "description": "What you did..."
    }
  ],
  "education": [
    { "institution": "University", "degree": "Your Degree", "duration": "2016 - 2020" }
  ],
  "contactInfo": {
    "email": "your@email.com",
    "github": "https://github.com/yourusername",
    "linkedin": "https://linkedin.com/in/yourusername"
  }
}
```

### 2. Customize Colors

Edit `lib/core/theme/app_theme.dart`:

```dart
class AppColors {
  static const primary = Color(0xFF6366F1);    // Change primary color
  static const secondary = Color(0xFF8B5CF6);  // Change secondary color
  // ... customize other colors
}
```

### 3. Add Your Images

1. Place images in `assets/images/`
2. Update image paths in `portfolio_data.dart`:
   ```dart
   imageUrl: 'assets/images/your-image.png'
   ```

### 4. Customize Logo

Edit the logo in `lib/presentation/widgets/nav_bar.dart`:

```dart
Text(
  'YourLogo',  // Change this
  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  ),
),
```

## 📱 Responsive Breakpoints

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

## 🎭 Sections

1. **Hero Section** - Animated intro with typewriter effect and particle canvas
2. **Skills Section** - Categorized skills with animated progress bars
3. **Projects Section** - Tilt cards with hover effects, rating, downloads; click → detail page
4. **Project Detail Page** - Full description, media gallery (images + YouTube), tech tags
5. **Experience Section** - Timeline-style work history
6. **Contact Section** - Social links with hover animations

## 🛠️ Tech Stack

- **Flutter** - UI framework
- **go_router** - Client-side routing (`/`, `/project/:slug`)
- **Google Fonts** - Typography (Poppins + Inter)
- **Font Awesome** - Icons
- **Animated Text Kit** - Typewriter animations
- **Visibility Detector** - Scroll-triggered animations
- **Palette Generator** - Dynamic color extraction from images
- **URL Launcher** - External links

## 🌐 Deployment

### Deploy to Firebase Hosting

1. Build for web:
   ```bash
   flutter build web
   ```

2. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

3. Initialize Firebase:
   ```bash
   firebase init hosting
   ```

4. Deploy:
   ```bash
   firebase deploy
   ```

### Deploy to GitHub Pages

1. Build for web:
   ```bash
   flutter build web --base-href "/your-repo-name/"
   ```

2. Push `build/web` contents to `gh-pages` branch

### Deploy to Netlify

1. Build for web:
   ```bash
   flutter build web
   ```

2. Drag and drop `build/web` folder to Netlify

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Feel free to fork this project and customize it for your own portfolio!

## 📧 Contact

For questions or feedback, reach out via the contact section on the portfolio.

---

**Built with ❤️ using Flutter**
