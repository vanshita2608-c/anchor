import 'package:flutter/material.dart';

/// Exact official multi-color Google "G" logo
class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({Key? key, this.size = 22.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OfficialGoogleGPainter(),
      ),
    );
  }
}

class _OfficialGoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final scale = s / 24.0;
    canvas.scale(scale, scale);

    // Blue Segment
    final Paint blue = Paint()..color = const Color(0xFF4285F4);
    final Path pathBlue = Path()
      ..moveTo(23.49, 12.27)
      ..cubicTo(23.49, 11.48, 23.42, 10.73, 23.3, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.51)
      ..lineTo(18.47, 14.51)
      ..cubicTo(18.18, 15.99, 17.31, 17.24, 16.03, 18.09)
      ..lineTo(16.03, 21.09)
      ..lineTo(19.94, 21.09)
      ..cubicTo(22.23, 18.98, 23.49, 15.91, 23.49, 12.27)
      ..close();
    canvas.drawPath(pathBlue, blue);

    // Green Segment
    final Paint green = Paint()..color = const Color(0xFF34A853);
    final Path pathGreen = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.96, 22.92, 19.94, 21.09)
      ..lineTo(16.03, 18.09)
      ..cubicTo(14.95, 18.81, 13.58, 19.25, 12.0, 19.25)
      ..cubicTo(8.87, 19.25, 6.22, 17.14, 5.27, 14.29)
      ..lineTo(1.23, 14.29)
      ..lineTo(1.23, 17.42)
      ..cubicTo(3.25, 21.34, 7.31, 24.0, 12.0, 24.0)
      ..close();
    canvas.drawPath(pathGreen, green);

    // Yellow Segment
    final Paint yellow = Paint()..color = const Color(0xFFFBBC05);
    final Path pathYellow = Path()
      ..moveTo(5.27, 14.29)
      ..cubicTo(5.03, 13.57, 4.9, 12.8, 4.9, 12.0)
      ..cubicTo(4.9, 11.2, 5.03, 10.43, 5.27, 9.71)
      ..lineTo(5.27, 6.58)
      ..lineTo(1.23, 6.58)
      ..cubicTo(0.44, 8.16, 0.0, 9.97, 0.0, 12.0)
      ..cubicTo(0.0, 14.03, 0.44, 15.84, 1.23, 17.42)
      ..lineTo(5.27, 14.29)
      ..close();
    canvas.drawPath(pathYellow, yellow);

    // Red Segment
    final Paint red = Paint()..color = const Color(0xFFEA4335);
    final Path pathRed = Path()
      ..moveTo(12.0, 4.75)
      ..cubicTo(13.77, 4.75, 15.35, 5.36, 16.6, 6.55)
      ..lineTo(19.99, 3.16)
      ..cubicTo(17.95, 1.26, 15.24, 0.0, 12.0, 0.0)
      ..cubicTo(7.31, 0.0, 3.25, 2.66, 1.23, 6.58)
      ..lineTo(5.27, 9.71)
      ..cubicTo(6.22, 6.86, 8.87, 4.75, 12.0, 4.75)
      ..close();
    canvas.drawPath(pathRed, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
