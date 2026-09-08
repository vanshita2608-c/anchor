class PasswordItem {
  final String id;
  final String websiteTitle;
  final String websiteUrl;
  final String username;
  final String encryptedPassword;
  final String category;
  final bool isFavorite;
  final int securityScore;
  final DateTime createdAt;

  PasswordItem({
    required this.id,
    required this.websiteTitle,
    required this.websiteUrl,
    required this.username,
    required this.encryptedPassword,
    required this.category,
    this.isFavorite = false,
    required this.securityScore,
    required this.createdAt,
  });
}
