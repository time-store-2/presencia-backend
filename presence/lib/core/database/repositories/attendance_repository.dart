import '../database_helper.dart';
import '../../../models/attendance.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Attendance attendance) async {
    final db = await _dbHelper.database;
    final attWithTime = attendance.copyWith(lastUpdated: DateTime.now());
    final id = await db.insert('attendance', attWithTime.toMap());
    
    final inserted = await getById(id);
    if (inserted != null) {
    }
    
    return id;
  }

  Future<void> saveBatch(List<Attendance> attendances) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final savedRows = <Attendance>[];

    await db.transaction((txn) async {
      for (var attendance in attendances) {
        final attWithTime = attendance.copyWith(lastUpdated: now);

        // Upsert : remplace toute ligne existante pour le même couple
        // (adolescent_id, session_id) afin d'éviter les doublons.
        final existing = await txn.query(
          'attendance',
          where: 'adolescent_id = ? AND session_id = ?',
          whereArgs: [attendance.adolescentId, attendance.sessionId],
        );

        if (existing.isNotEmpty) {
          final updateData = attWithTime.toMap()..remove('id');
          // Préserve le server_id déjà enregistré pour ne pas le perdre.
          updateData['server_id'] = existing.first['server_id'];
          updateData['is_deleted'] = existing.first['is_deleted'];
          await txn.update(
            'attendance',
            updateData,
            where: 'id = ?',
            whereArgs: [existing.first['id']],
          );
          savedRows.add(Attendance.fromMap({...existing.first, ...updateData, 'id': existing.first['id']}));
        } else {
          final id = await txn.insert('attendance', attWithTime.toMap());
          final inserted = await txn.query(
            'attendance',
            where: 'id = ?',
            whereArgs: [id],
          );
          if (inserted.isNotEmpty) {
            savedRows.add(Attendance.fromMap(inserted.first));
          }
        }
      }
    });

    // Push each with its real local id + server_id so the id gets persisted back.
    for (var row in savedRows) {
    }
  }

  Future<List<Attendance>> getBySession(int sessionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'session_id = ? AND is_deleted = 0',
      whereArgs: [sessionId],
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<Attendance?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHistoryForAdolescent(int adolescentId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT a.*, s.title as session_title, s.date as session_date
      FROM attendance a
      JOIN sessions s ON a.session_id = s.id
      WHERE a.adolescent_id = ?
      ORDER BY s.date DESC
    ''', [adolescentId]);
  }

  Future<Map<String, int>> getStatsForAdolescent(int adolescentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM attendance 
      WHERE adolescent_id = ? 
      GROUP BY status
    ''', [adolescentId]);

    Map<String, int> stats = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
    };

    for (var row in results) {
      stats[row['status'] as String] = row['count'] as int;
    }

    return stats;
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final db = await _dbHelper.database;
    
    final sessionCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sessions')) ?? 0;
    
    final statusCounts = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM attendance 
      GROUP BY status
    ''');

    Map<String, int> counts = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
    };

    for (var row in statusCounts) {
      counts[row['status'] as String] = row['count'] as int;
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayStats = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM attendance a
      JOIN sessions s ON a.session_id = s.id
      WHERE s.date LIKE ?
      GROUP BY status
    ''', ['$todayStr%']);

    Map<String, int> todayCounts = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
    };

    for (var row in todayStats) {
      todayCounts[row['status'] as String] = row['count'] as int;
    }

    return {
      'totalSessions': sessionCount,
      'globalCounts': counts,
      'todayCounts': todayCounts,
    };
  }

  Future<Map<int, Map<String, int>>> getStatsByPeriod(DateTime start, DateTime end, int groupId) async {
    final db = await _dbHelper.database;
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    // On ajoute 23:59:59 à la fin de la date de fin pour inclure toute la journée
    final endStr = DateFormat('yyyy-MM-dd').format(end.add(const Duration(days: 1)));

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT a.adolescent_id, a.status, COUNT(*) as count
      FROM attendance a
      JOIN sessions s ON a.session_id = s.id
      WHERE s.date >= ? AND s.date < ? AND s.group_id = ?
      GROUP BY a.adolescent_id, a.status
    ''', [startStr, endStr, groupId]);

    Map<int, Map<String, int>> periodStats = {};
    for (var row in results) {
      final id = row['adolescent_id'] as int;
      final status = row['status'] as String;
      final count = row['count'] as int;
      
      periodStats.putIfAbsent(id, () => {'present': 0, 'absent': 0, 'late': 0, 'excused': 0});
      periodStats[id]![status] = count;
    }
    return periodStats;
  }

  Future<List<Map<String, dynamic>>> getInactivityAlerts() async {
    final db = await _dbHelper.database;
    // Trouve les jeunes qui n'ont pas été 'present' ou 'late' dans les 3 dernières séances
    // ou qui ont manqué les 3 dernières séances.
    return await db.rawQuery('''
      SELECT a.id, a.first_name, a.last_name, COUNT(att.id) as missing_count
      FROM adolescents a
      JOIN (
        SELECT id FROM sessions ORDER BY date DESC LIMIT 3
      ) last_sessions
      LEFT JOIN attendance att ON a.id = att.adolescent_id 
        AND att.session_id = last_sessions.id 
        AND att.status = 'absent'
      GROUP BY a.id
      HAVING missing_count >= 2
      ORDER BY missing_count DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getYouthRanking({bool mostPresent = true}) async {
    final db = await _dbHelper.database;
    final String order = mostPresent ? 'DESC' : 'ASC';
    final String status = mostPresent ? 'present' : 'absent';
    
    return await db.rawQuery('''
      SELECT a.first_name, a.last_name, COUNT(att.id) as count
      FROM adolescents a
      LEFT JOIN attendance att ON a.id = att.adolescent_id AND att.status = ?
      GROUP BY a.id
      ORDER BY count $order
      LIMIT 5
    ''', [status]);
  }
}
