class AuditEntry {
  final String id;
  final String action;
  final String timestamp;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.timestamp,
  });
}
