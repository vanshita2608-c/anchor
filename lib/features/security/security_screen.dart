import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../core/models/audit_entry.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricsEnabled = true;
  String _autoLockTimeout = '1 Minute';

  final List<AuditEntry> _auditLogs = [
    AuditEntry(id: 'a1', action: 'Vault Unlocked via Biometrics', timestamp: 'Today, 6:42 PM'),
    AuditEntry(id: 'a2', action: 'Password "Netflix Family" Copied', timestamp: 'Today, 5:15 PM'),
    AuditEntry(id: 'a3', action: 'Document "Dad\'s Passport" Added', timestamp: 'Yesterday, 11:20 AM'),
    AuditEntry(id: 'a4', action: 'Master Password Derived (Argon2id/PBKDF2)', timestamp: 'Sep 7, 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Security & Audit', style: AnchorTypography.headlineLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vault Protection', style: AnchorTypography.titleLarge),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Biometric Unlock (Face ID / Fingerprint)', style: AnchorTypography.titleMedium),
                    subtitle: Text('Unlock local vault key with device biometrics', style: AnchorTypography.bodySmall),
                    value: _biometricsEnabled,
                    activeColor: AnchorColors.ceruleanTeal,
                    onChanged: (val) => setState(() => _biometricsEnabled = val),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Auto-Lock Timeout', style: AnchorTypography.titleMedium),
                    subtitle: Text('Lock vault when app moves to background', style: AnchorTypography.bodySmall),
                    trailing: DropdownButton<String>(
                      value: _autoLockTimeout,
                      underline: const SizedBox(),
                      items: ['Immediately', '1 Minute', '5 Minutes', '15 Minutes']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val, style: AnchorTypography.bodyMedium)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _autoLockTimeout = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Vault Key Recovery Section
          Card(
            color: AnchorColors.cardWhite,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.key_off_rounded, color: AnchorColors.warningAmber, size: 32),
              title: Text('Export Vault Recovery Key', style: AnchorTypography.titleMedium),
              subtitle: Text('Zero-knowledge vault recovery code in case master password is lost.', style: AnchorTypography.bodySmall),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 24),
          Text('Security Audit Feed', style: AnchorTypography.headlineMedium),
          const SizedBox(height: 4),
          Text('Strict privacy: No passwords or secret contents are ever logged.', style: AnchorTypography.bodySmall),
          const SizedBox(height: 12),

          ..._auditLogs.map((log) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(Icons.history_toggle_off_rounded, color: AnchorColors.ceruleanTeal),
              title: Text(log.action, style: AnchorTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(log.timestamp, style: AnchorTypography.bodySmall),
            ),
          )),
        ],
      ),
    );
  }
}
