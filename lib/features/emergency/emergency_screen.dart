import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _shareInsuranceInEmergency = true;
  bool _sharePropertyDocsInEmergency = true;
  bool _shareFamilyOttPasswords = true;
  bool _sharePersonalBankAccounts = false;

  final List<Map<String, String>> _emergencyContacts = [
    {'name': 'Dr. Rajesh Shah', 'relation': 'Family Doctor', 'phone': '+91 98201 92810'},
    {'name': 'Advocate Malhotra', 'relation': 'Legal Advisor', 'phone': '+91 98190 39201'},
  ];

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AnchorColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Emergency Contact', style: AnchorTypography.headlineMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: AnchorTypography.bodyLarge, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 12),
              TextField(controller: relCtrl, style: AnchorTypography.bodyLarge, decoration: const InputDecoration(labelText: 'Relationship / Role')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, style: AnchorTypography.bodyLarge, decoration: const InputDecoration(labelText: 'Phone Number')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: AnchorTypography.bodyMedium)),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _emergencyContacts.add({
                      'name': nameCtrl.text,
                      'relation': relCtrl.text.isNotEmpty ? relCtrl.text : 'Emergency Contact',
                      'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '+91 98000 00000',
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: Text('Save Contact', style: AnchorTypography.buttonText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Emergency & Digital Legacy', style: AnchorTypography.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnchorColors.alertCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.alertCoral.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AnchorColors.alertCoral, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Access Ready', style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.alertCoral)),
                        const SizedBox(height: 2),
                        Text(
                          'Keep critical medical notes, blood group, and emergency access permissions ready when it matters most.',
                          style: AnchorTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Contacts Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Emergency Contacts', style: AnchorTypography.titleMedium),
                IconButton(icon: const Icon(Icons.add_circle_outline, color: AnchorColors.primaryNavy), onPressed: _showAddContactDialog),
              ],
            ),
            const SizedBox(height: 8),

            ..._emergencyContacts.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AnchorColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AnchorColors.borderSand),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AnchorColors.bgWarmCream,
                      child: Icon(Icons.phone_in_talk_outlined, color: AnchorColors.primaryNavy, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name']!, style: AnchorTypography.titleSmall),
                          Text('${c['relation']!} • ${c['phone']!}', style: AnchorTypography.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.call, color: AnchorColors.statusMint, size: 20),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Digital Legacy Preferences
            Text('Digital Legacy Controls', style: AnchorTypography.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Specify what items will be made accessible to designated emergency contacts in a verified legacy scenario.',
              style: AnchorTypography.bodySmall,
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AnchorColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.borderSand),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AnchorColors.primaryNavy,
                    title: Text('Share Health & Insurance Documents', style: AnchorTypography.titleSmall),
                    subtitle: Text('Allows emergency access to health policies & medical records', style: AnchorTypography.bodySmall),
                    value: _shareInsuranceInEmergency,
                    onChanged: (val) => setState(() => _shareInsuranceInEmergency = val),
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  SwitchListTile(
                    activeColor: AnchorColors.primaryNavy,
                    title: Text('Share Property Deeds & Agreements', style: AnchorTypography.titleSmall),
                    subtitle: Text('Grants legacy access to legal real estate deeds', style: AnchorTypography.bodySmall),
                    value: _sharePropertyDocsInEmergency,
                    onChanged: (val) => setState(() => _sharePropertyDocsInEmergency = val),
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  SwitchListTile(
                    activeColor: AnchorColors.primaryNavy,
                    title: Text('Share Family OTT & Utility Credentials', style: AnchorTypography.titleSmall),
                    subtitle: Text('Shares family logins (Netflix, Wi-Fi, Prime)', style: AnchorTypography.bodySmall),
                    value: _shareFamilyOttPasswords,
                    onChanged: (val) => setState(() => _shareFamilyOttPasswords = val),
                  ),
                  const Divider(color: AnchorColors.borderSand, height: 1),
                  SwitchListTile(
                    activeColor: AnchorColors.primaryNavy,
                    title: Text('Share Personal Banking Credentials', style: AnchorTypography.titleSmall),
                    subtitle: Text('Strictly restricted unless verified by 2 legal admins', style: AnchorTypography.bodySmall),
                    value: _sharePersonalBankAccounts,
                    onChanged: (val) => setState(() => _sharePersonalBankAccounts = val),
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
