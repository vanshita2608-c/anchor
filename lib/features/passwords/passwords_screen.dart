import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/password_item.dart';
import '../../core/services/vault_repository.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final VaultRepository _repo = VaultRepository();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'OTT & Entertainment',
    'Shopping',
    'Utilities',
    'Accounts',
  ];

  List<PasswordItem> _passwords = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final items = await _repo.fetchPasswords();
      if (mounted) setState(() => _passwords = items);
    } catch (e) {
      debugPrint('Load passwords notice: $e');
      if (mounted) setState(() => _loadError = "Couldn't load your passwords.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: error ? AnchorColors.alertCoral : AnchorColors.primaryNavy),
    );
  }

  Future<void> _copyPassword(PasswordItem item) async {
    try {
      final plain = await _repo.revealPassword(item);
      await Clipboard.setData(ClipboardData(text: plain));
      _showSnack('Password for ${item.websiteTitle} copied');
    } catch (e) {
      debugPrint('Reveal password notice: $e');
      _showSnack("Couldn't decrypt this password.", error: true);
    }
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'OTT & Entertainment':
        return Icons.tv_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Utilities':
        return Icons.wifi;
      case 'Accounts':
        return Icons.account_circle_outlined;
      default:
        return Icons.lock_outline;
    }
  }

  void _showAddPasswordSheet() {
    final serviceCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    String category = 'OTT & Entertainment';
    String accessPermission = 'Entire Vault';
    bool saving = false;
    String? formError;

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
                    if (formError != null) ...[
                      const SizedBox(height: 12),
                      Text(formError!, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral)),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (serviceCtrl.text.trim().isEmpty || pwdCtrl.text.isEmpty) {
                                  setModalState(() => formError = 'Please enter a service name and password.');
                                  return;
                                }
                                setModalState(() {
                                  saving = true;
                                  formError = null;
                                });
                                try {
                                  await _repo.addPassword(
                                    websiteTitle: serviceCtrl.text.trim(),
                                    username: userCtrl.text.trim(),
                                    password: pwdCtrl.text,
                                    category: category,
                                    accessLevel: accessPermission,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  await _loadPasswords();
                                } catch (e) {
                                  debugPrint('Save password notice: $e');
                                  setModalState(() {
                                    saving = false;
                                    formError = "Couldn't save the password. Please try again.";
                                  });
                                }
                              },
                        child: saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Save Password to Vault', style: AnchorTypography.buttonText),
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
        : _passwords.where((p) => p.category == _selectedCategory).toList();

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AnchorColors.primaryNavy))
                : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 54, color: AnchorColors.textMuted),
                        const SizedBox(height: 12),
                        Text(_loadError!, style: AnchorTypography.titleMedium),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _loadPasswords, child: Text('Retry', style: AnchorTypography.buttonText)),
                      ],
                    ),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.key_off_outlined, size: 54, color: AnchorColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No passwords saved yet', style: AnchorTypography.titleMedium),
                        const SizedBox(height: 6),
                        Text('Tap Add Password to save your first one', style: AnchorTypography.bodySmall),
                      ],
                    ),
                  )
                : ListView.separated(
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
                            child: Icon(_iconFor(pwd.category), color: AnchorColors.primaryNavy, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pwd.websiteTitle, style: AnchorTypography.titleSmall),
                                const SizedBox(height: 2),
                                Text(
                                  [if (pwd.username.isNotEmpty) pwd.username, 'Shared: ${pwd.accessLevel}'].join(' • '),
                                  style: AnchorTypography.bodySmall,
                                ),
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
                              pwd.strengthLabel,
                              style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.statusMint, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy password',
                            icon: const Icon(Icons.copy_outlined, size: 20, color: AnchorColors.primaryNavy),
                            onPressed: () => _copyPassword(pwd),
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
