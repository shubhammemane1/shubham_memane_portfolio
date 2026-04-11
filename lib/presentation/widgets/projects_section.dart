import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../domain/models/portfolio_data.dart';
import 'project_icon_button.dart';
import 'tilt_card.dart';

class ProjectsSection extends StatefulWidget {
  final List<Project> projects;

  const ProjectsSection({super.key, required this.projects});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('projects-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
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
            Text('Featured Projects', style: Responsive.value(context, mobile: Theme.of(context).textTheme.displaySmall, desktop: Theme.of(context).textTheme.displayMedium)),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.xl,
              alignment: WrapAlignment.center,
              children: widget.projects.asMap().entries.map((entry) {
                return _ProjectCard(project: entry.value, index: entry.key, isVisible: _isVisible);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  final bool isVisible;

  const _ProjectCard({required this.project, required this.index, required this.isVisible});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  Color _gradientStart = AppColors.primary;
  Color _gradientEnd = AppColors.accent;

  @override
  void initState() {
    super.initState();
    final url = widget.project.imageUrl;
    if (url != null && url.startsWith('http')) {
      _extractColors(url);
    }
  }

  Future<void> _extractColors(String url) async {
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        size: const Size(100, 100),
      );
      if (!mounted) return;
      final dominant = generator.dominantColor?.color;
      final muted = generator.mutedColor?.color ?? generator.vibrantColor?.color;
      if (dominant != null) {
        setState(() {
          _gradientStart = dominant;
          _gradientEnd = muted ?? dominant.withValues(alpha: 0.6);
        });
      }
    } catch (_) {}
  }

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
      child: GestureDetector(
        onTap: () => context.go('/project/${widget.project.slug}'),
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
                      _gradientStart.withValues(alpha: 0.85),
                      _gradientEnd.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'project-icon-${widget.project.slug}',
                    child: widget.project.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: widget.project.imageUrl!.startsWith('http')
                                ? Image.network(
                                    widget.project.imageUrl!,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => _buildGradientFallback(),
                                  )
                                : Image.asset(
                                    widget.project.imageUrl!,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => _buildGradientFallback(),
                                  ),
                          )
                        : FaIcon(
                            widget.project.icon ?? FontAwesomeIcons.code,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                  ),
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
                    Text(
                      widget.project.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            tech,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (widget.project.githubUrl != null)
                          ProjectIconButton(
                            icon: FontAwesomeIcons.github,
                            tooltip: 'GitHub',
                            onTap: () => _launchUrl(widget.project.githubUrl!),
                          ),
                        if (widget.project.liveUrl != null)
                          ProjectIconButton(
                            icon: FontAwesomeIcons.arrowUpRightFromSquare,
                            tooltip: 'Live Demo',
                            onTap: () => _launchUrl(widget.project.liveUrl!),
                          ),
                        if (widget.project.playStoreUrl != null)
                          ProjectIconButton(
                            icon: FontAwesomeIcons.googlePlay,
                            tooltip: 'Play Store',
                            onTap: () => _launchUrl(widget.project.playStoreUrl!),
                          ),
                        if (widget.project.appStoreUrl != null)
                          ProjectIconButton(
                            icon: FontAwesomeIcons.appStoreIos,
                            tooltip: 'App Store',
                            onTap: () => _launchUrl(widget.project.appStoreUrl!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildGradientFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gradientStart.withValues(alpha: 0.85),
            _gradientEnd.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: FaIcon(
          widget.project.icon ?? FontAwesomeIcons.code,
          size: 64,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (_) {}
  }
}
