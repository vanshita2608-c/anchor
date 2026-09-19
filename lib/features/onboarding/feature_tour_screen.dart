import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../vault_setup/create_vault_screen.dart';

class TourStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<String> bulletPoints;

  TourStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.bulletPoints,
  });
}

class FeatureTourScreen extends StatefulWidget {
  const FeatureTourScreen({Key? key}) : super(key: key);

  @override
  State<FeatureTourScreen> createState() => _FeatureTourScreenState();
}

class _FeatureTourScreenState extends State<FeatureTourScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<TourStep> _steps = [
    TourStep(
      title: 'Your Family Vault',
      subtitle: 'STEP 1 OF 7',
      description: 'Create a private, zero-knowledge space for your family to securely organize important digital records.',
      icon: Icons.shield,
      bulletPoints: [
        'Single encrypted workspace for your family',
        'AES-256-GCM zero-knowledge security',
        'You maintain full ownership of all encryption keys',
      ],
    ),
    TourStep(
      title: 'Documents',
      subtitle: 'STEP 2 OF 7',
      description: 'Store Aadhaar cards, passports, insurance policies, tax returns, property deeds, and medical files safely.',
      icon: Icons.folder_special_outlined,
      bulletPoints: [
        'Organized into 6 smart categories',
        'Upload PDFs, photos, or official certificates',
        'Encrypted before leaving your device',
      ],
    ),
    TourStep(
      title: 'Passwords',
      subtitle: 'STEP 3 OF 7',
      description: 'Securely manage shared family passwords for OTT streaming, Wi-Fi networks, utilities, and banking.',
      icon: Icons.key_outlined,
      bulletPoints: [
        'Netflix, Prime, Spotify, Wi-Fi & banking logins',
        'Built-in secure password generator',
        'Password strength and vulnerability scanner',
      ],
    ),
    TourStep(
      title: 'Scan & OCR',
      subtitle: 'STEP 4 OF 7',
      description: 'Take a photo of physical documents and Anchor will extract text, names, and policy details automatically.',
      icon: Icons.document_scanner,
      bulletPoints: [
        'Camera capture → Auto-crop → OCR extraction',
        'Review extracted info before saving',
        'Instant searchable document metadata',
      ],
    ),
    TourStep(
      title: 'Family Sharing',
      subtitle: 'STEP 5 OF 7',
      description: 'Add trusted family members with granular role-based permissions (Owner, Admin, Member, Viewer).',
      icon: Icons.people_outline,
      bulletPoints: [
        'Invite via email or secure invite link',
        'Specify who can access each document or password',
        'Revoke or update permissions anytime',
      ],
    ),
    TourStep(
      title: 'Smart Reminders',
      subtitle: 'STEP 6 OF 7',
      description: 'Keep track of upcoming document expiration dates, insurance renewals, and warranty milestones.',
      icon: Icons.alarm_on_outlined,
      bulletPoints: [
        'Passport & Driving License expiry alerts',
        'Insurance policy renewal notifications',
        'Customizable alert timing (90d, 30d, 7d)',
      ],
    ),
    TourStep(
      title: 'Emergency Access',
      subtitle: 'STEP 7 OF 7',
      description: 'Ensure critical medical instructions, blood group info, and key document access are ready when needed.',
      icon: Icons.health_and_safety_outlined,
      bulletPoints: [
        'Designate emergency contacts',
        'Configure Digital Legacy preferences',
        'Audit-logged emergency access protocols',
      ],
    ),
  ];

  void _nextPage() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTour();
    }
  }

  void _completeTour() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateVaultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Anchor Tour', style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.primaryNavy)),
                  TextButton(
                    onPressed: _completeTour,
                    child: Text('Skip', style: AnchorTypography.labelLarge.copyWith(color: AnchorColors.ceruleanTeal)),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AnchorColors.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: AnchorColors.borderSand, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(step.icon, size: 54, color: AnchorColors.primaryNavy),
                        ),
                        const SizedBox(height: 28),

                        Text(
                          step.subtitle,
                          style: AnchorTypography.bodySmall.copyWith(
                            color: AnchorColors.ceruleanTeal,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: AnchorTypography.displayMedium,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
                        ),
                        const SizedBox(height: 28),

                        // Bullet Points Container
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AnchorColors.cardWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AnchorColors.borderSand),
                          ),
                          child: Column(
                            children: step.bulletPoints.map((point) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: AnchorColors.statusMint, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(point, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.textPrimary)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (index) {
                      final isSelected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? AnchorColors.primaryNavy : AnchorColors.borderSand,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentIndex == _steps.length - 1 ? 'Ready to Build My Vault' : 'Next Step',
                        style: AnchorTypography.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
