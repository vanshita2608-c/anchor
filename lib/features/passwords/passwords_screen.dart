import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../core/models/password_item.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final List<PasswordItem> _passwords = [
    PasswordItem(
      id: 'pwd_1',
      websiteTitle: 'Netflix Family Account',
      websiteUrl: 'https://netflix.com',
      username: 'family@shah.com',
      encryptedPassword: '••••••••••••',
      category: 'Entertainment',
      isFavorite: true,
      securityScore: 95,
      createdAt: DateTime.now(),
    ),
    PasswordItem(
      id: 'pwd_2',
      websiteTitle: 'HDFC NetBanking (Dad)',
      websiteUrl: 'https://netbanking.hdfcbank.com',
      username: 'dad_hdfc_user',
      encryptedPassword: '••••••••••••',
      category: 'Banking',
      isFavorite: true,
      securityScore: 100,
      createdAt: DateTime.now(),
    ),
    PasswordItem(
      id: 'pwd_3',
      websiteTitle: 'Home Wi-Fi Router Admin',
      websiteUrl: '192.168.1.1',
      username: 'admin',
      encryptedPassword: '••••••••••••',
      category: 'Utilities',
      securityScore: 40, // Weak
      createdAt: DateTime.now(),
    ),
  ];

  void _copyPassword(String title) {
    Clipboard.setData(const ClipboardData(text: 'AnchorDecryptedSecret2026!'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password for $title copied to clipboard (clears in 30s)'),
        backgroundColor: AnchorColors.primaryNavy,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Password Vault', style: AnchorTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AnchorColors.primaryNavy),
            onPressed: () => _showAddPasswordModal(context),
            tooltip: 'Add Password',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Analysis Card
          Card(
            color: AnchorColors.primaryNavy,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.shield_moon_rounded, color: AnchorColors.ceruleanLight, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Password Health', style: AnchorTypography.titleLarge.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('1 Weak Password Detected • 2 Favorites', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.textDarkSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AnchorColors.navySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Score: 92%', style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.ceruleanLight)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('All Passwords (${_passwords.length})', style: AnchorTypography.headlineMedium),
          const SizedBox(height: 12),

          ..._passwords.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AnchorColors.ceruleanTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.key_rounded, color: AnchorColors.ceruleanTeal),
              ),
              title: Text(item.websiteTitle, style: AnchorTypography.titleMedium),
              subtitle: Text('${item.username} • ${item.category}', style: AnchorTypography.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AnchorColors.ceruleanTeal, size: 20),
                    onPressed: () => _copyPassword(item.websiteTitle),
                    tooltip: 'Copy Password',
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, color: AnchorColors.textSecondary, size: 20),
                    onPressed: () {},
                    tooltip: 'Reveal (Requires Biometrics)',
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AnchorColors.ceruleanTeal,
        onPressed: () => _showAddPasswordModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Password', style: AnchorTypography.buttonText),
      ),
    );
  }

  void _showAddPasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AnchorColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Password', style: AnchorTypography.headlineMedium),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Service Name (e.g. Netflix)')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Username / Email')),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.auto_awesome, color: AnchorColors.ceruleanTeal),
                    onPressed: () {},
                    tooltip: 'Generate Strong Password',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Save Encrypted Password', style: AnchorTypography.buttonText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
