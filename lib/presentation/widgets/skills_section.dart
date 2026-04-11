import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../domain/models/portfolio_data.dart';
import 'tilt_card.dart';

class SkillsSection extends StatefulWidget {
  final List<Skill> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final groupedSkills = <String, List<Skill>>{};
    for (var skill in widget.skills) {
      groupedSkills.putIfAbsent(skill.category, () => []).add(skill);
    }

    return VisibilityDetector(
      key: const Key('skills-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.value(context, mobile: AppSpacing.lg, desktop: AppSpacing.xxxl),
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          children: [
            Text('Skills & Expertise', style: Responsive.value(context, mobile: Theme.of(context).textTheme.displaySmall, desktop: Theme.of(context).textTheme.displayMedium)),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.xl,
              alignment: WrapAlignment.center,
              children: groupedSkills.entries.map((entry) {
                return _SkillCategory(
                  category: entry.key,
                  skills: entry.value,
                  isVisible: _isVisible,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCategory extends StatefulWidget {
  final String category;
  final List<Skill> skills;
  final bool isVisible;

  const _SkillCategory({
    required this.category,
    required this.skills,
    required this.isVisible,
  });

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
            Text(
              widget.category,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
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
                              backgroundColor:
                                  Theme.of(context).brightness ==
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
