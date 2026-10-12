import '../database_helper.dart';
import '../../../models/parent.dart';
import 'package:sqflite/sqflite.dart';

class ParentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Parent parent) async {
    final db = await _dbHelper.database;
    final parentWithTime = parent.copyWith(lastUpdated: DateTime.now());
    final id = await db.insert('parents', parentWithTime.toMap());
    
    final inserted = await getById(id);
    if (inserted != null) {
    }
    
    return id;
  }

  Future<List<Parent>> getByAdolescent(int adolescentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parents',
      where: 'adolescent_id = ? AND is_deleted = 0',
      whereArgs: [adolescentId],
    );
    return List.generate(maps.length, (i) => Parent.fromMap(maps[i]));
  }

  Future<List<Parent>> getByGroup(int groupId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM parents p
      JOIN adolescents a ON p.adolescent_id = a.id
      JOIN adolescent_groups ag ON a.id = ag.adolescent_id
      WHERE ag.group_id = ? AND p.is_deleted = 0 AND a.is_deleted = 0 AND ag.is_deleted = 0
    ''', [groupId]);
    return maps.map((m) => Parent.fromMap(m)).toList();
  }

  Future<int> update(Parent parent) async {
    final db = await _dbHelper.database;
    final parentWithTime = parent.copyWith(lastUpdated: DateTime.now());
    final result = await db.update(
      'parents',
      parentWithTime.toMap(),
      where: 'id = ?',
      whereArgs: [parent.id],
    );
    
    
    return result;
  }

  Future<void> replaceForAdolescent(int adolescentId, List<Parent> parents) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Soft delete all parents for this adolescent
      await txn.update(
        'parents',
        {'is_deleted': 1, 'last_updated': DateTime.now().toIso8601String()},
        where: 'adolescent_id = ?',
        whereArgs: [adolescentId],
      );
      
      // We should technically push the deletions to Firestore too, 
      // but for simplicity here we'll just insert the new ones.
      // A more robust sync would iterate through existing parents and delete them on server.
      
      for (var parent in parents) {
        final pWithTime = parent.copyWith(lastUpdated: DateTime.now(), adolescentId: adolescentId);
        final id = await txn.insert('parents', pWithTime.toMap());
        // We can't easily push from within a transaction if SyncService is async, 
        // so we'll just assume they'll be pushed by a background sync or manual trigger.
      }
    });
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final parent = await getById(id);
    if (parent != null) {
      final softDeleted = parent.copyWith(isDeleted: true, lastUpdated: DateTime.now());
      await db.update(
        'parents',
        softDeleted.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 1;
  }

  Future<int> deleteByAdolescent(int adolescentId) async {
    final db = await _dbHelper.database;
    await db.update(
      'parents',
      {'is_deleted': 1, 'last_updated': DateTime.now().toIso8601String()},
      where: 'adolescent_id = ?',
      whereArgs: [adolescentId],
    );
    // Ideally we'd trigger server side deletes for all these too.
    return 1;
  }

  Future<Parent?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parents',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Parent.fromMap(maps.first);
    }
    return null;
  }
}
