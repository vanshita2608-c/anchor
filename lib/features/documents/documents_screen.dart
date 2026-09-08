import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../core/models/document_item.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Identity',
    'Insurance',
    'Vehicle',
    'Property',
    'Tax & Bills',
    'Medical',
  ];

  final List<DocumentItem> _documents = [
    DocumentItem(
      id: 'doc_1',
      title: "Dad's Indian Passport",
      category: 'Identity',
      ownerName: 'Dad',
      expiryDate: DateTime.now().add(const Duration(days: 240)),
      fileSizeKB: 1420,
      tags: ['Passport', 'Travel'],
      createdAt: DateTime.now(),
    ),
    DocumentItem(
      id: 'doc_2',
      title: "Honda City Vehicle RC & Insurance",
      category: 'Vehicle',
      ownerName: 'Dad',
      expiryDate: DateTime.now().add(const Duration(days: 12)),
      fileSizeKB: 890,
      tags: ['Car', 'Insurance'],
      createdAt: DateTime.now(),
    ),
    DocumentItem(
      id: 'doc_3',
      title: "Vanshita Aadhaar Card",
      category: 'Identity',
      ownerName: 'Vanshita',
      fileSizeKB: 410,
      tags: ['Identity', 'Govt'],
      createdAt: DateTime.now(),
    ),
    DocumentItem(
      id: 'doc_4',
      title: "Family Health Insurance Policy",
      category: 'Insurance',
      ownerName: 'Shared (Family)',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      fileSizeKB: 2350,
      tags: ['HDFC', 'Medical'],
      createdAt: DateTime.now(),
    ),
  ];

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
            onPressed: () => _showScanModal(context),
            tooltip: 'Scan Document with OCR',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips Carousel
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AnchorColors.primaryNavy,
                  backgroundColor: AnchorColors.cardWhite,
                  labelStyle: AnchorTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AnchorColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No documents in this category', style: AnchorTypography.bodyMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AnchorColors.ceruleanTint,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded, color: AnchorColors.ceruleanTeal),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(doc.title, style: AnchorTypography.titleMedium),
                                        const SizedBox(height: 2),
                                        Text('${doc.category} • Owner: ${doc.ownerName}', style: AnchorTypography.bodySmall),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert_rounded, color: AnchorColors.textSecondary),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_rounded, size: 14, color: AnchorColors.statusMint),
                                      const SizedBox(width: 4),
                                      Text('AES-256 Encrypted', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.statusMint, fontSize: 11)),
                                    ],
                                  ),
                                  if (doc.expiryDate != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: doc.isExpiringSoon ? AnchorColors.warningAmberLight : AnchorColors.bgWarmCream,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: doc.isExpiringSoon ? AnchorColors.warningAmber : AnchorColors.borderSand,
                                        ),
                                      ),
                                      child: Text(
                                        doc.isExpiringSoon
                                            ? 'Expiring in ${doc.expiryDate!.difference(DateTime.now()).inDays} days'
                                            : 'Expires: ${doc.expiryDate!.year}-${doc.expiryDate!.month.toString().padLeft(2, '0')}',
                                        style: AnchorTypography.bodySmall.copyWith(
                                          fontSize: 11,
                                          color: doc.isExpiringSoon ? AnchorColors.warningAmber : AnchorColors.textSecondary,
                                          fontWeight: doc.isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AnchorColors.primaryNavy,
        onPressed: () => _showScanModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Scan Document', style: AnchorTypography.buttonText),
      ),
    );
  }

  void _showScanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AnchorColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add & Scan Document', style: AnchorTypography.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'ML Kit OCR will automatically extract metadata on-device before client-side encryption.',
                textAlign: TextAlign.center,
                style: AnchorTypography.bodySmall,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AnchorColors.ceruleanTeal),
                title: Text('Take Photo / Scan', style: AnchorTypography.titleMedium),
                subtitle: Text('Scan document page via Camera', style: AnchorTypography.bodySmall),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AnchorColors.primaryNavy),
                title: Text('Import Image from Gallery', style: AnchorTypography.titleMedium),
                subtitle: Text('Select PNG / JPEG file', style: AnchorTypography.bodySmall),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: AnchorColors.warningAmber),
                title: Text('Upload PDF File', style: AnchorTypography.titleMedium),
                subtitle: Text('Select PDF from Files', style: AnchorTypography.bodySmall),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
