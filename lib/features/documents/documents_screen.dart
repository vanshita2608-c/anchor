import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class DocumentsScreen extends StatefulWidget {
  final bool initialScan;

  const DocumentsScreen({
    Key? key,
    this.initialScan = false,
  }) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Identity',
    'Financial & Legal',
    'Education',
    'Medical',
    'Household',
  ];

  final List<Map<String, dynamic>> _documents = [
    {
      'title': 'Indian Passport (Vanshita Shah)',
      'category': 'Identity',
      'id_number': 'J82930192',
      'expiry': '14 Feb 2027',
      'expiring_soon': true,
      'icon': Icons.badge_outlined,
    },
    {
      'title': 'Aadhaar Card (Family)',
      'category': 'Identity',
      'id_number': 'XXXX-XXXX-9281',
      'expiry': 'N/A',
      'expiring_soon': false,
      'icon': Icons.fingerprint,
    },
    {
      'title': 'HDFC Health Insurance Policy',
      'category': 'Financial & Legal',
      'id_number': 'POL-9281920',
      'expiry': '18 Oct 2026',
      'expiring_soon': true,
      'icon': Icons.medical_services_outlined,
    },
    {
      'title': 'Property Deed (Bandra Flat)',
      'category': 'Financial & Legal',
      'id_number': 'REG-2021-99',
      'expiry': 'N/A',
      'expiring_soon': false,
      'icon': Icons.home_work_outlined,
    },
    {
      'title': 'Degree Certificate (B.Tech)',
      'category': 'Education',
      'id_number': 'DEG-92810',
      'expiry': 'N/A',
      'expiring_soon': false,
      'icon': Icons.school_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOCRScanModal();
      });
    }
  }

  void _showAddDocumentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AnchorColors.cardWhite,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Document to Vault', style: AnchorTypography.headlineMedium),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AnchorColors.primaryNavy),
                title: Text('Scan Document with Camera (OCR)', style: AnchorTypography.titleSmall),
                subtitle: Text('Auto-extract names, numbers & expiry dates', style: AnchorTypography.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _showOCRScanModal();
                },
              ),
              const Divider(color: AnchorColors.borderSand),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined, color: AnchorColors.ceruleanTeal),
                title: Text('Upload PDF or Image File', style: AnchorTypography.titleSmall),
                subtitle: Text('Upload files directly from device storage', style: AnchorTypography.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _showManualAddDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOCRScanModal() {
    final titleCtrl = TextEditingController(text: 'Scan Results: Car Insurance Policy');
    final nameCtrl = TextEditingController(text: 'Vanshita Shah');
    final idCtrl = TextEditingController(text: 'POL-3920192');
    final expiryCtrl = TextEditingController(text: '12 March 2027');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AnchorColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.document_scanner, color: AnchorColors.statusMint),
              const SizedBox(width: 10),
              Text('OCR Scan Results', style: AnchorTypography.headlineMedium),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anchor OCR extracted useful metadata from your scanned document. Please review before saving.',
                  style: AnchorTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Document Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Document Holder'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Policy / Document Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expiryCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.alertCoral)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _documents.insert(0, {
                    'title': titleCtrl.text,
                    'category': 'Financial & Legal',
                    'id_number': idCtrl.text,
                    'expiry': expiryCtrl.text,
                    'expiring_soon': true,
                    'icon': Icons.directions_car_outlined,
                  });
                });
                Navigator.pop(ctx);
              },
              child: Text('Save to Vault', style: AnchorTypography.buttonText),
            ),
          ],
        );
      },
    );
  }

  void _showManualAddDialog() {
    final titleCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AnchorColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add New Document', style: AnchorTypography.headlineMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Document Title (e.g. Birth Certificate)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'ID / Reference Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expiryCtrl,
                  style: AnchorTypography.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Expiry Date (Optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AnchorTypography.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  setState(() {
                    _documents.insert(0, {
                      'title': titleCtrl.text,
                      'category': _selectedCategory == 'All' ? 'Identity' : _selectedCategory,
                      'id_number': idCtrl.text.isNotEmpty ? idCtrl.text : 'REF-9201',
                      'expiry': expiryCtrl.text.isNotEmpty ? expiryCtrl.text : 'N/A',
                      'expiring_soon': false,
                      'icon': Icons.description_outlined,
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: Text('Save Document', style: AnchorTypography.buttonText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _documents
        : _documents.where((d) => d['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('Document Vault', style: AnchorTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AnchorColors.primaryNavy),
            onPressed: _showAddDocumentSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat, style: AnchorTypography.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AnchorColors.primaryNavy,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    selected: isSelected,
                    selectedColor: AnchorColors.primaryNavy,
                    backgroundColor: AnchorColors.cardWhite,
                    side: const BorderSide(color: AnchorColors.borderSand),
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // Document List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open_outlined, size: 54, color: AnchorColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No documents in $_selectedCategory', style: AnchorTypography.titleMedium),
                        const SizedBox(height: 6),
                        Text('Tap + to add your first document', style: AnchorTypography.bodySmall),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AnchorColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AnchorColors.borderSand),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AnchorColors.bgWarmCream,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(doc['icon'] as IconData, color: AnchorColors.primaryNavy, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc['title'] as String, style: AnchorTypography.titleSmall),
                                  const SizedBox(height: 2),
                                  Text('ID: ${doc['id_number']} • Expiry: ${doc['expiry']}', style: AnchorTypography.bodySmall),
                                ],
                              ),
                            ),
                            if (doc['expiring_soon'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AnchorColors.alertCoral.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Alert', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AnchorColors.primaryNavy,
        onPressed: _showAddDocumentSheet,
        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
        label: Text('Scan Document', style: AnchorTypography.buttonText),
      ),
    );
  }
}
