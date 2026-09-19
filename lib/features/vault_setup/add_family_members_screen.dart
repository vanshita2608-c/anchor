import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../shared/widgets/anchor_nav_shell.dart';

class AddFamilyMembersScreen extends StatefulWidget {
  final String vaultName;

  const AddFamilyMembersScreen({
    Key? key,
    this.vaultName = 'Shah Family',
  }) : super(key: key);

  @override
  State<AddFamilyMembersScreen> createState() => _AddFamilyMembersScreenState();
}

class _AddFamilyMembersScreenState extends State<AddFamilyMembersScreen> {
  final List<Map<String, String>> _members = [
    {'name': 'Vanshita Shah', 'email': 'vanshitashah848@gmail.com', 'relation': 'Owner', 'role': 'Owner'},
  ];

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _selectedRelation = 'Mother';
  String _selectedRole = 'Member';

  final List<String> _relations = ['Mother', 'Father', 'Sister', 'Brother', 'Spouse', 'Child', 'Other'];
  final List<String> _roles = ['Admin', 'Member', 'Viewer', 'Emergency Contact'];

  void _addMember() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) return;

    setState(() {
      _members.add({
        'name': name,
        'email': email,
        'relation': _selectedRelation,
        'role': _selectedRole,
      });
      _nameCtrl.clear();
      _emailCtrl.clear();
    });

    Navigator.pop(context);
  }

  void _showAddDialog() {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Family Member', style: AnchorTypography.headlineMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    style: AnchorTypography.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    style: AnchorTypography.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedRelation,
                    decoration: const InputDecoration(labelText: 'Relationship'),
                    items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setModalState(() => _selectedRelation = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Vault Role'),
                    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setModalState(() => _selectedRole = val!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _addMember();
                      },
                      child: Text('Add to Vault', style: AnchorTypography.buttonText),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Build Your Family Vault', style: AnchorTypography.displayMedium),
              const SizedBox(height: 6),
              Text(
                'Add trusted family members to ${widget.vaultName}. You can control role permissions for each member.',
                style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textSecondary),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.separated(
                  itemCount: _members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AnchorColors.cardWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AnchorColors.borderSand),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AnchorColors.primaryNavy,
                            child: Text(
                              member['name']![0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member['name']!, style: AnchorTypography.titleMedium),
                                Text('${member['email']!} • ${member['relation']!}', style: AnchorTypography.bodySmall),
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
                              member['role']!,
                              style: AnchorTypography.labelMedium.copyWith(color: AnchorColors.ceruleanTeal),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              OutlinedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, color: AnchorColors.primaryNavy),
                label: Text('Add Another Member', style: AnchorTypography.buttonText.copyWith(color: AnchorColors.primaryNavy)),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AnchorNavShell()),
                      (route) => false,
                    );
                  },
                  child: Text('Complete Setup & Open Dashboard', style: AnchorTypography.buttonText),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
