import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'media_dialog.dart';

class MediaSection extends StatelessWidget {
  final List<String> screenshots;
  final List<String> videos;

  const MediaSection({
    super.key,
    required this.screenshots,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final allMedia = [
      ...screenshots.map((url) => MediaItem(url: url, isVideo: false)),
      ...videos.map((url) => MediaItem(url: url, isVideo: true)),
    ];

    if (allMedia.isEmpty) return const SizedBox.shrink();

    final title = videos.isEmpty ? 'Screenshots' : 'Screenshots & Videos';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 450,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allMedia.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) => _MediaThumb(
                item: allMedia[index],
                onTap: () => showMediaDialog(
                  context: context,
                  items: allMedia,
                  initialIndex: index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _MediaThumb({required this.item, required this.onTap});

  String get _posterUrl {
    if (!item.isVideo) return item.url;
    final videoId = _extractYouTubeId(item.url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return '';
  }

  static String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
    return uri.queryParameters['v'];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 260,
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _posterUrl.isNotEmpty
                  ? Image.network(
                      _posterUrl,
                      width: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _placeholderBox(),
                    )
                  : _placeholderBox(),
              if (item.isVideo) ...[
                Container(color: Colors.black45),
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 30),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('VIDEO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
        width: 260,
        height: 450,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          item.isVideo ? Icons.play_circle_outline : Icons.image_not_supported,
          color: AppColors.primary,
          size: 48,
        ),
      );
}
