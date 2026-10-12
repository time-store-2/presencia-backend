import '../database_helper.dart';
import '../../../models/group.dart';
import '../../../models/adolescent.dart';
import 'package:sqflite/sqflite.dart';

class GroupRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Group group) async {
    final db = await _dbHelper.database;
    final groupWithTime = group.copyWith(lastUpdated: DateTime.now());
    final id = await db.insert('groups', groupWithTime.toMap());
    
    // Trigger sync
    final insertedGroup = await getById(id);
    if (insertedGroup != null) {
    }
    
    return id;
  }

  Future<bool> existsByName(String name, {int? excludeId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'groups',
      where: excludeId == null
          ? 'LOWER(name) = LOWER(?) AND is_deleted = 0'
          : 'LOWER(name) = LOWER(?) AND is_deleted = 0 AND id != ?',
      whereArgs: excludeId == null ? [name] : [name, excludeId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Group>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups', 
      where: 'is_deleted = 0',
      orderBy: 'name ASC'
    );
    return List.generate(maps.length, (i) => Group.fromMap(maps[i]));
  }

  Future<int> update(Group group) async {
    final db = await _dbHelper.database;
    final groupWithTime = group.copyWith(lastUpdated: DateTime.now());
    final result = await db.update(
      'groups',
      groupWithTime.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
    
    // Trigger sync
    
    return result;
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    
    // Soft delete locally to allow sync
    final group = await getById(id);
    if (group != null) {
      final softDeletedGroup = group.copyWith(isDeleted: true, lastUpdated: DateTime.now());
      await db.update(
        'groups',
        softDeletedGroup.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Trigger sync
    }
    
    return 1;
  }

  Future<Group?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Group.fromMap(maps.first);
    }
    return null;
  }

  // Many-to-many logic
  Future<void> addAdolescentToGroup(int adolescentId, int groupId) async {
    final db = await _dbHelper.database;
    await db.insert('adolescent_groups', {
      'adolescent_id': adolescentId,
      'group_id': groupId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeAdolescentFromGroup(int adolescentId, int groupId) async {
    final db = await _dbHelper.database;
    await db.delete('adolescent_groups', 
      where: 'adolescent_id = ? AND group_id = ?',
      whereArgs: [adolescentId, groupId]
    );
  }

  Future<void> syncAdolescentGroups(int adolescentId, Set<int> groupIds) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('adolescent_groups', where: 'adolescent_id = ?', whereArgs: [adolescentId]);
      for (var gId in groupIds) {
        await txn.insert('adolescent_groups', {
          'adolescent_id': adolescentId,
          'group_id': gId,
        });
      }
    });
  }

  Future<List<Adolescent>> getGroupMembers(int groupId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.* FROM adolescents a
      JOIN adolescent_groups ag ON a.id = ag.adolescent_id
      WHERE ag.group_id = ?
      ORDER BY a.last_name ASC, a.first_name ASC
    ''', [groupId]);
    return List.generate(maps.length, (i) => Adolescent.fromMap(maps[i]));
  }

  Future<List<int>> getAdolescentGroupIds(int adolescentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'adolescent_groups',
      columns: ['group_id'],
      where: 'adolescent_id = ?',
      whereArgs: [adolescentId],
    );
    return List.generate(maps.length, (i) => maps[i]['group_id'] as int);
  }

  Future<List<Map<String, dynamic>>> getAllAdolescentGroupMappings() async {
    final db = await _dbHelper.database;
    return await db.query('adolescent_groups');
  }
}
