import '../database_helper.dart';
import '../../../models/attendance_session.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceSessionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(AttendanceSession session) async {
    final db = await _dbHelper.database;
    final sessionWithTime = session.copyWith(lastUpdated: DateTime.now());
    final id = await db.insert('sessions', sessionWithTime.toMap());
    
    final inserted = await getById(id);
    if (inserted != null) {
    }
    
    return id;
  }

  Future<bool> existsByTitle(String title, {int? excludeId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sessions',
      where: excludeId == null
          ? 'LOWER(title) = LOWER(?) AND is_deleted = 0'
          : 'LOWER(title) = LOWER(?) AND is_deleted = 0 AND id != ?',
      whereArgs: excludeId == null ? [title] : [title, excludeId],
    );
    return maps.isNotEmpty;
  }

  Future<List<AttendanceSession>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions', 
      where: 'is_deleted = 0',
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => AttendanceSession.fromMap(maps[i]));
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final session = await getById(id);
    if (session != null) {
      final softDeleted = session.copyWith(isDeleted: true, lastUpdated: DateTime.now());
      await db.update(
        'sessions',
        softDeleted.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 1;
  }

  Future<AttendanceSession?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AttendanceSession.fromMap(maps.first);
    }
    return null;
  }

  Future<String> getNextSessionNumber() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) as count FROM sessions');
    int count = Sqflite.firstIntValue(result) ?? 0;
    return (count + 1).toString().padLeft(4, '0');
  }
}
