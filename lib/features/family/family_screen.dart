import 'package:flutter/material.dart';
import '../../core/services/family_service.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../vault_setup/add_family_members_screen.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final FamilyService _familyService = FamilyService();

  @override
  void initState() {
    super.initState();
    _familyService.initializeOwner();
    _familyService.load().catchError((Object e) {
      debugPrint('Family load notice: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _familyService,
      builder: (context, _) {
        final members = _familyService.members;
        final vaultName = _familyService.vaultName;
        final count = _familyService.memberCount;

        return Scaffold(
          backgroundColor: AnchorColors.bgWarmCream,
          appBar: AppBar(
            title: Text('Family Workspace', style: AnchorTypography.headlineLarge),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined, color: AnchorColors.primaryNavy),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFamilyMembersScreen()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vault Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AnchorColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AnchorColors.borderSand),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AnchorColors.bgWarmCream,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield, color: AnchorColors.primaryNavy, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vaultName, style: AnchorTypography.headlineMedium),
                            const SizedBox(height: 2),
                            Text('$count Active Vault Member${count == 1 ? '' : 's'}', style: AnchorTypography.bodySmall),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invite link copied: anchor://invite/${vaultName.toLowerCase().replaceAll(' ', '-')}'),
                              backgroundColor: AnchorColors.primaryNavy,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                        child: Text('Invite Link', style: AnchorTypography.buttonText.copyWith(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Members & Roles', style: AnchorTypography.titleMedium),
                const SizedBox(height: 12),

                ...members.map((m) {
                  final initial = (m['name'] != null && m['name']!.isNotEmpty)
                      ? m['name']![0].toUpperCase()
                      : 'U';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AnchorColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AnchorColors.borderSand),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AnchorColors.primaryNavy,
                          child: Text(
                            initial,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['name'] ?? 'User', style: AnchorTypography.titleSmall),
                              Text('${m['relation'] ?? ''} • ${m['email'] ?? ''}', style: AnchorTypography.bodySmall),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AnchorColors.bgWarmCream,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            m['role'] ?? 'Member',
                            style: AnchorTypography.labelMedium.copyWith(color: AnchorColors.ceruleanTeal),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
