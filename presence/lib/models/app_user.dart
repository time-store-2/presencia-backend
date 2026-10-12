/// Utilisateur connecté via l'API Payload CMS.
/// Les ids peuvent être des nombres (SQLite) ou des strings (MongoDB).
class AppUser {
  final dynamic id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // super_admin | org_admin | group_leader
  final dynamic organizationId;
  final dynamic groupId;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.organizationId,
    this.groupId,
  });

  static dynamic _extractId(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['id'];
    return value;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'group_leader',
      organizationId: _extractId(json['organization']),
      groupId: _extractId(json['group']),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  bool get isSuperAdmin => role == 'super_admin';
  bool get isOrgAdmin => role == 'org_admin' || role == 'super_admin';
  bool get isGroupLeader => role == 'group_leader';

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'organization': organizationId,
        'group': groupId,
      };
}
