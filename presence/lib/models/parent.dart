class Parent {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? whatsapp;
  final int memberId;
  final String? relation; // Père, Mère, Tuteur, etc.
  final String? serverId;
  final DateTime? lastUpdated;
  final bool isDeleted;

  Parent({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.whatsapp,
    required this.memberId,
    this.relation,
    this.serverId,
    this.lastUpdated,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'whatsapp': whatsapp,
      'member_id': memberId,
      'relation': relation,
      'server_id': serverId,
      'last_updated': lastUpdated?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phone: map['phone'],
      whatsapp: map['whatsapp'],
      memberId: map['member_id'],
      relation: map['relation'],
      serverId: map['server_id'],
      lastUpdated: map['last_updated'] != null ? DateTime.parse(map['last_updated']) : null,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Parent copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? whatsapp,
    int? memberId,
    String? relation,
    String? serverId,
    DateTime? lastUpdated,
    bool? isDeleted,
  }) {
    return Parent(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      memberId: memberId ?? this.memberId,
      relation: relation ?? this.relation,
      serverId: serverId ?? this.serverId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  String get fullName => '${firstName ?? ""} ${lastName ?? ""}'.trim();
}
