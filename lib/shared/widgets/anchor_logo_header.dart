import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

/// Custom Anchor Logo Emblem & Brand Header Widget
/// Renders Logo #2: Deep Navy Shield + Keyhole Anchor + Cerulean Waves
class AnchorLogoHeader extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool isLight;

  const AnchorLogoHeader({
    Key? key,
    this.size = 64.0,
    this.showTagline = true,
    this.isLight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Logo Emblem Tile
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AnchorColors.bgWarmCream,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: AnchorColors.primaryNavy.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: AnchorColors.borderSand, width: 1.5),
          ),
          child: CustomPaint(
            painter: _AnchorEmblemPainter(),
          ),
        ),
        const SizedBox(height: 12),
        // Brand Title
        Text(
          'ANCHOR',
          style: AnchorTypography.brandTitle.copyWith(
            color: isLight ? Colors.white : AnchorColors.primaryNavy,
            fontSize: size * 0.42,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Your Family. Secured.',
            style: AnchorTypography.brandSubtitle.copyWith(
              color: isLight ? AnchorColors.ceruleanLight : AnchorColors.ceruleanTeal,
              fontSize: size * 0.20,
            ),
          ),
        ],
      ],
    );
  }
}

class _AnchorEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Anchor Body in Deep Navy
    final navyPaint = Paint()
      ..color = AnchorColors.primaryNavy
      ..style = PaintingStyle.fill;

    // Anchor Vertical Stem
    final stemPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.18, w * 0.12, h * 0.52),
        const Radius.circular(4),
      ));
    canvas.drawPath(stemPath, navyPaint);

    // Anchor Top Ring
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.09, navyPaint);
    final ringHolePaint = Paint()..color = AnchorColors.bgWarmCream;
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.045, ringHolePaint);

    // Anchor Crossbar
    final barPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.34, w * 0.48, h * 0.08),
        const Radius.circular(3),
      ));
    canvas.drawPath(barPath, navyPaint);

    // Anchor Bottom Flukes
    final flukePath = Path()
      ..moveTo(w * 0.18, h * 0.48)
      ..quadraticBezierTo(w * 0.22, h * 0.68, w * 0.5, h * 0.70)
      ..quadraticBezierTo(w * 0.78, h * 0.68, w * 0.82, h * 0.48)
      ..lineTo(w * 0.74, h * 0.46)
      ..quadraticBezierTo(w * 0.70, h * 0.62, w * 0.5, h * 0.63)
      ..quadraticBezierTo(w * 0.30, h * 0.62, w * 0.26, h * 0.46)
      ..close();
    canvas.drawPath(flukePath, navyPaint);

    // Keyhole Negative Space in Stem Center
    final keyholePaint = Paint()..color = AnchorColors.bgWarmCream;
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.04, keyholePaint);
    final keyholeSlot = Path()
      ..moveTo(w * 0.48, h * 0.48)
      ..lineTo(w * 0.52, h * 0.48)
      ..lineTo(w * 0.53, h * 0.56)
      ..lineTo(w * 0.47, h * 0.48)
      ..close();
    canvas.drawPath(keyholeSlot, keyholePaint);

    // 2. Draw Cerulean Ocean Waves at the base
    final wavePaint = Paint()
      ..color = AnchorColors.ceruleanTeal
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(w * 0.18, h * 0.78)
      ..quadraticBezierTo(w * 0.35, h * 0.72, w * 0.50, h * 0.78)
      ..quadraticBezierTo(w * 0.65, h * 0.84, w * 0.82, h * 0.78)
      ..lineTo(w * 0.82, h * 0.84)
      ..quadraticBezierTo(w * 0.65, h * 0.90, w * 0.50, h * 0.84)
      ..quadraticBezierTo(w * 0.35, h * 0.78, w * 0.18, h * 0.84)
      ..close();
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
