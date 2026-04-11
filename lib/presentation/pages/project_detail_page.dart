import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/portfolio_data.dart';
import '../widgets/project_icon_button.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Color _gradientStart = AppColors.primary;
  Color _gradientEnd = AppColors.accent;

  static const _fakeStats = <String, (String, String, String)>{
    'e-commerce-app':              ('Shopping',     '50K+',  '4.7'),
    'task-management-system':      ('Productivity', '20K+',  '4.5'),
    'mo-trader':                   ('Finance',      '100K+', '4.8'),
    'weather-app':                 ('Weather',      '30K+',  '4.6'),
    'torus-banking-trading-demat': ('Finance',      '80K+',  '4.9'),
  };

  (String, String, String) get _stats =>
      _fakeStats[widget.project.slug] ?? ('Utility', '10K+', '4.5');

  @override
  void initState() {
    super.initState();
    final url = widget.project.imageUrl;
    if (url != null && url.startsWith('http')) _extractColors(url);
  }

  Future<void> _extractColors(String url) async {
    try {
      final gen = await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        size: const Size(100, 100),
      );
      if (!mounted) return;
      final dominant = gen.dominantColor?.color;
      final muted = gen.mutedColor?.color ?? gen.vibrantColor?.color;
      if (dominant != null) {
        setState(() {
          _gradientStart = dominant;
          _gradientEnd = muted ?? dominant.withValues(alpha: 0.6);
        });
      }
    } catch (_) {}
  }

  Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (category, downloads, rating) = _stats;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              project: widget.project,
              gradientStart: _gradientStart,
              gradientEnd: _gradientEnd,
            ),
            _ActionBar(
              project: widget.project,
              category: category,
              downloads: downloads,
              rating: rating,
              onLaunch: _launch,
            ),
            if (widget.project.screenshots.isNotEmpty)
              _ScreenshotsSection(screenshots: widget.project.screenshots),
            _AboutSection(
              text: widget.project.longDescription ?? widget.project.description,
            ),
            _TechSection(technologies: widget.project.technologies),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Project project;
  final Color gradientStart;
  final Color gradientEnd;

  const _Header({
    required this.project,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientStart.withValues(alpha: 0.9),
            gradientEnd.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'project-icon-${project.slug}',
                  child: project.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: project.imageUrl!.startsWith('http')
                              ? Image.network(
                                  project.imageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _IconFallback(icon: project.icon),
                                )
                              : Image.asset(
                                  project.imageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _IconFallback(icon: project.icon),
                                ),
                        )
                      : _IconFallback(icon: project.icon),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                  child: Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconFallback extends StatelessWidget {
  final IconData? icon;
  const _IconFallback({this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Center(
        child: FaIcon(
          icon ?? FontAwesomeIcons.code,
          size: 48,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Project project;
  final String category;
  final String downloads;
  final String rating;
  final void Function(String) onLaunch;

  const _ActionBar({
    required this.project,
    required this.category,
    required this.downloads,
    required this.rating,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          if (project.githubUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.github,
              tooltip: 'GitHub',
              onTap: () => onLaunch(project.githubUrl!),
            ),
          if (project.liveUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.arrowUpRightFromSquare,
              tooltip: 'Live Demo',
              onTap: () => onLaunch(project.liveUrl!),
            ),
          if (project.playStoreUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.googlePlay,
              tooltip: 'Play Store',
              onTap: () => onLaunch(project.playStoreUrl!),
            ),
          if (project.appStoreUrl != null)
            ProjectIconButton(
              icon: FontAwesomeIcons.appStoreIos,
              tooltip: 'App Store',
              onTap: () => onLaunch(project.appStoreUrl!),
            ),
          _StatChip(label: '$rating ★'),
          _StatChip(label: downloads),
          _StatChip(label: category),
        ],
      ),
    );
  }
}

class _ScreenshotsSection extends StatelessWidget {
  final List<String> screenshots;
  const _ScreenshotsSection({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Screenshots',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: screenshots.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  screenshots[index],
                  width: 130,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 130,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String text;
  const _AboutSection({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this project',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _TechSection extends StatelessWidget {
  final List<String> technologies;
  const _TechSection({required this.technologies});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Technologies',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: technologies.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
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
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxxl, horizontal: AppSpacing.lg),
      child: Center(
        child: TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to Portfolio'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
