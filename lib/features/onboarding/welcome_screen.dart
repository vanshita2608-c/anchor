import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../shared/widgets/anchor_logo_header.dart';
import 'feature_tour_screen.dart';
import '../vault_setup/create_vault_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final String userName;

  const WelcomeScreen({
    Key? key,
    this.userName = 'User',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const AnchorLogoHeader(size: 100.0),
                      const SizedBox(height: 24),

                      Text(
                        'Welcome to Anchor,\n$userName!',
                        textAlign: TextAlign.center,
                        style: AnchorTypography.displayLarge,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Your family digital life, securely organized in one zero-knowledge place.',
                        textAlign: TextAlign.center,
                        style: AnchorTypography.bodyLarge.copyWith(color: AnchorColors.textSecondary),
                      ),

                      const SizedBox(height: 28),

                      // Feature Highlights Badge Box
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AnchorColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AnchorColors.borderSand),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildFeatureRow(Icons.security, 'Zero-Knowledge Encryption', 'Only you & authorized family hold keys'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AnchorColors.borderSand),
                            ),
                            _buildFeatureRow(Icons.document_scanner_outlined, 'OCR Document Scanner', 'Instant document text extraction'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AnchorColors.borderSand),
                            ),
                            _buildFeatureRow(Icons.group_outlined, 'Family Permissions', 'Granular controls for every item'),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      // Primary CTA: Let's Set Up Anchor
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const FeatureTourScreen()),
                            );
                          },
                          child: Text("Let's Set Up Anchor", style: AnchorTypography.buttonText),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Secondary CTA: Skip Tour
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateVaultScreen()),
                          );
                        },
                        child: Text(
                          'Skip Tour & Create Vault',
                          style: AnchorTypography.bodyMedium.copyWith(
                            color: AnchorColors.ceruleanTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AnchorColors.bgWarmCream,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AnchorColors.primaryNavy, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AnchorTypography.titleMedium),
              const SizedBox(height: 2),
              Text(desc, style: AnchorTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
