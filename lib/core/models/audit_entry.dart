class AuditEntry {
  final String id;
  final String action;
  final DateTime createdAt;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.createdAt,
  });
}
