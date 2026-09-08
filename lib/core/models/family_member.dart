class FamilyMember {
  final String id;
  final String fullName;
  final String email;
  final String role; // OWNER, ADMIN, MEMBER, VIEWER, EMERGENCY_CONTACT

  const FamilyMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });
}
