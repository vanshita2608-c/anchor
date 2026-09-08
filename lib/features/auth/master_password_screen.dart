import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../core/security/key_hierarchy_manager.dart';
import '../../shared/widgets/anchor_logo_header.dart';
import '../../shared/widgets/anchor_nav_shell.dart';

class MasterPasswordScreen extends StatefulWidget {
  const MasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final _passwordController = TextEditingController(text: 'AnchorDemo2026!');
  bool _isLoading = false;
  String? _errorMessage;

  void _handleUnlock() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulated Vault Key derivation & AES-256 key unwrap
    await Future.delayed(const Duration(milliseconds: 600));
    await KeyHierarchyManager().setupNewVault(_passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AnchorNavShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnchorLogoHeader(size: 80.0),
                const SizedBox(height: 36),

                Text(
                  'Unlock Family Vault',
                  style: AnchorTypography.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your Master Password to decrypt your zero-knowledge vault.',
                  textAlign: TextAlign.center,
                  style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // Master Password Input Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AnchorTypography.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AnchorColors.primaryNavy),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.fingerprint, color: AnchorColors.ceruleanTeal, size: 28),
                      onPressed: _handleUnlock,
                      tooltip: 'Unlock with Biometrics',
                    ),
                  ),
                ),

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
                    onPressed: _isLoading ? null : _handleUnlock,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Unlock Vault', style: AnchorTypography.buttonText),
                  ),
                ),

                const SizedBox(height: 20),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
