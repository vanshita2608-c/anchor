import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

/// Anchor Logo Header Widget
/// Uses ANCHOR_ICON_ONLY.png (Anchor symbol only, no duplicate text)
/// merged 100% seamlessly on #FCF4E0 background
class AnchorLogoHeader extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool isLight;

  const AnchorLogoHeader({
    Key? key,
    this.size = 90.0,
    this.showTagline = true,
    this.isLight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Anchor Symbol ONLY (No text in image)
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/ANCHOR_ICON_ONLY.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        // Brand Title in Otama Display (Appears exactly ONCE)
        Text(
          'ANCHOR',
          style: AnchorTypography.brandTitle.copyWith(
            color: isLight ? Colors.white : AnchorColors.primaryNavy,
            fontSize: size * 0.30,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 2),
          Text(
            'Your Family. Secured.',
            style: AnchorTypography.brandSubtitle.copyWith(
              color: isLight ? AnchorColors.ceruleanLight : AnchorColors.ceruleanTeal,
              fontSize: size * 0.16,
            ),
          ),
        ],
      ],
    );
  }
}
