import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../auth/auth_screen.dart';
import '../onboarding/feature_tour_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _gmailConnected = false;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Vanshita Shah';
    final userEmail = user?.email ?? 'vanshitashah848@gmail.com';
    final username = user?.userMetadata?['username'] ?? 'vanshita_shah';
    final mobile = user?.userMetadata?['mobile'] ?? '+91 98201 92810';

    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Profile & Settings', style: AnchorTypography.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AnchorColors.borderSand),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AnchorColors.primaryNavy,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: AnchorTypography.displayLarge.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: AnchorTypography.headlineMedium),
                        const SizedBox(height: 2),
                        Text(userEmail, style: AnchorTypography.bodySmall),
                        Text('@$username • $mobile', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.ceruleanTeal)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Connected Email Abstraction (Gmail OAuth)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.borderSand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, color: AnchorColors.ceruleanTeal, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connect Gmail for Auto-Reminders', style: AnchorTypography.titleSmall),
                            Text('Scans for bills, warranties, and insurance renewals', style: AnchorTypography.bodySmall),
                          ],
                        ),
                      ),
                      Switch(
                        activeColor: AnchorColors.primaryNavy,
                        value: _gmailConnected,
                        onChanged: (val) {
                          setState(() => _gmailConnected = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Gmail connection initialized' : 'Gmail disconnected'),
                              backgroundColor: AnchorColors.primaryNavy,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings List
            Container(
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.borderSand),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.explore_outlined, color: AnchorColors.primaryNavy),
                    title: Text('Replay Anchor Feature Tour', style: AnchorTypography.titleSmall),
                    subtitle: Text('Review interactive product walkthrough', style: AnchorTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AnchorColors.textMuted),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeatureTourScreen()));
                    },
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_outlined, color: AnchorColors.primaryNavy),
                    title: Text('Export Encrypted Vault Data', style: AnchorTypography.titleSmall),
                    subtitle: Text('Download local backup of vault objects', style: AnchorTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AnchorColors.textMuted),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting encrypted backup...'), backgroundColor: AnchorColors.primaryNavy),
                      );
                    },
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AnchorColors.alertCoral),
                    title: Text('Delete Account & Clear Vault', style: AnchorTypography.titleSmall.copyWith(color: AnchorColors.alertCoral)),
                    subtitle: Text('Permanently wipes encryption keys and vault items', style: AnchorTypography.bodySmall),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AnchorColors.alertCoral),
                label: Text('Sign Out', style: AnchorTypography.buttonText.copyWith(color: AnchorColors.alertCoral)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
