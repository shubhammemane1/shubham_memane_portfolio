// lib/presentation/widgets/hero_section.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/state/mouse_notifier.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../domain/models/portfolio_data.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ParallaxRings(mouseNotifier: mouseNotifier),
          ),
          _GlowBlob(mouseNotifier: mouseNotifier),
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
    return ValueListenableBuilder<Offset>(
      valueListenable: mouseNotifier,
      builder: (context, mouse, _) {
        return IgnorePointer(
          child: Transform.translate(
            offset: Offset(mouse.dx * 150, mouse.dy * 150),
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x2010B981), Colors.transparent],
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
          ..rotateY(mouse.dx * 3 * math.pi / 180)
          ..rotateX(-mouse.dy * 2 * math.pi / 180);
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
                child: Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final nameColor = isDark ? Colors.white : AppColors.lightText;
                    final gradientEnd = isDark
                        ? const Color(0x8810B981)
                        : AppColors.primary;
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [nameColor, gradientEnd],
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
                              ?.copyWith(color: nameColor),
                          desktop: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: nameColor),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
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
                            mobile: Theme.of(context).textTheme.headlineSmall,
                            desktop:
                                Theme.of(context).textTheme.headlineMedium,
                          )?.copyWith(color: AppColors.primary),
                          speed: const Duration(milliseconds: 100),
                        ),
                        TypewriterAnimatedText(
                          'Problem Solver',
                          textStyle: Responsive.value(
                            context,
                            mobile: Theme.of(context).textTheme.headlineSmall,
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
                    shadowColor: AppColors.primary.withValues(alpha: 0.5),
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
