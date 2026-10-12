/// Utilisateur connecté via l'API Payload CMS.
/// Les ids peuvent être des nombres (SQLite) ou des strings (Postgres).
class AppUser {
  final dynamic id;
  final String email;
  final String displayName;
  final String? phone;
  final String role; // admin | assistant
  final List<dynamic> groupIds; // groupes assignés (assistant)

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.phone,
    required this.role,
    this.groupIds = const [],
  });

  static List<dynamic> _extractIds(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((v) => v is Map ? v['id'] : v).toList();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      displayName: json['displayName'] ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      phone: json['phone']?.toString(),
      role: json['role'] ?? 'assistant',
      groupIds: _extractIds(json['assignedGroups']),
    );
  }

  String get fullName => displayName;

  bool get isAdmin => role == 'admin';
  bool get isAssistant => role == 'assistant';

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'phone': phone,
        'role': role,
        'assignedGroups': groupIds,
      };
}
