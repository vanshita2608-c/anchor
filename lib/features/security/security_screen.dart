import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricsEnabled = true;
  bool _autoLockEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Security Dashboard', style: AnchorTypography.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vault Security Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AnchorColors.borderSand),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: 0.92,
                          strokeWidth: 8,
                          backgroundColor: AnchorColors.bgWarmCream,
                          valueColor: const AlwaysStoppedAnimation<Color>(AnchorColors.statusMint),
                        ),
                      ),
                      Text('92', style: AnchorTypography.securityScore),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vault Health: Excellent', style: AnchorTypography.headlineMedium),
                        const SizedBox(height: 4),
                        Text('AES-256-GCM zero-knowledge encryption active. 1 weak password needs attention.', style: AnchorTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security Controls
            Text('Security Controls', style: AnchorTypography.titleMedium),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.borderSand),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AnchorColors.primaryNavy,
                    title: Text('Face ID / Fingerprint Unlock', style: AnchorTypography.titleSmall),
                    subtitle: Text('Unlock Anchor securely without typing Master Password', style: AnchorTypography.bodySmall),
                    value: _biometricsEnabled,
                    onChanged: (val) => setState(() => _biometricsEnabled = val),
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  SwitchListTile(
                    activeColor: AnchorColors.primaryNavy,
                    title: Text('Auto-Lock Vault on Background', style: AnchorTypography.titleSmall),
                    subtitle: Text('Immediately locks vault when leaving the app', style: AnchorTypography.bodySmall),
                    value: _autoLockEnabled,
                    onChanged: (val) => setState(() => _autoLockEnabled = val),
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  ListTile(
                    leading: const Icon(Icons.key, color: AnchorColors.primaryNavy),
                    title: Text('Master Password & KEK Derivation', style: AnchorTypography.titleSmall),
                    subtitle: Text('PBKDF2-HMAC-SHA256 • 100,000 Iterations', style: AnchorTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AnchorColors.textMuted),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Audit Logs
            Text('Security Audit Trail', style: AnchorTypography.titleMedium),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.borderSand),
              ),
              child: Column(
                children: [
                  _buildAuditTile('Master Password Key Hierarchy Initialized', 'Device Keychain • Today at 4:00 PM', Icons.vpn_key_outlined),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  _buildAuditTile('Biometric Authentication Enrolled', 'Face ID • Today at 4:02 PM', Icons.fingerprint),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  _buildAuditTile('Google Account Verification', 'vanshitashah848@gmail.com', Icons.verified_user_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AnchorColors.bgWarmCream,
        child: Icon(icon, size: 18, color: AnchorColors.primaryNavy),
      ),
      title: Text(title, style: AnchorTypography.titleSmall),
      subtitle: Text(subtitle, style: AnchorTypography.bodySmall),
    );
  }
}
