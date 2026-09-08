class DocumentItem {
  final String id;
  final String title;
  final String category;
  final String ownerName;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final int fileSizeKB;
  final List<String> tags;
  final bool isEncrypted;
  final DateTime createdAt;

  DocumentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.ownerName,
    this.issueDate,
    this.expiryDate,
    required this.fileSizeKB,
    required this.tags,
    this.isEncrypted = true,
    required this.createdAt,
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 30;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}
