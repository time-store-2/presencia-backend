enum AttendanceStatus { present, absent, late, excused }

class Attendance {
  final int? id;
  final int adolescentId;
  final int sessionId;
  final AttendanceStatus status;
  final DateTime timestamp;
  final String? comment;
  final String? serverId;
  final DateTime? lastUpdated;
  final bool isDeleted;

  Attendance({
    this.id,
    required this.adolescentId,
    required this.sessionId,
    required this.status,
    required this.timestamp,
    this.comment,
    this.serverId,
    this.lastUpdated,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adolescent_id': adolescentId,
      'session_id': sessionId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'comment': comment,
      'server_id': serverId,
      'last_updated': lastUpdated?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      adolescentId: map['adolescent_id'],
      sessionId: map['session_id'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      comment: map['comment'],
      serverId: map['server_id'],
      lastUpdated: map['last_updated'] != null ? DateTime.parse(map['last_updated']) : null,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Attendance copyWith({
    int? id,
    int? adolescentId,
    int? sessionId,
    AttendanceStatus? status,
    DateTime? timestamp,
    String? comment,
    String? serverId,
    DateTime? lastUpdated,
    bool? isDeleted,
  }) {
    return Attendance(
      id: id ?? this.id,
      adolescentId: adolescentId ?? this.adolescentId,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      comment: comment ?? this.comment,
      serverId: serverId ?? this.serverId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
