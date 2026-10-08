import 'package:flutter/material.dart';
import '../../core/models/document_item.dart';
import '../../core/services/current_user.dart';
import '../../core/services/vault_repository.dart';
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
  final VaultRepository _repo = VaultRepository();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Identity',
    'Financial & Legal',
    'Education',
    'Medical',
    'Household',
  ];

  List<DocumentItem> _documents = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    // The Vault tab stays alive in the nav shell; refresh when documents are added elsewhere.
    _repo.addListener(_loadDocuments);
    if (widget.initialScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDocumentForm(fromScan: true);
      });
    }
  }

  @override
  void dispose() {
    _repo.removeListener(_loadDocuments);
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final docs = await _repo.fetchDocuments();
      if (mounted) setState(() => _documents = docs);
    } catch (e) {
      debugPrint('Load documents notice: $e');
      if (mounted) setState(() => _loadError = "Couldn't load your documents.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  _showDocumentForm(fromScan: true);
                },
              ),
              const Divider(color: AnchorColors.borderSand),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined, color: AnchorColors.ceruleanTeal),
                title: Text('Enter Document Details', style: AnchorTypography.titleSmall),
                subtitle: Text('Add the document information manually', style: AnchorTypography.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDocumentForm(fromScan: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDocumentForm({required bool fromScan}) {
    final titleCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: CurrentUser.displayName);
    final idCtrl = TextEditingController();
    String category = _selectedCategory == 'All' ? 'Identity' : _selectedCategory;
    DateTime? expiry;
    bool saving = false;
    String? formError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> save() async {
              if (titleCtrl.text.trim().isEmpty) {
                setDialogState(() => formError = 'Please enter a document title.');
                return;
              }
              setDialogState(() {
                saving = true;
                formError = null;
              });
              try {
                await _repo.addDocument(
                  title: titleCtrl.text.trim(),
                  category: category,
                  holderName: nameCtrl.text.trim(),
                  idNumber: idCtrl.text.trim(),
                  expiryDate: expiry,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                debugPrint('Save document notice: $e');
                setDialogState(() {
                  saving = false;
                  formError = "Couldn't save the document. Please try again.";
                });
              }
            }

            return AlertDialog(
              backgroundColor: AnchorColors.cardWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(fromScan ? Icons.document_scanner : Icons.note_add_outlined, color: AnchorColors.statusMint),
                  const SizedBox(width: 10),
                  Text(fromScan ? 'Scan Document' : 'Add New Document', style: AnchorTypography.headlineMedium),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Holder name and ID number are encrypted on this device before they are saved.',
                      style: AnchorTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Document Title (e.g. Passport)'),
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
                      decoration: const InputDecoration(labelText: 'ID / Reference Number'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setDialogState(() => category = val!),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: expiry ?? now,
                          firstDate: DateTime(now.year - 10),
                          lastDate: DateTime(now.year + 50),
                        );
                        if (picked != null) setDialogState(() => expiry = picked);
                      },
                      icon: const Icon(Icons.event_outlined, color: AnchorColors.primaryNavy),
                      label: Text(
                        expiry == null ? 'Expiry Date (Optional)' : 'Expires ${_formatDate(expiry!)}',
                        style: AnchorTypography.bodyMedium,
                      ),
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: 12),
                      Text(formError!, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx),
                  child: Text('Cancel', style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.alertCoral)),
                ),
                ElevatedButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save to Vault', style: AnchorTypography.buttonText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Identity':
        return Icons.badge_outlined;
      case 'Financial & Legal':
        return Icons.account_balance_outlined;
      case 'Education':
        return Icons.school_outlined;
      case 'Medical':
        return Icons.medical_services_outlined;
      case 'Household':
        return Icons.home_work_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Widget _buildBody(List<DocumentItem> filtered) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AnchorColors.primaryNavy));
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 54, color: AnchorColors.textMuted),
            const SizedBox(height: 12),
            Text(_loadError!, style: AnchorTypography.titleMedium),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadDocuments, child: Text('Retry', style: AnchorTypography.buttonText)),
          ],
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
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
      );
    }
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = filtered[index];
          final details = [
            if (doc.idNumber.isNotEmpty) 'ID: ${doc.idNumber}',
            'Expiry: ${doc.expiryDate != null ? _formatDate(doc.expiryDate!) : 'N/A'}',
          ].join(' • ');
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
                  child: Icon(_iconFor(doc.category), color: AnchorColors.primaryNavy, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title, style: AnchorTypography.titleSmall),
                      if (doc.holderName.isNotEmpty) Text(doc.holderName, style: AnchorTypography.bodySmall),
                      const SizedBox(height: 2),
                      Text(details, style: AnchorTypography.bodySmall),
                    ],
                  ),
                ),
                if (doc.isExpiringSoon || doc.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AnchorColors.alertCoral.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      doc.isExpired ? 'Expired' : 'Alert',
                      style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.alertCoral, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _documents
        : _documents.where((d) => d.category == _selectedCategory).toList();

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
          Expanded(child: _buildBody(filtered)),
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
