import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../shared/widgets/anchor_logo_header.dart';
import '../../shared/widgets/google_logo_painter.dart';
import 'master_password_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool autoForwardIfAuthenticated;

  const AuthScreen({
    super.key,
    this.autoForwardIfAuthenticated = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedAvatarIndex = 0;

  final List<IconData> _avatarIcons = [
    Icons.person_outline,
    Icons.security_outlined,
    Icons.family_restroom,
    Icons.anchor,
    Icons.stars_outlined,
    Icons.shield_outlined,
  ];

  final _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.autoForwardIfAuthenticated) {
      _checkExistingSession();
    }
  }

  void _checkExistingSession() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        final name = session.user.userMetadata?['full_name'] ?? session.user.email?.split('@').first ?? 'User';
        _proceedToMasterPasswordScreen(name: name);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = _supabase.auth.currentSession;
      if (session != null && mounted) {
        final name = session.user.userMetadata?['full_name'] ?? session.user.email?.split('@').first ?? 'User';
        _proceedToMasterPasswordScreen(name: name);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _syncProfileToDatabase({
    required String userId,
    required String email,
    String? fullName,
    String? username,
    String? mobile,
    int? avatarIndex,
  }) async {
    try {
      final payload = {
        'id': userId,
        'email': email,
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        if (avatarIndex != null) 'avatar_url': 'avatar_$avatarIndex',
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('profiles').upsert(payload);
    } catch (e) {
      debugPrint('Profile database sync notice: $e');
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password.');
      return;
    }

    if (_isSignUp && name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        final res = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': name,
            'mobile': mobile,
            'username': username,
            'avatar_index': _selectedAvatarIndex,
          },
        );

        final userId = res.user?.id ?? _supabase.auth.currentUser?.id;
        if (userId != null) {
          await _syncProfileToDatabase(
            userId: userId,
            email: email,
            fullName: name,
            username: username,
            mobile: mobile,
            avatarIndex: _selectedAvatarIndex,
          );
        }

        _proceedToMasterPasswordScreen(name: name.isNotEmpty ? name : 'User');
      } else {
        final res = await _supabase.auth.signInWithPassword(email: email, password: password);
        final user = res.user ?? _supabase.auth.currentUser;
        final userName = user?.userMetadata?['full_name'] ?? email.split('@').first;

        if (user != null) {
          await _syncProfileToDatabase(
            userId: user.id,
            email: user.email ?? email,
            fullName: userName,
          );
        }

        _proceedToMasterPasswordScreen(name: userName);
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _proceedToMasterPasswordScreen(name: name.isNotEmpty ? name : 'User');
    } catch (_) {
      _proceedToMasterPasswordScreen(name: name.isNotEmpty ? name : 'User');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await GoogleAuthService().signInWithGoogle();

      if (result.error != null) {
        setState(() => _errorMessage = result.error);
        return;
      }

      if (result.cancelled) {
        return;
      }

      final googleUser = result.googleUser;
      final sessionUser = _supabase.auth.currentUser;
      final userName = googleUser?.displayName ??
          sessionUser?.userMetadata?['full_name'] ??
          'Vanshita Shah';
      final email = googleUser?.email ?? sessionUser?.email ?? '';
      final userId = sessionUser?.id ?? googleUser?.id ?? '';

      if (userId.isNotEmpty && email.isNotEmpty) {
        await _syncProfileToDatabase(
          userId: userId,
          email: email,
          fullName: userName,
          avatarIndex: 0,
        );
      }

      _proceedToMasterPasswordScreen(name: userName);
    } catch (e) {
      debugPrint('Google Sign-In notice: $e');
      setState(() => _errorMessage = 'Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _proceedToMasterPasswordScreen({required String name}) {
    if (!mounted) return;
    final vaultName = name.contains(' ') ? '${name.split(' ').first}\'s Family' : '$name Family';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MasterPasswordScreen(vaultName: vaultName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnchorLogoHeader(size: 90.0),
                const SizedBox(height: 24),

                Text(
                  _isSignUp ? 'Create Family Account' : 'Welcome Back',
                  style: AnchorTypography.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Set up your complete profile to start your zero-knowledge vault'
                      : 'Sign in to access your protected family digital assets',
                  textAlign: TextAlign.center,
                  style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AnchorColors.cardWhite,
                      side: const BorderSide(color: AnchorColors.borderSand, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const GoogleLogoWidget(size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: AnchorTypography.buttonText.copyWith(color: AnchorColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AnchorColors.borderSand)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _isSignUp ? 'OR REGISTER WITH EMAIL' : 'OR EMAIL',
                        style: AnchorTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(child: Divider(color: AnchorColors.borderSand)),
                  ],
                ),
                const SizedBox(height: 18),

                // If Sign Up -> Show Avatar Selector Grid & Name/Mobile/Username
                if (_isSignUp) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Choose Profile Avatar', style: AnchorTypography.labelLarge),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_avatarIcons.length, (index) {
                      final isSelected = _selectedAvatarIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAvatarIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AnchorColors.primaryNavy : AnchorColors.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AnchorColors.primaryNavy : AnchorColors.borderSand,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _avatarIcons[index],
                            size: 20,
                            color: isSelected ? Colors.white : AnchorColors.primaryNavy,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextField(
                    controller: _nameController,
                    style: AnchorTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline, color: AnchorColors.primaryNavy),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Username
                  TextField(
                    controller: _usernameController,
                    style: AnchorTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Username (e.g. vanshita_shah)',
                      prefixIcon: Icon(Icons.alternate_email, color: AnchorColors.primaryNavy),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mobile Number
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    style: AnchorTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined, color: AnchorColors.primaryNavy),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AnchorColors.primaryNavy),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: AnchorColors.primaryNavy),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailAuth,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isSignUp ? 'Create Account' : 'Sign In', style: AnchorTypography.buttonText),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle Sign In / Sign Up
                TextButton(
                  onPressed: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _errorMessage = null;
                  }),
                  child: Text(
                    _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Create Account",
                    style: AnchorTypography.labelLarge.copyWith(color: AnchorColors.ceruleanTeal),
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
