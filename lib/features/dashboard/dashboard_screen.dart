import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../documents/documents_screen.dart';
import '../passwords/passwords_screen.dart';
import '../emergency/emergency_screen.dart';
import '../family/family_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String vaultName;
  final String userName;

  const DashboardScreen({
    Key? key,
    this.vaultName = 'Shah Family',
    this.userName = 'Vanshita',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good evening, $userName', style: AnchorTypography.headlineLarge),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.shield, size: 14, color: AnchorColors.ceruleanTeal),
                          const SizedBox(width: 4),
                          Text('$vaultName Vault • 4 Members', style: AnchorTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AnchorColors.cardWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AnchorColors.borderSand),
                    ),
                    child: const Icon(Icons.notifications_none, color: AnchorColors.primaryNavy),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Action Grid Bar
              Text('Quick Add & Scan', style: AnchorTypography.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.note_add_outlined,
                    label: 'Document',
                    color: AnchorColors.primaryNavy,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
                  ),
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.key_outlined,
                    label: 'Password',
                    color: AnchorColors.ceruleanTeal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordsScreen())),
                  ),
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.document_scanner,
                    label: 'Scan OCR',
                    color: AnchorColors.statusMint,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen(initialScan: true))),
                  ),
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.health_and_safety_outlined,
                    label: 'Emergency',
                    color: AnchorColors.alertCoral,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Expiring Soon Banner Alert
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AnchorColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AnchorColors.borderSand),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AnchorColors.alertCoral, size: 20),
                        const SizedBox(width: 8),
                        Text('Expiring Soon (3 Items)', style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.alertCoral)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpiryTile('Passport (Vanshita Shah)', 'Expires in 90 days', Icons.card_membership),
                    const Divider(color: AnchorColors.borderSand, height: 16),
                    _buildExpiryTile('Car Insurance Policy', 'Expires in 18 days', Icons.directions_car_outlined),
                    const Divider(color: AnchorColors.borderSand, height: 16),
                    _buildExpiryTile('MacBook Pro Warranty', 'Expires in 7 days', Icons.laptop_mac),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vault Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Documents',
                      count: '24 Items',
                      icon: Icons.folder_special_outlined,
                      subtitle: 'Identity, Legal, Medical',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Passwords',
                      count: '18 Saved',
                      icon: Icons.key_outlined,
                      subtitle: 'OTT, Wi-Fi, Utilities',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Family Members',
                      count: '4 Active',
                      icon: Icons.group_outlined,
                      subtitle: 'Owner, Admin, Member',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FamilyScreen())),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Emergency',
                      count: 'Configured',
                      icon: Icons.health_and_safety_outlined,
                      subtitle: 'Contacts & Legacy',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Audit Activity Log
              Text('Recent Vault Activity', style: AnchorTypography.titleMedium),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AnchorColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AnchorColors.borderSand),
                ),
                child: Column(
                  children: [
                    _buildActivityTile('Passport Document Added', 'Vanshita Shah • Today at 4:30 PM', Icons.add_circle_outline),
                    const Divider(color: AnchorColors.borderSand, height: 1),
                    _buildActivityTile('Netflix Password Shared with Mom', 'Vanshita Shah • Yesterday', Icons.share),
                    const Divider(color: AnchorColors.borderSand, height: 1),
                    _buildActivityTile('Car Insurance Expiry Detected', 'Smart OCR Scanner • 2 days ago', Icons.alarm),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AnchorColors.cardWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AnchorColors.borderSand),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: AnchorTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildExpiryTile(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AnchorColors.primaryNavy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AnchorTypography.titleSmall),
              Text(subtitle, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AnchorColors.textMuted),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AnchorColors.primaryNavy, size: 24),
                const Icon(Icons.arrow_forward, size: 16, color: AnchorColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: AnchorTypography.titleMedium),
            const SizedBox(height: 2),
            Text(count, style: AnchorTypography.statNumber.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(subtitle, style: AnchorTypography.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String title, String subtitle, IconData icon) {
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
