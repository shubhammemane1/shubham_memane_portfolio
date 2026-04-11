// lib/presentation/widgets/parallax_rings.dart
import 'package:flutter/material.dart';
import '../../core/state/mouse_notifier.dart';

/// Three concentric rings that move at different parallax depths
/// as the mouse moves, creating a sense of 3D layering.
class ParallaxRings extends StatelessWidget {
  final MouseNotifier mouseNotifier;

  const ParallaxRings({required this.mouseNotifier, super.key});

  static const _factors = [0.04, 0.025, 0.01];
  static const _diameters = [500.0, 350.0, 200.0];
  static const _opacities = [0.12, 0.2, 0.35];
  static const Color _ringColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: mouseNotifier,
      builder: (context, mouse, _) {
        final screenW = MediaQuery.of(context).size.width;
        final screenH = MediaQuery.of(context).size.height;
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final offsetX = mouse.dx * screenW / 2 * _factors[i];
            final offsetY = mouse.dy * screenH / 2 * _factors[i];
            return Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Container(
                width: _diameters[i],
                height: _diameters[i],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _ringColor.withValues(alpha: _opacities[i]),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
