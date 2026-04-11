// lib/presentation/widgets/particle_canvas.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/state/mouse_notifier.dart';

class ParticleCanvas extends StatefulWidget {
  final MouseNotifier mouseNotifier;

  const ParticleCanvas({required this.mouseNotifier, super.key});

  @override
  State<ParticleCanvas> createState() => _ParticleCanvasState();
}

class _ParticleCanvasState extends State<ParticleCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  static const int _particleCount = 80;
  static const double _connectionDistance = 100;
  static const double _repulsionRadius = 120;
  static const Color _particleColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < _particleCount; i++) {
        _particles.add(_Particle.random(_random, size));
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final deltaMs = (elapsed - _lastElapsed).inMilliseconds.clamp(1, 32);
    _lastElapsed = elapsed;

    if (!mounted) return;
    final size = context.size ?? Size.zero;
    final mouse = widget.mouseNotifier.value;
    final mousePx = Offset(
      (mouse.dx + 1) / 2 * size.width,
      (mouse.dy + 1) / 2 * size.height,
    );

    for (final p in _particles) {
      p.update(deltaMs.toDouble(), size, mousePx, _repulsionRadius);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _ParticlePainter(
        particles: List.unmodifiable(_particles),
        connectionDistance: _connectionDistance,
        color: _particleColor,
        isDark: isDark,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, opacity;
  bool glowing;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.glowing,
  });

  factory _Particle.random(math.Random rnd, Size bounds) {
    final speed = 0.3 + rnd.nextDouble() * 0.4;
    final angle = rnd.nextDouble() * 2 * math.pi;
    return _Particle(
      x: rnd.nextDouble() * bounds.width,
      y: rnd.nextDouble() * bounds.height,
      vx: math.cos(angle) * speed,
      vy: math.sin(angle) * speed,
      size: rnd.nextDouble() * 2 + 1,
      opacity: rnd.nextDouble() * 0.6 + 0.2,
      glowing: rnd.nextDouble() > 0.6,
    );
  }

  void update(double deltaMs, Size bounds, Offset mouse, double repulsionRadius) {
    final scale = deltaMs / 16.0;
    x += vx * scale;
    y += vy * scale;

    if (x < 0 || x > bounds.width) vx = -vx;
    if (y < 0 || y > bounds.height) vy = -vy;
    x = x.clamp(0, bounds.width);
    y = y.clamp(0, bounds.height);

    final dx = x - mouse.dx;
    final dy = y - mouse.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < repulsionRadius && dist > 0) {
      final force = (repulsionRadius - dist) / repulsionRadius * 1.5 * scale;
      x += (dx / dist) * force;
      y += (dy / dist) * force;
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double connectionDistance;
  final Color color;
  final bool isDark;

  const _ParticlePainter({
    required this.particles,
    required this.connectionDistance,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawConnections(canvas);
    _drawParticles(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    const step = 50.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxDist = math.sqrt(cx * cx + cy * cy);

    double gridOpacity(double x, double y) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);
      return (1 - dist / maxDist).clamp(0.0, 1.0) * (isDark ? 0.10 : 0.05);
    }

    for (double x = 0; x < size.width; x += step) {
      final opacity = gridOpacity(x, cy);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..strokeWidth = 0.5,
      );
    }
    for (double y = 0; y < size.height; y += step) {
      final opacity = gridOpacity(cx, y);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawConnections(Canvas canvas) {
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].x - particles[j].x;
        final dy = particles[i].y - particles[j].y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < connectionDistance) {
          final opacity = (1 - dist / connectionDistance) * 0.15;
          canvas.drawLine(
            Offset(particles[i].x, particles[i].y),
            Offset(particles[j].x, particles[j].y),
            Paint()
              ..color = color.withValues(alpha: opacity)
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final paint = Paint()..color = color.withValues(alpha: p.opacity);
      if (p.glowing) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      }
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
