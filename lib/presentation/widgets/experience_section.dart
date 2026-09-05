import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../domain/models/portfolio_data.dart';

class ExperienceSection extends StatefulWidget {
  final List<Experience> experiences;

  const ExperienceSection({super.key, required this.experiences});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('experience-section'),
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
            Text('Experience', style: Responsive.value(context, mobile: Theme.of(context).textTheme.displaySmall, desktop: Theme.of(context).textTheme.displayMedium)),
            const SizedBox(height: AppSpacing.xl),
            Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: widget.experiences.asMap().entries.map((entry) {
                  return _TimelineCard(
                    experience: entry.value,
                    index: entry.key,
                    isVisible: _isVisible,
                    isLast: entry.key == widget.experiences.length - 1,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Experience experience;
  final int index;
  final bool isVisible;
  final bool isLast;

  const _TimelineCard({
    required this.experience,
    required this.index,
    required this.isVisible,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    final isMobile = Responsive.isMobile(context);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0, end: isVisible ? 1 : 0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((isEven && !isMobile ? -50 : 50) * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left side content (for even index on desktop)
            if (!isMobile && isEven)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  child: _ContentCard(experience: experience, alignment: Alignment.centerRight),
                ),
              )
            else if (!isMobile)
              const Expanded(child: SizedBox()),

            // Timeline line and dot
            SizedBox(
              width: 60,
              child: Stack(
                children: [
                  // Snake dotted line (Positioned so it doesn't feed into
                  // IntrinsicHeight's calculation and starve the card's height)
                  if (!isLast)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CustomPaint(
                        painter: _SnakeDottedLinePainter(
                          color: AppColors.primary,
                          isEven: isEven,
                        ),
                      ),
                    ),
                  // Timeline dot
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right side content (for odd index on desktop, all on mobile)
            if (!isMobile && !isEven)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xl),
                  child: _ContentCard(experience: experience, alignment: Alignment.centerLeft),
                ),
              )
            else if (isMobile)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: _ContentCard(experience: experience, alignment: Alignment.centerLeft),
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatefulWidget {
  final Experience experience;
  final Alignment alignment;

  const _ContentCard({required this.experience, required this.alignment});

  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isHovered ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? AppColors.primary.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: widget.alignment == Alignment.centerRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                widget.experience.duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Position
            Text(
              widget.experience.position,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: widget.alignment == Alignment.centerRight ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Company
            Row(
              children: [
                Icon(Icons.business, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    widget.experience.company,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Description
            Text(
              widget.experience.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: widget.alignment == Alignment.centerRight ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for snake dotted line
class _SnakeDottedLinePainter extends CustomPainter {
  final Color color;
  final bool isEven;

  _SnakeDottedLinePainter({required this.color, required this.isEven});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerX = size.width / 2;
    
    // Start from top center
    path.moveTo(centerX, 0);

    // Create snake curve
    final curveHeight = size.height;
    final amplitude = 15.0; // How far the curve goes left/right
    
    // Create smooth S-curve
    if (isEven) {
      // Curve to the right then left
      path.cubicTo(
        centerX + amplitude, curveHeight * 0.25,
        centerX + amplitude, curveHeight * 0.5,
        centerX, curveHeight * 0.5,
      );
      path.cubicTo(
        centerX - amplitude, curveHeight * 0.5,
        centerX - amplitude, curveHeight * 0.75,
        centerX, curveHeight,
      );
    } else {
      // Curve to the left then right
      path.cubicTo(
        centerX - amplitude, curveHeight * 0.25,
        centerX - amplitude, curveHeight * 0.5,
        centerX, curveHeight * 0.5,
      );
      path.cubicTo(
        centerX + amplitude, curveHeight * 0.5,
        centerX + amplitude, curveHeight * 0.75,
        centerX, curveHeight,
      );
    }

    // Draw dotted line
    _drawDottedPath(canvas, path, paint);
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)?.position;
        distance += dashWidth;
        final end = metric.getTangentForOffset(distance)?.position;
        
        if (start != null && end != null) {
          canvas.drawLine(start, end, paint);
        }
        distance += dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
