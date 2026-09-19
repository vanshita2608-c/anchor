import 'dart:convert';

class VaultModel {
  final String id;
  final String name;
  final String ownerId;
  final int memberCount;
  final DateTime createdAt;

  VaultModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.memberCount = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VaultModel.fromMap(Map<String, dynamic> map) {
    return VaultModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Family Vault',
      ownerId: map['owner_id'] ?? '',
      memberCount: map['member_count'] ?? 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory VaultModel.fromJson(String source) => VaultModel.fromMap(json.decode(source));
}
