import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
// Conditional imports: use stub on non-web platforms, real libs on web
import '../../stubs/dart_html_stub.dart' as html
    if (dart.library.html) 'dart:html';
import '../../stubs/dart_ui_web_stub.dart' as ui_web
    if (dart.library.html) 'dart:ui_web';
import '../../core/theme/app_theme.dart';

// ─── Change this to switch popup style ───────────────────────────────────────
const kMediaPopupStyle = MediaPopupStyle.immersive;

enum MediaPopupStyle {
  /// Full image fills popup. Floating arrows + dot indicator. No header chrome.
  immersive,

  /// Header with counter, main image, thumbnail strip at bottom for quick jump.
  galleryStrip,

  /// Counter pill top-left, image with contain fit, prev/next + dots in footer.
  minimal,
}

// ─── Shared data class ────────────────────────────────────────────────────────

/// Shared data class — media_section.dart imports this file (one-way dependency).
class MediaItem {
  final String url;
  final bool isVideo;
  const MediaItem({required this.url, required this.isVideo});
}

// ─── Entry point ─────────────────────────────────────────────────────────────

void showMediaDialog({
  required BuildContext context,
  required List<MediaItem> items,
  required int initialIndex,
  MediaPopupStyle style = kMediaPopupStyle,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) =>
        MediaDialog(items: items, initialIndex: initialIndex, style: style),
  );
}

// ─── Video registration ───────────────────────────────────────────────────────

// Intentionally never cleared: platformViewRegistry does not allow re-registering
// the same viewId. Entries persist for the app lifetime (safe — portfolio has few videos).
final _registeredViewIds = <String>{};

