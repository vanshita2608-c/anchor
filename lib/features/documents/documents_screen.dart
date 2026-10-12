import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/models/document_item.dart';
import '../../core/services/current_user.dart';
import '../../core/services/document_ai_service.dart';
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
  bool _isAnalyzing = false;

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
        _triggerAiOcrScan(ImageSource.camera);
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

  Future<void> _triggerAiOcrScan([ImageSource source = ImageSource.gallery]) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isAnalyzing = true);

      // Analyze document image via Gemini AI / OCR Service
      final result = await DocumentAiService.instance.analyzeDocument(
        imagePath: pickedFile.path,
      );

      setState(() => _isAnalyzing = false);

      if (!mounted) return;
      _showAiReviewDialog(result, pickedFile.path);
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e'), backgroundColor: AnchorColors.alertCoral),
      );
    }
  }

  Future<void> _triggerFilePicker() async {
    try {
      final fileResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
      );

      if (fileResult == null || fileResult.files.single.path == null) return;
      final path = fileResult.files.single.path!;

      setState(() => _isAnalyzing = true);

      final result = await DocumentAiService.instance.analyzeDocument(
        imagePath: path,
      );

      setState(() => _isAnalyzing = false);

      if (!mounted) return;
      _showAiReviewDialog(result, path);
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File upload error: $e'), backgroundColor: AnchorColors.alertCoral),
      );
    }
  }

  void _showAiReviewDialog(DocumentAiResult aiResult, String fileSourcePath) {
    final titleCtrl = TextEditingController(text: aiResult.title);
    final holderCtrl = TextEditingController(text: aiResult.holderName);
    final numberCtrl = TextEditingController(text: aiResult.documentNumber);
    final expiryCtrl = TextEditingController(text: aiResult.expiryDate ?? '');
    final summaryCtrl = TextEditingController(text: aiResult.summary);
    String selectedCategory = aiResult.category;
    bool saving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AnchorColors.cardCreamElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AnchorColors.borderSand),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AnchorColors.statusMint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AnchorColors.statusMint),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI OCR Extracted Metadata', style: AnchorTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('Powered by Gemini Vision AI', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.ceruleanTeal)),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anchor AI automatically categorized and extracted metadata from your document image. Verify details below:',
                      style: AnchorTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Document Title',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _categories.contains(selectedCategory) ? selectedCategory : 'Financial & Legal',
                      decoration: const InputDecoration(
                        labelText: 'AI Smart Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories.where((c) => c != 'All').map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: holderCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Document Holder Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: numberCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Document / Policy Number',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: expiryCtrl,
                      style: AnchorTypography.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: summaryCtrl,
                      maxLines: 2,
                      style: AnchorTypography.bodySmall,
                      decoration: const InputDecoration(
                        labelText: 'AI Summary',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    if (aiResult.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: aiResult.tags.map((t) {
                          return Chip(
                            label: Text('#$t', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.primaryNavy)),
                            backgroundColor: AnchorColors.bgWarmCream,
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx),
                  child: Text('Discard', style: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.alertCoral)),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setModalState(() => saving = true);
                          DateTime? parsedExpiry;
                          if (expiryCtrl.text.trim().isNotEmpty && expiryCtrl.text.trim() != 'N/A') {
                            parsedExpiry = DateTime.tryParse(expiryCtrl.text.trim());
                          }
                          try {
                            await _repo.addDocument(
                              title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Scanned Document',
                              category: selectedCategory,
                              holderName: holderCtrl.text.trim(),
                              idNumber: numberCtrl.text.trim(),
                              expiryDate: parsedExpiry,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            await _loadDocuments();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Document encrypted & saved to Vault!'),
                                  backgroundColor: AnchorColors.primaryNavy,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => saving = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save document: $e'), backgroundColor: AnchorColors.alertCoral),
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Encrypt & Save', style: AnchorTypography.buttonText),
                ),
              ],
            );
          },
        );
      },
    );
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
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AnchorColors.primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AnchorColors.primaryNavy),
                ),
                title: Text('Scan Document with Camera (AI OCR)', style: AnchorTypography.titleSmall),
                subtitle: Text('Auto-extract names, numbers & expiry dates using Gemini AI', style: AnchorTypography.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerAiOcrScan(ImageSource.camera);
                },
              ),
              const Divider(color: AnchorColors.borderSand),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AnchorColors.ceruleanTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AnchorColors.ceruleanTeal),
                ),
                title: Text('Select Image from Photo Gallery', style: AnchorTypography.titleSmall),
                subtitle: Text('Run AI intelligence OCR on existing photo', style: AnchorTypography.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerAiOcrScan(ImageSource.gallery);
                },
              ),
              const Divider(color: AnchorColors.borderSand),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AnchorColors.statusMint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.upload_file_outlined, color: AnchorColors.statusMint),
                ),
                title: Text('Upload PDF or Document File', style: AnchorTypography.titleSmall),
                subtitle: Text('Upload files directly from device storage', style: AnchorTypography.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerFilePicker();
                },
              ),
              const Divider(color: AnchorColors.borderSand),
              ListTile(
                leading: const Icon(Icons.note_add_outlined, color: AnchorColors.ceruleanTeal),
                title: Text('Enter Document Details Manually', style: AnchorTypography.titleSmall),
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
                await _loadDocuments();
              } catch (e) {
                debugPrint('Save document notice: $e');
                setDialogState(() {
                  saving = false;
                  formError = "Couldn't save the document. Please try again.";
                });
              }
            }

            return AlertDialog(
              backgroundColor: AnchorColors.cardCreamElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AnchorColors.borderSand),
              ),
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

  void _showDocumentDetails(DocumentItem doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AnchorColors.cardCreamElevated,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AnchorColors.creamBox,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconFor(doc.category), color: AnchorColors.primaryNavy, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.title, style: AnchorTypography.headlineMedium),
                        Text(doc.category, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.ceruleanTeal)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AnchorColors.borderSand),
              const SizedBox(height: 12),
              if (doc.holderName.isNotEmpty)
                _buildDetailRow(Icons.person_outline, 'Document Holder', doc.holderName),
              if (doc.idNumber.isNotEmpty)
                _buildDetailRow(Icons.pin_outlined, 'Reference / ID Number', doc.idNumber),
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Expiry Date',
                doc.expiryDate != null ? _formatDate(doc.expiryDate!) : 'N/A',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.lock_outline, color: AnchorColors.primaryNavy),
                      label: Text('Decrypt File', style: AnchorTypography.bodyMedium),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AnchorColors.primaryNavy),
                      icon: const Icon(Icons.share_outlined, color: Colors.white),
                      label: Text('Secure Share', style: AnchorTypography.buttonText),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AnchorColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: AnchorTypography.bodyLarge),
              ],
            ),
          ),
        ],
      ),
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
            Text('Tap + or Scan to add your first document', style: AnchorTypography.bodySmall),
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
          return InkWell(
            onTap: () => _showDocumentDetails(doc),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnchorColors.cardCreamElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AnchorColors.borderSand),
                boxShadow: [
                  BoxShadow(color: AnchorColors.primaryNavy.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AnchorColors.creamBox,
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
            icon: const Icon(Icons.add_a_photo_outlined, color: AnchorColors.primaryNavy),
            onPressed: () => _triggerAiOcrScan(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AnchorColors.primaryNavy),
            onPressed: _showAddDocumentSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                        backgroundColor: AnchorColors.creamBox,
                        side: BorderSide(color: isSelected ? AnchorColors.primaryNavy : AnchorColors.borderSand),
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

          // Fullscreen AI Processing Loading Overlay
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AnchorColors.cardCreamElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AnchorColors.borderSand),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AnchorColors.primaryNavy),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: AnchorColors.statusMint),
                          const SizedBox(width: 8),
                          Text('Analyzing Document with Gemini AI...', style: AnchorTypography.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Extracting names, numbers & expiry dates...', style: AnchorTypography.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AnchorColors.primaryNavy,
        onPressed: () => _triggerAiOcrScan(ImageSource.camera),
        icon: const Icon(Icons.center_focus_strong, color: Colors.white),
        label: Text('AI OCR Scan', style: AnchorTypography.buttonText),
      ),
    );
  }
}
