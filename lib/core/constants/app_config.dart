// App Configuration
// Customize these values to personalize your portfolio
library;

class AppConfig {
  // App Information
  static const String appTitle = 'Shubham Memane - Portfolio';
  static const String logoText = '<SM />';
  
  // SEO & Meta
  static const String metaDescription = 'Full Stack Developer specializing in Flutter, Web, and Mobile development';
  static const String metaKeywords = 'Flutter Developer, Full Stack Developer, Mobile App Developer';
  
  // Social Media
  static const String ogImage = 'assets/images/og-image.png'; // For social media sharing
  
  // Features Toggle
  static const bool enableDarkModeByDefault = true;
  static const bool showEducationSection = true;
  static const bool showExperienceSection = true;
  
  // Animation Settings
  static const int heroAnimationDuration = 800; // milliseconds
  static const int sectionAnimationDuration = 600; // milliseconds
  static const double visibilityThreshold = 0.3; // 0.0 to 1.0
  
  // Layout Settings
  static const double maxContentWidth = 1200;
  static const int mobileBreakpoint = 768;
  static const int tabletBreakpoint = 1024;
}
