// lib/presentation/widgets/tilt_card.dart
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDegrees;
  final bool showShine;
  final Color hoverBorderColor;
  final Color hoverGlowColor;
  final double perspective;
  final double borderRadius;

  const TiltCard({
    required this.child,
    this.maxTiltDegrees = 14,
    this.showShine = true,
    this.hoverBorderColor = const Color(0x5510B981),
    this.hoverGlowColor = const Color(0x2210B981),
    this.perspective = 800,
    this.borderRadius = 16,
    super.key,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;

  double _tiltX = 0;
  double _tiltY = 0;
  double _targetTiltX = 0;
  double _targetTiltY = 0;
  Offset _shinePos = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Single persistent listener — no accumulation on each exit
    _resetController.addListener(() {
      if (mounted) {
        setState(() {
          final t = Curves.easeOutCubic.transform(_resetController.value);
          _tiltX = _targetTiltX * (1 - t);
          _tiltY = _targetTiltY * (1 - t);
        });
      }
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  Size _getActualSize() {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size ?? Size.zero;
  }

  void _onHover(PointerHoverEvent event) {
    _resetController.stop();
    final size = _getActualSize();
    if (size.isEmpty) return;

    // Normalize to -1..1 using actual rendered size
    final dx = ((event.localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final dy = ((event.localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);

    setState(() {
      _tiltX = -dy * widget.maxTiltDegrees;
      _tiltY = dx * widget.maxTiltDegrees;
      _shinePos = Offset(
        event.localPosition.dx / size.width,
        event.localPosition.dy / size.height,
      );
      _isHovered = true;
    });
  }

  void _onExit(PointerExitEvent _) {
    // Snapshot current tilt as spring-back start point
    _targetTiltX = _tiltX;
    _targetTiltY = _tiltY;
    _resetController
      ..reset()
      ..forward().then((_) {
        if (mounted) {
          setState(() {
            _tiltX = 0;
            _tiltY = 0;
            _isHovered = false;
          });
        }
      });
  }

  Matrix4 _buildMatrix() {
    final tx = _tiltX * math.pi / 180;
    final ty = _tiltY * math.pi / 180;
    return Matrix4.identity()
      ..setEntry(3, 2, 1 / widget.perspective)
      ..rotateX(tx)
      ..rotateY(ty);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Transform(
          transform: _buildMatrix(),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isHovered
                    ? widget.hoverBorderColor
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.hoverGlowColor,
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  widget.child,
                  if (widget.showShine && _isHovered)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(
                                _shinePos.dx * 2 - 1,
                                _shinePos.dy * 2 - 1,
                              ),
                              radius: 1.2,
                              colors: [
                                Colors.white.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
