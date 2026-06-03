import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// An animated spinning qubit sphere widget.
class AnimatedQubit extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const AnimatedQubit({
    super.key,
    this.size = 80,
    this.color = AppTheme.primary,
    this.animate = true,
  });

  @override
  State<AnimatedQubit> createState() => _AnimatedQubitState();
}

class _AnimatedQubitState extends State<AnimatedQubit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _QubitSpherePainter(angle: 0, color: widget.color),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _QubitSpherePainter(
          angle: _controller.value * 2 * math.pi,
          color: widget.color,
        ),
      ),
    );
  }
}

class _QubitSpherePainter extends CustomPainter {
  final double angle;
  final Color color;

  const _QubitSpherePainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 * 0.85;

    // Glow background
    final glowPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx, cy), r * 1.3, glowPaint);

    // Main sphere gradient
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.15),
          color.withOpacity(0.05),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, spherePaint);

    // Sphere outline
    final outlinePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), r, outlinePaint);

    // Equator ellipse (animated rotation)
    final equatorPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final equatorPath = Path();
    final scaleY = math.sin(angle).abs() * 0.4 + 0.1;
    equatorPath.addOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: r * 2,
        height: r * scaleY * 2,
      ),
    );
    canvas.drawPath(equatorPath, equatorPaint);

    // State vector arrow
    final vecX = math.cos(angle) * r * 0.7;
    final vecY = -math.sin(angle * 0.7) * r * 0.7;
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + vecX, cy + vecY),
      arrowPaint,
    );

    // Arrow head
    final headPaint = Paint()..color = color;
    canvas.drawCircle(Offset(cx + vecX, cy + vecY), 4, headPaint);

    // North/south poles
    final polePaint = Paint()..color = color.withOpacity(0.7);
    canvas.drawCircle(Offset(cx, cy - r), 3, polePaint);
    canvas.drawCircle(Offset(cx, cy + r), 3, polePaint);
  }

  @override
  bool shouldRepaint(_QubitSpherePainter old) => old.angle != angle;
}
