import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Emergency Access', style: AnchorTypography.headlineLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Warning Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AnchorColors.alertCoralLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AnchorColors.alertCoral.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AnchorColors.alertCoral, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Controlled Emergency Vault Access', style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.alertCoral)),
                      const SizedBox(height: 2),
                      Text('Emergency contacts can request access to critical documents with a mandatory 48-hour approval delay.', style: AnchorTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Trusted Emergency Contacts', style: AnchorTypography.headlineMedium),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AnchorColors.ceruleanTint,
                child: Icon(Icons.person_rounded, color: AnchorColors.primaryNavy),
              ),
              title: Text('Sunita Shah (Mom)', style: AnchorTypography.titleMedium),
              subtitle: Text('Scope: Insurance, Identity & Medical Documents (48h Delay)', style: AnchorTypography.bodySmall),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AnchorColors.statusMintLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('APPROVED', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.statusMint, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AnchorColors.alertCoral),
              onPressed: () {},
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
              label: Text('Initiate Emergency Access Request', style: AnchorTypography.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
