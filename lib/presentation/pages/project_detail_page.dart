import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/portfolio_data.dart';
import '../widgets/media_section.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Color _gradientStart = AppColors.secondary;

  static const _fakeStats = <String, (String, String, String)>{
    'riise':                       ('Finance',      '500K+', '4.7'),
    'mo-private-wealth':           ('Finance',      '50K+',  '4.5'),
    'mo-trader':                   ('Finance',      '100K+', '4.8'),
    'weather-app':                 ('Weather',      '30K+',  '4.6'),
    'torus-banking-trading-demat': ('Finance',      '80K+',  '4.9'),
  };

  (String, String, String) get _stats {
    final fake = _fakeStats[widget.project.slug] ?? ('Utility', '10K+', '4.5');
    final rating = widget.project.rating != null
        ? widget.project.rating!.toStringAsFixed(1)
        : fake.$3;
    final downloads = widget.project.downloads ?? fake.$2;
    return (fake.$1, downloads, rating);
  }

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
          _gradientStart = muted ?? dominant;
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
            _EditorialHero(
              project: widget.project,
              tintColor: _gradientStart,
              category: category,
              downloads: downloads,
              rating: rating,
            ),
            _LinksBar(project: widget.project, onLaunch: _launch),
            if (widget.project.screenshots.isNotEmpty || widget.project.videos.isNotEmpty)
              MediaSection(
                screenshots: widget.project.screenshots,
                videos: widget.project.videos,
              ),
            _QuoteSection(text: widget.project.description),
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

class _EditorialHero extends StatelessWidget {
  final Project project;
  final Color tintColor;
  final String category;
  final String downloads;
  final String rating;

  const _EditorialHero({
    required this.project,
    required this.tintColor,
    required this.category,
    required this.downloads,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 440,
      color: AppColors.darkSurface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Hero(
              tag: 'project-icon-${project.slug}',
              child: project.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: project.imageUrl!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: project.imageUrl!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  _IconFallback(icon: project.icon),
                            )
                          : Image.asset(
                              project.imageUrl!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _IconFallback(icon: project.icon),
                            ),
                    )
                  : _IconFallback(icon: project.icon),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tintColor.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.85],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.xl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CASE STUDY · ${category.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _MetaStat(value: downloads, label: 'downloads'),
                      const SizedBox(width: AppSpacing.xl),
                      _MetaStat(value: rating, label: 'rating'),
                      const SizedBox(width: AppSpacing.xl),
                      _MetaStat(value: category, label: 'category'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaStat extends StatelessWidget {
  final String value;
  final String label;
  const _MetaStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _IconFallback extends StatelessWidget {
  final FaIconData? icon;
  const _IconFallback({this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Center(
        child: FaIcon(
          icon ?? FontAwesomeIcons.code,
          size: 72,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _LinksBar extends StatelessWidget {
  final Project project;
  final void Function(String) onLaunch;

  const _LinksBar({required this.project, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final links = <(String, String)>[
      if (project.githubUrl != null) ('GitHub', project.githubUrl!),
      if (project.liveUrl != null) ('Live Demo', project.liveUrl!),
      if (project.playStoreUrl != null) ('Play Store', project.playStoreUrl!),
      if (project.appStoreUrl != null) ('App Store', project.appStoreUrl!),
    ];
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < links.length; i++) ...[
            if (i > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('·',
                    style: TextStyle(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        fontSize: 14)),
              ),
            _LinkText(
              label: links[i].$1,
              onTap: () => onLaunch(links[i].$2),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LinkText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _QuoteSection extends StatelessWidget {
  final String text;
  const _QuoteSection({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.secondary, width: 3),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily:
                    Theme.of(context).textTheme.headlineSmall?.fontFamily,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                height: 1.6,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
        ),
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
          Text('About',
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
          Text('TECHNOLOGIES',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: technologies.map((tech) {
              return RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 13),
                  children: [
                    TextSpan(
                        text: '[ ',
                        style: TextStyle(
                            color: AppColors.secondary.withValues(alpha: 0.4))),
                    TextSpan(
                        text: tech,
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: ' ]',
                        style: TextStyle(
                            color: AppColors.secondary.withValues(alpha: 0.4))),
                  ],
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
