import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../core/models/family_member.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  final List<FamilyMember> _members = const [
    FamilyMember(id: 'm1', fullName: 'Rajesh Shah', email: 'rajesh@shah.com', role: 'OWNER'),
    FamilyMember(id: 'm2', fullName: 'Sunita Shah', email: 'sunita@shah.com', role: 'ADMIN'),
    FamilyMember(id: 'm3', fullName: 'Vanshita Shah', email: 'vanshita@shah.com', role: 'MEMBER'),
    FamilyMember(id: 'm4', fullName: 'Rohan Shah', email: 'rohan@shah.com', role: 'MEMBER'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Family Access', style: AnchorTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AnchorColors.primaryNavy),
            onPressed: () => _showInviteModal(context),
            tooltip: 'Invite Family Member',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Family Banner Card
          Card(
            color: AnchorColors.navySurface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AnchorColors.ceruleanTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.groups_rounded, color: AnchorColors.ceruleanLight, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shah Family Vault', style: AnchorTypography.titleLarge.copyWith(color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('4 Active Members • 3 Shared Vault Items', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.textDarkSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AnchorColors.borderDarkNavy),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Invitation Code: AN-SHAH-9982', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.ceruleanLight, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('Family Members (${_members.length})', style: AnchorTypography.headlineMedium),
          const SizedBox(height: 12),

          ..._members.map((member) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: AnchorColors.ceruleanTint,
                child: Text(
                  member.fullName[0],
                  style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.primaryNavy),
                ),
              ),
              title: Text(member.fullName, style: AnchorTypography.titleMedium),
              subtitle: Text(member.email, style: AnchorTypography.bodySmall),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: member.role == 'OWNER' ? AnchorColors.primaryNavy : AnchorColors.bgWarmCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AnchorColors.borderSand),
                ),
                child: Text(
                  member.role,
                  style: AnchorTypography.bodySmall.copyWith(
                    color: member.role == 'OWNER' ? Colors.white : AnchorColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showInviteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AnchorColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite Family Member', style: AnchorTypography.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Each member receives an individual key-sharing wrapper. They will only see items explicitly shared with them.',
                style: AnchorTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Family Member Email')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Send Secure Invitation Link', style: AnchorTypography.buttonText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
