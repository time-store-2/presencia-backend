class AttendanceSession {
  final int? id;
  final String title;
  final DateTime date;
  final int? groupId;
  final String? serverId;
  final DateTime? lastUpdated;
  final bool isDeleted;

  AttendanceSession({
    this.id,
    required this.title,
    required this.date,
    this.groupId,
    this.serverId,
    this.lastUpdated,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'group_id': groupId,
      'server_id': serverId,
      'last_updated': lastUpdated?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      groupId: map['group_id'],
      serverId: map['server_id'],
      lastUpdated: map['last_updated'] != null ? DateTime.parse(map['last_updated']) : null,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  AttendanceSession copyWith({
    int? id,
    String? title,
    DateTime? date,
    int? groupId,
    String? serverId,
    DateTime? lastUpdated,
    bool? isDeleted,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      groupId: groupId ?? this.groupId,
      serverId: serverId ?? this.serverId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