void _registerVideoView(String viewId, String url) {
  if (!kIsWeb) return; // Only register on web platform
  if (_registeredViewIds.contains(viewId)) return;
  _registeredViewIds.add(viewId);
  ui_web.platformViewRegistry.registerViewFactory(viewId, (_) {
    if (_isYouTube(url)) {
      final videoId = extractYouTubeId(url) ?? '';
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

String? extractYouTubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  return uri.queryParameters['v'];
}

String _posterUrl(MediaItem item) {
  if (!item.isVideo) return item.url;
  final id = extractYouTubeId(item.url);
  return id != null ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : '';
}

// ─── Dialog ───────────────────────────────────────────────────────────────────

class MediaDialog extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;
  final MediaPopupStyle style;

  const MediaDialog({
    super.key,
    required this.items,
    required this.initialIndex,
    this.style = kMediaPopupStyle,
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
  bool get _hasPrev => _index > 0;
  bool get _hasNext => _index < widget.items.length - 1;

  void _prev() {
    if (_hasPrev) setState(() => _index--);
  }

  void _next() {
    if (_hasNext) setState(() => _index++);
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return switch (widget.style) {
      MediaPopupStyle.immersive => _buildImmersive(),
      MediaPopupStyle.galleryStrip => _buildGalleryStrip(),
      MediaPopupStyle.minimal => _buildMinimal(),
    };
  }

  // ══════════════════════════════════════════════════════════════════
  // A — Immersive
  // Full image, no header. Floating arrows + dot indicator at bottom.
  // ══════════════════════════════════════════════════════════════════

  Widget _buildImmersive() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
          child: Stack(
            children: [
              // ── Image / Video ──
              SizedBox.expand(
                child: _current.isVideo
                    ? _VideoViewer(url: _current.url)
                    : _ImageViewer(
                        url: _current.url, fit: BoxFit.cover),
              ),

              // ── Gradient scrim ──
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xAA000000),
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                      stops: [0.0, 0.18, 0.72, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Close button ──
              Positioned(
                top: 12,
                right: 12,
                child: _FloatingCircleButton(
                  onTap: _close,
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),

              // ── Prev arrow ──
              if (widget.items.length > 1)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _FloatingCircleButton(
                      onTap: _hasPrev ? _prev : null,
                      child: Icon(Icons.chevron_left,
                          color: _hasPrev
                              ? Colors.white
                              : Colors.white30,
                          size: 24),
                    ),
                  ),
                ),

              // ── Next arrow ──
              if (widget.items.length > 1)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _FloatingCircleButton(
                      onTap: _hasNext ? _next : null,
                      child: Icon(Icons.chevron_right,
                          color: _hasNext
                              ? Colors.white
                              : Colors.white30,
                          size: 24),
                    ),
                  ),
                ),

              // ── Dot indicator ──
              if (widget.items.length > 1)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.items.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // B — Gallery Strip
  // Header with counter + close. Main image. Thumbnail strip at bottom.
  // ══════════════════════════════════════════════════════════════════

  Widget _buildGalleryStrip() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                color: const Color(0xFF0f172a),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      _current.isVideo
                          ? 'Video'
                          : 'Screenshot ${_index + 1} / ${widget.items.where((i) => !i.isVideo).length}',
                      style: const TextStyle(
                          color: Color(0xFF64748b), fontSize: 12),
                    ),
                    const Spacer(),
                    _SmallCloseButton(onTap: _close),
                  ],
                ),
              ),

              // ── Main image + fade arrows ──
              Flexible(
                child: Stack(
                  children: [
                    Container(
                      color: const Color(0xFF070d1a),
                      width: double.infinity,
                      child: _current.isVideo
                          ? _VideoViewer(url: _current.url)
                          : _ImageViewer(url: _current.url),
                    ),
                    if (widget.items.length > 1) ...[
                      // Left fade + arrow
                      Positioned(
                        left: 0, top: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: _hasPrev ? _prev : null,
                          child: Container(
                            width: 44,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xAA000000), Colors.transparent],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.chevron_left,
                                color: _hasPrev
                                    ? Colors.white70
                                    : Colors.transparent,
                                size: 28),
                          ),
                        ),
                      ),
                      // Right fade + arrow
                      Positioned(
                        right: 0, top: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: _hasNext ? _next : null,
                          child: Container(
                            width: 44,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0xAA000000)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.chevron_right,
                                color: _hasNext
                                    ? Colors.white70
                                    : Colors.transparent,
                                size: 28),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Thumbnail strip ──
              if (widget.items.length > 1)
                Container(
                  color: const Color(0xFF070d1a),
                  height: 76,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final item = widget.items[i];
                      final active = i == _index;
                      final poster = _posterUrl(item);
                      return GestureDetector(
                        onTap: () => setState(() => _index = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                poster.isNotEmpty
                                    ? Image.network(
                                        poster,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _thumbPlaceholder(),
                                      )
                                    : _thumbPlaceholder(),
                                if (!active)
                                  Container(
                                      color: Colors.black.withValues(
                                          alpha: 0.45)),
                                if (item.isVideo)
                                  const Center(
                                    child: Icon(Icons.play_arrow,
                                        color: Colors.white60, size: 14),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // C — Minimal Clean
  // Counter pill top-left. Image contain. Prev/next + dots in footer.
  // ══════════════════════════════════════════════════════════════════

  Widget _buildMinimal() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: const Color(0xFF1e293b),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _current.isVideo
                              ? 'Video'
                              : '${_index + 1} / ${widget.items.where((i) => !i.isVideo).length}',
                          style: const TextStyle(
                              color: Color(0xFF94a3b8), fontSize: 11),
                        ),
                      ),
                      const Spacer(),
                      _SmallCloseButton(onTap: _close),
                    ],
                  ),
                ),

                // ── Image / Video ──
                Flexible(
                  child: Container(
                    color: const Color(0xFF0f172a),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: _current.isVideo
                        ? _VideoViewer(url: _current.url)
                        : _ImageViewer(url: _current.url),
                  ),
                ),

                // ── Bottom bar ──
                if (widget.items.length > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0x1AFFFFFF)),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Prev/Next buttons
                        _NavButton(
                          icon: Icons.chevron_left,
                          enabled: _hasPrev,
                          onTap: _prev,
                        ),
                        const SizedBox(width: 8),
                        _NavButton(
                          icon: Icons.chevron_right,
                          enabled: _hasNext,
                          onTap: _next,
                        ),
                        const Spacer(),
                        // Dot indicators
                        Row(
                          children: List.generate(
                            widget.items.length.clamp(0, 10),
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: i == _index ? 14 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? AppColors.primary
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
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

  Widget _thumbPlaceholder() => Container(
        color: const Color(0xFF1e293b),
        child: const Icon(Icons.image, color: Color(0xFF334155), size: 14),
      );
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _FloatingCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _FloatingCircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: child,
      ),
    );
  }
}

class _SmallCloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SmallCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFF1e293b),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Color(0xFF94a3b8), size: 15),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.25)
                : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : const Color(0xFF334155),
          size: 20,
        ),
      ),
    );
  }
}

// ─── Image viewer ─────────────────────────────────────────────────────────────

class _ImageViewer extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const _ImageViewer({required this.url, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.image_not_supported,
            color: AppColors.primary, size: 48),
      ),
    );
  }
}

// ─── Video viewer ─────────────────────────────────────────────────────────────

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
    _viewId = 'video-${widget.url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
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
