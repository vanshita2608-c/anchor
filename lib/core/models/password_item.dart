/// A saved password. The password itself stays encrypted until the user asks to copy it.
class PasswordItem {
  final String id;
  final String websiteTitle;
  final String username;
  final String category;
  final String accessLevel;
  final int securityScore;
  final String encryptedPassword;
  final String passwordNonce;
  final String passwordMac;
  final DateTime createdAt;

  const PasswordItem({
    required this.id,
    required this.websiteTitle,
    required this.username,
    required this.category,
    required this.accessLevel,
    required this.securityScore,
    required this.encryptedPassword,
    required this.passwordNonce,
    required this.passwordMac,
    required this.createdAt,
  });

  String get strengthLabel {
    if (securityScore >= 80) return 'Strong';
    if (securityScore >= 50) return 'Moderate';
    return 'Weak';
  }
}
