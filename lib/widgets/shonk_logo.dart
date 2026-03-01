import 'package:flutter/material.dart';

class ShonkLogo extends StatelessWidget {
  const ShonkLogo({
    super.key,
    this.iconSize = 62,
    this.titleSize = 30,
    this.showSubtitle = true,
    this.primaryColor = const Color(0xFF1F2937),
    this.accentColor = const Color(0xFFE07B00),
    this.subtitleColor = const Color(0xFF9CA3AF),
  });

  final double iconSize;
  final double titleSize;
  final bool showSubtitle;
  final Color primaryColor;
  final Color accentColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _LogoPainter(accent: accentColor),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: 'SHONK',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: primaryColor,
                ),
                children: [
                  TextSpan(
                    text: 'POS',
                    style: TextStyle(color: accentColor),
                  ),
                ],
              ),
            ),
            if (showSubtitle)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  'MOBILE POINT OF SALE',
                  style: TextStyle(
                    fontSize: titleSize * 0.3,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 62.0;

    RRect rrect(double x, double y, double w, double h, double r) {
      return RRect.fromRectAndRadius(
        Rect.fromLTWH(x * scale, y * scale, w * scale, h * scale),
        Radius.circular(r * scale),
      );
    }

    Offset pt(double x, double y) => Offset(x * scale, y * scale);

    final bg = Paint()..color = accent.withOpacity(0.1);
    canvas.drawRRect(rrect(0, 0, 62, 62, 14), bg);

    final stroke = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final base = Path()
      ..moveTo(16 * scale, 28 * scale)
      ..lineTo(16 * scale, 48 * scale)
      ..lineTo(46 * scale, 48 * scale)
      ..lineTo(46 * scale, 28 * scale);
    canvas.drawPath(base, stroke);

    final roof = Path()
      ..moveTo(12 * scale, 22 * scale)
      ..lineTo(20 * scale, 14 * scale)
      ..lineTo(42 * scale, 14 * scale)
      ..lineTo(50 * scale, 22 * scale)
      ..close();
    canvas.drawPath(roof, Paint()..color = accent.withOpacity(0.15));
    canvas.drawPath(roof, stroke);

    canvas.drawRRect(
      rrect(26, 36, 10, 12, 2),
      Paint()..color = accent.withOpacity(0.3),
    );
    canvas.drawRRect(rrect(26, 36, 10, 12, 2), stroke..strokeWidth = 1.5 * scale);

    canvas.drawRRect(rrect(18, 30, 10, 8, 2), stroke);
    canvas.drawRRect(rrect(34, 30, 10, 8, 2), stroke);

    canvas.drawLine(
      pt(12, 22),
      pt(50, 22),
      Paint()
        ..color = accent.withOpacity(0.4)
        ..strokeWidth = 2 * scale,
    );

    canvas.drawCircle(pt(50, 14), 9 * scale, Paint()..color = accent);

    final textPainter = TextPainter(
      text: TextSpan(
        text: r'$',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11 * scale,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = pt(50, 14) - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
