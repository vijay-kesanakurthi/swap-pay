// lib/models/group_model.dart
import 'member_model.dart';

class Group {
  final String id;
  final String name;
  final String inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Member> members;

  Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      inviteCode: json['invite_code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((m) => Member.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}
