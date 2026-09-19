import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'OTT & Entertainment',
    'Shopping',
    'Utilities',
    'Accounts',
  ];

  final List<Map<String, dynamic>> _passwords = [
    {
      'service': 'Netflix (Family Plan)',
      'category': 'OTT & Entertainment',
      'username': 'family@shah.com',
      'password': '••••••••••••',
      'strength': 'Strong',
      'shared_with': 'Entire Vault',
      'icon': Icons.tv_outlined,
    },
    {
      'service': 'Amazon Prime',
      'category': 'OTT & Entertainment',
      'username': 'vanshita@gmail.com',
      'password': '••••••••••••',
      'strength': 'Strong',
      'shared_with': 'Selected Members',
      'icon': Icons.movie_outlined,
    },
    {
      'service': 'Home Wi-Fi (Shah_5G)',
      'category': 'Utilities',
      'username': 'Shah_5G',
      'password': '••••••••••••',
      'strength': 'Strong',
      'shared_with': 'Entire Vault',
      'icon': Icons.wifi,
    },
    {
      'service': 'Flipkart Account',
      'category': 'Shopping',
      'username': 'vanshitashah848@gmail.com',
      'password': '••••••••••••',
      'strength': 'Moderate',
      'shared_with': 'Only Me',
      'icon': Icons.shopping_bag_outlined,
    },
  ];

  void _showAddPasswordSheet() {
    final serviceCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    String category = 'OTT & Entertainment';
    String accessPermission = 'Entire Vault';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AnchorColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Password', style: AnchorTypography.headlineMedium),
                        TextButton.icon(
                          onPressed: () {
                            final gen = _generatePassword();
                            setModalState(() {
                              pwdCtrl.text = gen;
                            });
                          },
                          icon: const Icon(Icons.autorenew, size: 18, color: AnchorColors.ceruleanTeal),
                          label: Text('Generate Secure', style: AnchorTypography.labelMedium.copyWith(color: AnchorColors.ceruleanTeal)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: serviceCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Service Name (e.g. Netflix, Wi-Fi)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: userCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Username / Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pwdCtrl,
                      obscureText: false,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setModalState(() => category = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: accessPermission,
                      decoration: const InputDecoration(labelText: 'Who Can Access?'),
                      items: ['Only Me', 'Selected Members', 'Entire Vault'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setModalState(() => accessPermission = val!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (serviceCtrl.text.isNotEmpty && pwdCtrl.text.isNotEmpty) {
                            setState(() {
                              _passwords.insert(0, {
                                'service': serviceCtrl.text,
                                'category': category,
                                'username': userCtrl.text.isNotEmpty ? userCtrl.text : 'user@example.com',
                                'password': '••••••••••••',
                                'strength': 'Strong',
                                'shared_with': accessPermission,
                                'icon': Icons.lock_outline,
                              });
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text('Save Password to Vault', style: AnchorTypography.buttonText),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _generatePassword() {
    const chars = r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()';
    final rnd = Random.secure();
    return List.generate(14, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _passwords
        : _passwords.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Password Vault', style: AnchorTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AnchorColors.primaryNavy),
            onPressed: _showAddPasswordSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat, style: AnchorTypography.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AnchorColors.primaryNavy,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    selected: isSelected,
                    selectedColor: AnchorColors.primaryNavy,
                    backgroundColor: AnchorColors.cardWhite,
                    side: const BorderSide(color: AnchorColors.borderSand),
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // Passwords List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pwd = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AnchorColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AnchorColors.borderSand),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AnchorColors.bgWarmCream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(pwd['icon'] as IconData, color: AnchorColors.primaryNavy, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pwd['service'] as String, style: AnchorTypography.titleSmall),
                            const SizedBox(height: 2),
                            Text('${pwd['username']} • Shared: ${pwd['shared_with']}', style: AnchorTypography.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AnchorColors.statusMint.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pwd['strength'] as String,
                          style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.statusMint, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AnchorColors.primaryNavy,
        onPressed: _showAddPasswordSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Password', style: AnchorTypography.buttonText),
      ),
    );
  }
}
