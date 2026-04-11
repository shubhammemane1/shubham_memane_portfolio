# 🚀 Quick Customization Guide

## Step 1: Update Your Personal Information

Open `lib/core/constants/portfolio_data.dart` and update:

### Personal Info
```dart
personalInfo: PersonalInfo(
  name: 'Your Full Name',
  title: 'Your Job Title (e.g., Flutter Developer)',
  bio: 'Write a brief bio about yourself...',
),
```

### Skills
```dart
skills: [
  Skill(name: 'Skill Name', category: 'Category', proficiency: 0.9), // 0.0 to 1.0
  // Add more skills
],
```

Categories: 'Mobile', 'Web', 'Backend', 'Language', 'Tools', 'Design', etc.

### Projects
```dart
projects: [
  Project(
    title: 'Project Name',
    description: 'Brief description of your project',
    technologies: ['Tech1', 'Tech2', 'Tech3'],
    githubUrl: 'https://github.com/username/repo',
    liveUrl: 'https://yourproject.com', // Optional
  ),
],
```

### Experience
```dart
experiences: [
  Experience(
    company: 'Company Name',
    position: 'Your Position',
    duration: '2020 - Present',
    description: 'What you accomplished in this role...',
  ),
],
```

### Education
```dart
education: [
  Education(
    institution: 'University/College Name',
    degree: 'Degree Name',
    duration: '2016 - 2020',
  ),
],
```

### Contact Info
```dart
contactInfo: ContactInfo(
  email: 'your.email@example.com',
  phone: '+91 1234567890', // Optional
  github: 'https://github.com/yourusername',
  linkedin: 'https://linkedin.com/in/yourusername',
  twitter: 'https://twitter.com/yourusername', // Optional
),
```

## Step 2: Customize Colors (Optional)

Open `lib/core/theme/app_theme.dart`:

```dart
class AppColors {
  static const primary = Color(0xFF6366F1);    // Main brand color
  static const secondary = Color(0xFF8B5CF6);  // Secondary accent
  static const accent = Color(0xFF06B6D4);     // Additional accent
}
```

Popular color schemes:
- **Blue/Purple**: `0xFF6366F1` / `0xFF8B5CF6` (Current)
- **Green/Teal**: `0xFF10B981` / `0xFF06B6D4`
- **Orange/Red**: `0xFFF59E0B` / `0xFFEF4444`
- **Pink/Purple**: `0xFFEC4899` / `0xFF8B5CF6`

## Step 3: Update Logo

Open `lib/presentation/widgets/nav_bar.dart` and find:

```dart
Text(
  '<SM />',  // Change to your initials or logo text
  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  ),
),
```

## Step 4: Add Images (Optional)

1. Add images to `assets/images/` folder
2. Update `portfolio_data.dart`:
   ```dart
   imageUrl: 'assets/images/your-photo.png'
   ```

## Step 5: Run Your Portfolio

```bash
flutter run -d chrome
```

## 🎨 Design System Reference

### Spacing
- `AppSpacing.xs` = 4px
- `AppSpacing.sm` = 8px
- `AppSpacing.md` = 16px
- `AppSpacing.lg` = 24px
- `AppSpacing.xl` = 32px
- `AppSpacing.xxl` = 48px
- `AppSpacing.xxxl` = 64px

### Border Radius
- `AppRadius.sm` = 8px
- `AppRadius.md` = 12px
- `AppRadius.lg` = 16px
- `AppRadius.xl` = 24px

### Colors
- `AppColors.primary` - Main brand color
- `AppColors.secondary` - Secondary accent
- `AppColors.success` - Success states
- `AppColors.warning` - Warning states
- `AppColors.error` - Error states

## 🚀 Deploy Your Portfolio

### Option 1: Firebase Hosting (Recommended)
```bash
flutter build web
firebase init hosting
firebase deploy
```

### Option 2: GitHub Pages
```bash
flutter build web --base-href "/repository-name/"
# Push build/web to gh-pages branch
```

### Option 3: Netlify
```bash
flutter build web
# Drag build/web folder to Netlify
```

## 💡 Tips

1. **Keep it concise** - Quality over quantity in projects and experience
2. **Use real data** - Replace all placeholder data with your actual information
3. **Test responsiveness** - Check on mobile, tablet, and desktop
4. **Optimize images** - Compress images before adding to assets
5. **Update regularly** - Keep your portfolio current with new projects

## 🆘 Need Help?

- Check the main README.md for detailed documentation
- Review the code comments in each file
- Test changes incrementally with hot reload

---

**Happy Customizing! 🎉**
