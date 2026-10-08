/// A vault document as shown in the app. Sensitive fields (holder name,
/// ID number) are stored encrypted in `document_metadata.encrypted_metadata_blob`.
class DocumentItem {
  final String id;
  final String title;
  final String category;
  final String holderName;
  final String idNumber;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const DocumentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.holderName,
    required this.idNumber,
    this.expiryDate,
    required this.createdAt,
  });

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final today = DateTime.now();
    return DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }

  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days >= 0 && days <= 30;
  }

  bool get isExpired {
    final days = daysUntilExpiry;
    return days != null && days < 0;
  }
}
