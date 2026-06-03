import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom painter for the Bloch sphere visualization.
class BlochSpherePainter extends CustomPainter {
  final double x; // Bloch vector x component (-1 to 1)
  final double y; // Bloch vector y component (-1 to 1)
  final double z; // Bloch vector z component (-1 to 1)
  final Color color;

  const BlochSpherePainter({
    required this.x,
    required this.y,
    required this.z,
    this.color = AppTheme.primary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2 * 0.8;

    _drawGlow(canvas, cx, cy, r);
    _drawSphere(canvas, cx, cy, r);
    _drawAxes(canvas, cx, cy, r);
    _drawEquatorAndMeridians(canvas, cx, cy, r);
    _drawStateVector(canvas, cx, cy, r);
    _drawLabels(canvas, cx, cy, r);
  }

  void _drawGlow(Canvas canvas, double cx, double cy, double r) {
    final glow = Paint()
      ..color = color.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(cx, cy), r * 1.4, glow);
  }

  void _drawSphere(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          AppTheme.surface.withOpacity(0.95),
          AppTheme.background.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, paint);

    final outline = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), r, outline);
  }

  void _drawAxes(Canvas canvas, double cx, double cy, double r) {
    final axisPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Z axis (vertical)
    axisPaint.color = AppTheme.gateZ.withOpacity(0.5);
    canvas.drawLine(Offset(cx, cy - r * 1.1), Offset(cx, cy + r * 1.1), axisPaint);

    // X axis
    axisPaint.color = AppTheme.gateX.withOpacity(0.5);
    canvas.drawLine(Offset(cx - r * 1.1, cy), Offset(cx + r * 1.1, cy), axisPaint);

    // Y axis (projected at angle)
    axisPaint.color = AppTheme.gateY.withOpacity(0.5);
    canvas.drawLine(
      Offset(cx - r * 0.6, cy + r * 0.4),
      Offset(cx + r * 0.6, cy - r * 0.4),
      axisPaint,
    );
  }

  void _drawEquatorAndMeridians(Canvas canvas, double cx, double cy, double r) {
    final meridianPaint = Paint()
      ..color = AppTheme.textMuted.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Equatorial circle (projected as ellipse)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 0.5),
      meridianPaint,
    );

    // Meridian ellipse
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 0.5, height: r * 2),
      meridianPaint,
    );
  }

  void _drawStateVector(Canvas canvas, double cx, double cy, double r) {
    // Map Bloch vector (x,y,z) to screen coordinates
    // z → vertical, x → horizontal, y → depth (projected)
    final projX = x * r * 0.85 + y * r * 0.25;
    final projY = -z * r * 0.85 + y * r * 0.15;

    final endX = cx + projX;
    final endY = cy + projY;

    // Shadow / glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(Offset(cx, cy), Offset(endX, endY), glowPaint);

    // Main vector line
    final vecPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(endX, endY), vecPaint);

    // Arrowhead
    _drawArrowhead(canvas, cx, cy, endX, endY, color);

    // State dot
    final dotPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(endX, endY), 5, dotPaint);
    canvas.drawCircle(Offset(endX, endY), 3, Paint()..color = Colors.white);
  }

  void _drawArrowhead(Canvas canvas, double x1, double y1, double x2, double y2, Color c) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 10) return;
    final ux = dx / len;
    final uy = dy / len;
    const headLen = 10.0;
    const headAngle = 0.45;
    final p1 = Offset(
      x2 - headLen * (ux * math.cos(headAngle) - uy * math.sin(headAngle)),
      y2 - headLen * (uy * math.cos(headAngle) + ux * math.sin(headAngle)),
    );
    final p2 = Offset(
      x2 - headLen * (ux * math.cos(headAngle) + uy * math.sin(headAngle)),
      y2 - headLen * (uy * math.cos(headAngle) - ux * math.sin(headAngle)),
    );
    final paint = Paint()
      ..color = c
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(x2, y2)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, double cx, double cy, double r) {
    void drawLabel(String text, double px, double py, Color c) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: c,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }

    drawLabel('|0⟩', cx, cy - r * 1.18, AppTheme.gateZ);
    drawLabel('|1⟩', cx, cy + r * 1.18, AppTheme.gateZ);
    drawLabel('|+⟩', cx + r * 1.18, cy, AppTheme.gateX);
    drawLabel('|−⟩', cx - r * 1.18, cy, AppTheme.gateX);
    drawLabel('Y', cx + r * 0.75, cy - r * 0.5, AppTheme.gateY);
  }

  @override
  bool shouldRepaint(BlochSpherePainter old) =>
      old.x != x || old.y != y || old.z != z;
}

/// A widget that displays the Bloch sphere for a given state vector.
class BlochSphereWidget extends StatelessWidget {
  final double bx;
  final double by;
  final double bz;
  final double size;
  final Color? color;

  const BlochSphereWidget({
    super.key,
    this.bx = 0,
    this.by = 0,
    this.bz = 1,
    this.size = 200,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BlochSpherePainter(
          x: bx,
          y: by,
          z: bz,
          color: color ?? AppTheme.primary,
        ),
      ),
    );
  }
}
