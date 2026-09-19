import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../vault_setup/add_family_members_screen.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _members = const [
    {'name': 'Vanshita Shah', 'email': 'vanshitashah848@gmail.com', 'relation': 'Owner', 'role': 'Owner'},
    {'name': 'Sunita Shah', 'email': 'sunita.shah@gmail.com', 'relation': 'Mother', 'role': 'Admin'},
    {'name': 'Rajesh Shah', 'email': 'rajesh.shah@gmail.com', 'relation': 'Father', 'role': 'Admin'},
    {'name': 'Ananya Shah', 'email': 'ananya.shah@gmail.com', 'relation': 'Sister', 'role': 'Member'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Family Workspace', style: AnchorTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AnchorColors.primaryNavy),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFamilyMembersScreen()));
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
                        Text('Shah Family Vault', style: AnchorTypography.headlineMedium),
                        const SizedBox(height: 2),
                        Text('4 Active Vault Members', style: AnchorTypography.bodySmall),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite link copied: anchor://invite/shah-family'), backgroundColor: AnchorColors.primaryNavy),
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

            ..._members.map((m) {
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
                      child: Text(m['name']![0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['name']!, style: AnchorTypography.titleSmall),
                          Text('${m['relation']} • ${m['email']}', style: AnchorTypography.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AnchorColors.bgWarmCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m['role']!, style: AnchorTypography.labelMedium.copyWith(color: AnchorColors.ceruleanTeal)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
