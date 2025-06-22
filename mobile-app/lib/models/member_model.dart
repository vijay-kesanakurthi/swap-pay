// lib/models/member_model.dart

class Member {
  final String id;
  final String groupId;
  final String walletAddress;
  final String? name;
  final DateTime joinedAt;

  Member({
    required this.id,
    required this.groupId,
    required this.walletAddress,
    this.name,
    required this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      groupId: json['group_id'],
      walletAddress: json['wallet_address'],
      name: json['name'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'wallet_address': walletAddress,
      'name': name,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
