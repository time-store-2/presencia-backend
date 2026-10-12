class Group {
  final int? id;
  final String name;
  final String? slug;
  final String? description;
  final int? color;
  final DateTime createdAt;
  final String? serverId;
  final DateTime? lastUpdated;
  final bool isDeleted;

  Group({
    this.id,
    required this.name,
    this.slug,
    this.description,
    this.color,
    required this.createdAt,
    this.serverId,
    this.lastUpdated,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'server_id': serverId,
      'last_updated': lastUpdated?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      slug: map['slug'],
      description: map['description'],
      color: map['color'],
      createdAt: DateTime.parse(map['created_at']),
      serverId: map['server_id'],
      lastUpdated: map['last_updated'] != null ? DateTime.parse(map['last_updated']) : null,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Group copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    int? color,
    DateTime? createdAt,
    String? serverId,
    DateTime? lastUpdated,
    bool? isDeleted,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      serverId: serverId ?? this.serverId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
