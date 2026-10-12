class Member {
  final int? id;
  final String firstName;
  final String lastName;
  final String? gender;
  final DateTime? birthDate;
  final String? photoPath;
  final String? phone;
  final String? address;
  final bool isActive;
  final String? serverId;
  final DateTime? lastUpdated;
  final bool isDeleted;

  Member({
    this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.birthDate,
    this.photoPath,
    this.phone,
    this.address,
    this.isActive = true,
    this.serverId,
    this.lastUpdated,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'photo_path': photoPath,
      'phone': phone,
      'address': address,
      'active': isActive ? 1 : 0,
      'server_id': serverId,
      'last_updated': lastUpdated?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      gender: map['gender'],
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      photoPath: map['photo_path'],
      phone: map['phone'],
      address: map['address'],
      isActive: map['active'] == 1,
      serverId: map['server_id'],
      lastUpdated: map['last_updated'] != null ? DateTime.parse(map['last_updated']) : null,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Member copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? birthDate,
    String? photoPath,
    String? phone,
    String? address,
    bool? isActive,
    String? serverId,
    DateTime? lastUpdated,
    bool? isDeleted,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      serverId: serverId ?? this.serverId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  String get fullName => '$firstName $lastName';
}
