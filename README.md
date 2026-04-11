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
│   ├── constants/        # Portfolio data
│   ├── theme/           # Design system (colors, typography, spacing)
│   └── utils/           # Utilities (responsive helper)
├── domain/
│   └── models/          # Data models
└── presentation/
    ├── pages/           # Main pages
    └── widgets/         # Reusable UI components
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

Edit `lib/core/constants/portfolio_data.dart`:

```dart
final portfolioData = PortfolioData(
  personalInfo: PersonalInfo(
    name: 'Your Name',
    title: 'Your Title',
    bio: 'Your bio...',
  ),
  skills: [
    Skill(name: 'Flutter', category: 'Mobile', proficiency: 0.9),
    // Add your skills
  ],
  projects: [
    Project(
      title: 'Your Project',
      description: 'Description...',
      technologies: ['Flutter', 'Firebase'],
      githubUrl: 'https://github.com/...',
    ),
    // Add your projects
  ],
  experiences: [
    Experience(
      company: 'Company Name',
      position: 'Your Position',
      duration: '2020 - Present',
      description: 'What you did...',
    ),
    // Add your experiences
  ],
  education: [
    Education(
      institution: 'University',
      degree: 'Your Degree',
      duration: '2016 - 2020',
    ),
  ],
  contactInfo: ContactInfo(
    email: 'your@email.com',
    github: 'https://github.com/yourusername',
    linkedin: 'https://linkedin.com/in/yourusername',
  ),
);
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

1. **Hero Section** - Animated introduction with typewriter effect
2. **Skills Section** - Categorized skills with animated progress bars
3. **Projects Section** - Project cards with hover effects
4. **Experience Section** - Timeline-style experience display
5. **Contact Section** - Social links with hover animations

## 🛠️ Tech Stack

- **Flutter** - UI framework
- **Google Fonts** - Typography
- **Font Awesome** - Icons
- **Animated Text Kit** - Text animations
- **Visibility Detector** - Scroll animations
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
