import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/security/biometric_service.dart';
import '../../core/security/key_hierarchy_manager.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../shared/widgets/anchor_logo_header.dart';
import '../vault_setup/add_family_members_screen.dart';
import 'auth_screen.dart';

class MasterPasswordScreen extends StatefulWidget {
  final String vaultName;

  const MasterPasswordScreen({
    Key? key,
    this.vaultName = 'Shah Family',
  }) : super(key: key);

  @override
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isFirstTime = true;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkVaultState();
  }

  void _checkVaultState() async {
    final exists = await KeyHierarchyManager().hasExistingVault();
    if (mounted) {
      setState(() {
        _isFirstTime = !exists;
        _isLoading = false;
      });
    }
  }

  void _handleSubmit() async {
    final pwd = _passwordController.text;

    if (pwd.isEmpty) {
      setState(() => _errorMessage = 'Please enter a Master Password.');
      return;
    }

    if (_isFirstTime) {
      final confirm = _confirmController.text;
      if (pwd.length < 6) {
        setState(() => _errorMessage = 'Master Password should be at least 6 characters.');
        return;
      }
      if (pwd != confirm) {
        setState(() => _errorMessage = 'Passwords do not match.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isFirstTime) {
        final recoveryKey = await KeyHierarchyManager().setupNewVault(pwd);
        if (!mounted) return;
        setState(() => _isLoading = false);

        await _showRecoveryKeyDialog(recoveryKey);
      } else {
        final success = await KeyHierarchyManager().unlockVault(pwd);
        if (!success) {
          await KeyHierarchyManager().setupNewVault(pwd);
        }
      }

      if (!mounted) return;

      // Ask for Biometric authentication enrollment
      await BiometricService().authenticateWithBiometrics(
        reason: 'Enable biometric unlock for your Anchor vault',
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AddFamilyMembersScreen(vaultName: widget.vaultName),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error setting up Master Password.';
        });
      }
    }
  }

  Future<void> _showRecoveryKeyDialog(String recoveryKey) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AnchorColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Vault Recovery Key', style: AnchorTypography.headlineMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save this 16-character recovery key in a safe offline location. If you lose your master password, Anchor cannot decrypt your vault without it.',
                style: AnchorTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AnchorColors.bgWarmCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AnchorColors.borderSand),
                ),
                child: SelectableText(
                  recoveryKey,
                  textAlign: TextAlign.center,
                  style: AnchorTypography.titleMedium.copyWith(
                    color: AnchorColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('I Have Saved It', style: AnchorTypography.buttonText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AnchorColors.bgWarmCream,
        body: Center(
          child: CircularProgressIndicator(color: AnchorColors.primaryNavy),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnchorLogoHeader(size: 85.0),
                const SizedBox(height: 28),

                Text(
                  _isFirstTime ? 'Set Master Password' : 'Unlock Family Vault',
                  style: AnchorTypography.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _isFirstTime
                      ? 'Google Sign-In verifies your identity. Your Anchor Master Password protects the encrypted contents of your ${widget.vaultName} vault.'
                      : 'Enter your Master Password to decrypt your zero-knowledge family vault.',
                  textAlign: TextAlign.center,
                  style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
                ),
                const SizedBox(height: 28),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AnchorTypography.bodyLarge,
                  decoration: InputDecoration(
                    labelText: _isFirstTime ? 'Set Master Password' : 'Master Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AnchorColors.primaryNavy),
                  ),
                ),

                if (_isFirstTime) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    style: AnchorTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Master Password',
                      prefixIcon: Icon(Icons.lock_reset_outlined, color: AnchorColors.primaryNavy),
                    ),
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text(
                      _isFirstTime ? 'Encrypt Vault & Continue' : 'Unlock Vault',
                      style: AnchorTypography.buttonText,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _isFirstTime = !_isFirstTime;
                      _errorMessage = null;
                      _passwordController.clear();
                      _confirmController.clear();
                    });
                  },
                  child: Text(
                    _isFirstTime
                        ? 'Already created a vault? Unlock Vault'
                        : 'First time user or forgot password? Create New Vault',
                    style: AnchorTypography.bodyMedium.copyWith(
                      color: AnchorColors.ceruleanTeal,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AnchorColors.statusMint),
                    const SizedBox(width: 6),
                    Text(
                      'AES-256-GCM Zero-Knowledge Encryption',
                      style: AnchorTypography.bodySmall.copyWith(
                        color: AnchorColors.statusMint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 18, color: AnchorColors.textSecondary),
                  label: Text(
                    'Sign Out / Switch Account',
                    style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
