import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../core/theme/app_theme.dart';

/// Shared data class — media_section.dart imports this file (one-way dependency).
class MediaItem {
  final String url;
  final bool isVideo;
  const MediaItem({required this.url, required this.isVideo});
}

void showMediaDialog({
  required BuildContext context,
  required List<MediaItem> items,
  required int initialIndex,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => MediaDialog(items: items, initialIndex: initialIndex),
  );
}

// Intentionally never cleared: platformViewRegistry does not allow re-registering
// the same viewId. Entries persist for the app lifetime (safe — portfolio has few videos).
final _registeredViewIds = <String>{};

void _registerVideoView(String viewId, String url) {
  if (_registeredViewIds.contains(viewId)) return;
  _registeredViewIds.add(viewId);
  ui_web.platformViewRegistry.registerViewFactory(viewId, (_) {
    if (_isYouTube(url)) {
      final videoId = _extractYouTubeId(url) ?? '';
      return html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1'
        ..style.cssText = 'width:100%;height:100%;border:none;'
        ..allowFullscreen = true;
    } else {
      return html.VideoElement()
        ..src = url
        ..controls = true
        ..autoplay = true
        ..style.cssText = 'width:100%;height:100%;background:#000;';
    }
  });
}

bool _isYouTube(String url) =>
    url.contains('youtube.com') || url.contains('youtu.be');

String? _extractYouTubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  return uri.queryParameters['v'];
}

class MediaDialog extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;

  const MediaDialog({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<MediaDialog> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  MediaItem get _current => widget.items[_index];

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  void _next() {
    if (_index < widget.items.length - 1) setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  _current.isVideo
                      ? 'Video'
                      : 'Screenshot ${_index + 1} / ${widget.items.where((i) => !i.isVideo).length}',
                  style: const TextStyle(
                      color: Color(0xFF94a3b8), fontSize: 13),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1e293b),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF94a3b8), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _current.isVideo
                    ? _VideoViewer(url: _current.url)
                    : _ImageViewer(url: _current.url),
              ),
            ),
            if (widget.items.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _index > 0 ? _prev : null,
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.primary,
                    disabledColor: const Color(0xFF334155),
                  ),
                  Text(
                    '${_index + 1} / ${widget.items.length}',
                    style: const TextStyle(
                        color: Color(0xFF64748b), fontSize: 12),
                  ),
                  IconButton(
                    onPressed:
                        _index < widget.items.length - 1 ? _next : null,
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.primary,
                    disabledColor: const Color(0xFF334155),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String url;
  const _ImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.image_not_supported,
            color: AppColors.primary, size: 48),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;
  const _VideoViewer({required this.url});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-${widget.url.hashCode}';
    _registerVideoView(_viewId, widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
