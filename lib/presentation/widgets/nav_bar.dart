import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback onAbout;
  final VoidCallback onSkills;
  final VoidCallback onProjects;
  final VoidCallback onExperience;
  final VoidCallback onContact;

  const NavBar({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onAbout,
    required this.onSkills,
    required this.onProjects,
    required this.onExperience,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.value(context, mobile: AppSpacing.lg, desktop: AppSpacing.xxxl),
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0x99000000)  // black 60% in dark
                : const Color(0xCCFFFFFF), // white 80% in light
            border: const Border(
              bottom: BorderSide(color: Color(0x1A10B981), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.laptopCode, size: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'SM',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              if (Responsive.isDesktop(context))
                Row(
                  children: [
                    _NavItem(label: 'About', onTap: onAbout),
                    _NavItem(label: 'Skills', onTap: onSkills),
                    _NavItem(label: 'Projects', onTap: onProjects),
                    _NavItem(label: 'Experience', onTap: onExperience),
                    _NavItem(label: 'Contact', onTap: onContact),
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

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isHovered ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isDark;

  const _ThemeToggle({required this.onToggle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: AppColors.primary,
        ),
      ),
    );
  }
}
