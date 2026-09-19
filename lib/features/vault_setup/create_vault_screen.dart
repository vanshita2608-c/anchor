import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../shared/widgets/anchor_logo_header.dart';
import '../auth/master_password_screen.dart';

class CreateVaultScreen extends StatefulWidget {
  const CreateVaultScreen({Key? key}) : super(key: key);

  @override
  State<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends State<CreateVaultScreen> {
  final TextEditingController _vaultNameController = TextEditingController(text: 'Shah Family');
  final List<String> _suggestions = ['Shah Family', 'My Family', 'Home Vault', 'Our Family', 'Personal Vault'];

  @override
  void dispose() {
    _vaultNameController.dispose();
    super.dispose();
  }

  void _submitVault() {
    final name = _vaultNameController.text.trim();
    if (name.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MasterPasswordScreen(vaultName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const AnchorLogoHeader(size: 90.0),
              const SizedBox(height: 32),

              Text('Create Your Vault', style: AnchorTypography.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Give your family workspace a name. As the vault creator, you are assigned as the Owner with full security control.',
                textAlign: TextAlign.center,
                style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
              ),
              const SizedBox(height: 36),

              // Vault Name Input
              TextField(
                controller: _vaultNameController,
                style: AnchorTypography.titleLarge,
                decoration: InputDecoration(
                  labelText: 'Vault Name',
                  hintText: 'e.g. Shah Family',
                  prefixIcon: const Icon(Icons.shield_outlined, color: AnchorColors.primaryNavy),
                ),
              ),
              const SizedBox(height: 16),

              // Suggestion Chips
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Suggested Names', style: AnchorTypography.labelMedium),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((s) {
                  return ActionChip(
                    backgroundColor: AnchorColors.cardWhite,
                    side: const BorderSide(color: AnchorColors.borderSand),
                    label: Text(s, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.primaryNavy)),
                    onPressed: () {
                      setState(() {
                        _vaultNameController.text = s;
                      });
                    },
                  );
                }).toList(),
              ),

              const Spacer(),

              // Create Vault Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitVault,
                  child: Text('Create Vault & Set Master Password', style: AnchorTypography.buttonText),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
