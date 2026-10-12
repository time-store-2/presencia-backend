import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/attendance.dart';
import '../../models/attendance_session.dart';
import '../services/api_service.dart';
import '../services/payload_mappers.dart';
import '../services/already_exists_exception.dart';

/// Séances et présences chargées depuis l'API Payload.
/// Les statistiques sont calculées côté serveur (/api/org-stats...).
class AttendanceProvider with ChangeNotifier {
  AttendanceProvider({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  List<AttendanceSession> _sessions = [];
  bool _isLoading = false;
  Map<String, dynamic> _globalStats = {};
  List<Map<String, dynamic>> _topPresent = [];
  List<Map<String, dynamic>> _topAbsent = [];
  List<Map<String, dynamic>> _inactivityAlerts = [];

  List<AttendanceSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get globalStats => _globalStats;
  List<Map<String, dynamic>> get topPresent => _topPresent;
  List<Map<String, dynamic>> get topAbsent => _topAbsent;
  List<Map<String, dynamic>> get inactivityAlerts => _inactivityAlerts;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getMany(
        'attendance-sessions',
        limit: 200,
        sort: '-date',
      );
      _sessions = (res['docs'] as List)
          .map((d) => sessionFromPayload(d as Map<String, dynamic>))
          .toList();
      final stats = await _api.getRaw('org-stats');
      _globalStats = {
        'totalSessions': stats['totalSessions'] ?? 0,
        'globalCounts':
            Map<String, int>.from(stats['globalCounts'] ?? const {}),
        'todayCounts': Map<String, int>.from(stats['todayCounts'] ?? const {}),
      };
      _topPresent =
          List<Map<String, dynamic>>.from(stats['topPresent'] ?? const []);
      _topAbsent =
          List<Map<String, dynamic>>.from(stats['topAbsent'] ?? const []);
      _inactivityAlerts = List<Map<String, dynamic>>.from(
        stats['inactivityAlerts'] ?? const [],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> createSession(AttendanceSession session) async {
    final exists = _sessions.any(
      (s) => s.title.toLowerCase() == session.title.toLowerCase(),
    );
    if (exists) throw AlreadyExistsException(session.title);
    final user = _api.currentUser;
    if (user == null) throw Exception('Non connecté.');
    final created = await _api.create(
      'attendance-sessions',
      sessionToPayload(
        session,
        leaderId: user.id,
      ),
    );
    await loadSessions();
    return toIntId((created['doc'] as Map<String, dynamic>)['id']);
  }

  Future<void> deleteSession(int id) async {
    await _api.delete('attendance-sessions', id);
    await loadSessions();
  }

  Future<String> getNextSessionNumber() async {
    try {
      final res = await _api.getMany('attendance-sessions', limit: 1);
      final total = (res['totalDocs'] as num?)?.toInt() ?? _sessions.length;
      return (total + 1).toString().padLeft(4, '0');
    } catch (_) {
      return (_sessions.length + 1).toString().padLeft(4, '0');
    }
  }

  Future<void> saveAttendance(List<Attendance> attendances) async {
    if (attendances.isEmpty) return;
    final sessionId = attendances.first.sessionId;
    final existing = await getAttendanceForSession(sessionId);
    final existingByMember = {for (final a in existing) a.adolescentId: a.id};

    for (final a in attendances) {
      final recordId = existingByMember[a.adolescentId];
      if (recordId != null) {
        await _api.update(
          'attendance-records',
          recordId,
          attendanceToRecord(a),
        );
      } else {
        await _api.create('attendance-records', attendanceToRecord(a));
      }
    }
    await loadSessions(); // Refresh stats and ranking
  }

  Future<List<Attendance>> getAttendanceForSession(int sessionId) async {
    final res = await _api.getMany(
      'attendance-records',
      where: {'session': sessionId},
      limit: 2000,
    );
    return (res['docs'] as List)
        .map((d) => recordToAttendance(d as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getAdolescentStats(int adolescentId) async {
    final data = await _api.getRaw(
      'member-stats',
      {'memberId': '$adolescentId'},
    );
    final stats = (data['stats'] as Map?) ?? {};
    return {
      'present': (stats['present'] as num? ?? 0).toInt(),
      'absent': (stats['absent'] as num? ?? 0).toInt(),
      'late': (stats['late'] as num? ?? 0).toInt(),
      'excused': (stats['excused'] as num? ?? 0).toInt(),
    };
  }

  Future<List<Map<String, dynamic>>> getHistoryForAdolescent(
    int adolescentId,
  ) async {
    final data = await _api.getRaw(
      'member-stats',
      {'memberId': '$adolescentId'},
    );
    return List<Map<String, dynamic>>.from(data['history'] ?? const []);
  }

  Future<Map<int, Map<String, int>>> getStatsByPeriod(
    DateTime start,
    DateTime end,
    int groupId,
  ) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final data = await _api.getRaw('period-stats', {
      'groupId': '$groupId',
      'start': fmt.format(start),
      'end': fmt.format(end),
    });
    final result = <int, Map<String, int>>{};
    (data as Map<String, dynamic>).forEach((key, value) {
      final counts = (value as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      );
      result[int.parse(key)] = {
        'present': counts['present'] ?? 0,
        'absent': counts['absent'] ?? 0,
        'late': counts['late'] ?? 0,
        'excused': counts['excused'] ?? 0,
      };
    });
    return result;
  }

  /// Modèle du message d'absence (Réglages du backend).
  /// Repli local si le serveur est injoignable.
  Future<String> getAbsenceTemplate() async {
    const fallback =
        'Bonjour {prenom}, tu as manqué la séance de {groupe} du {date}.';
    try {
      final data = await _api.getRaw('globals/settings');
      final template = (data['absenceMessage'] as String?)?.trim();
      if (template != null && template.isNotEmpty) return template;
    } catch (_) {
      // Repli local.
    }
    return fallback;
  }

  Future<List<String>> getAdolescentBadges(int adolescentId) async {
    final history = await getHistoryForAdolescent(adolescentId);
    List<String> badges = [];

    if (history.isEmpty) return badges;

    // Badge: Fidèle (4 dernières séances présent ou retard)
    if (history.length >= 4) {
      bool consistent = true;
      for (int i = 0; i < 4; i++) {
        final status = history[i]['status'];
        if (status == 'absent') {
          consistent = false;
          break;
        }
      }
      if (consistent) badges.add("Fidèle");
    }

    // Badge: Ponctuel (Pas de retard sur les 3 dernières présences)
    final lastPresences = history.where((h) => h['status'] == 'present').toList();
    if (lastPresences.length >= 3) {
      badges.add("Ponctuel");
    }

    // Badge: Nouveau (Moins de 2 séances au total)
    if (history.length <= 2) {
      badges.add("Nouveau");
    }

    return badges;
  }
}
