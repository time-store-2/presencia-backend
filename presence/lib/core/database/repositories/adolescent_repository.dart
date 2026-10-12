import '../database_helper.dart';
import '../../../models/adolescent.dart';

class AdolescentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Adolescent adolescent) async {
    final db = await _dbHelper.database;
    final adolescentWithTime = adolescent.copyWith(lastUpdated: DateTime.now());
    final id = await db.insert('adolescents', adolescentWithTime.toMap());
    
    final inserted = await getById(id);
    if (inserted != null) {
    }
    
    return id;
  }

  Future<bool> existsByFullName(String firstName, String lastName, {int? excludeId}) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT id FROM adolescents WHERE LOWER(first_name) = LOWER(?) AND LOWER(last_name) = LOWER(?) AND is_deleted = 0'
      '${excludeId != null ? ' AND id != ?' : ''}',
      excludeId == null ? [firstName, lastName] : [firstName, lastName, excludeId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Adolescent>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'adolescents', 
      where: 'is_deleted = 0',
      orderBy: 'last_name ASC, first_name ASC'
    );
    return List.generate(maps.length, (i) => Adolescent.fromMap(maps[i]));
  }

  Future<List<Adolescent>> getByGroup(int groupId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.* FROM adolescents a
      JOIN adolescent_groups ag ON a.id = ag.adolescent_id
      WHERE ag.group_id = ? AND a.is_deleted = 0 AND ag.is_deleted = 0
      ORDER BY a.last_name ASC, a.first_name ASC
    ''', [groupId]);
    return maps.map((m) => Adolescent.fromMap(m)).toList();
  }

  Future<int> update(Adolescent adolescent) async {
    final db = await _dbHelper.database;
    final adolescentWithTime = adolescent.copyWith(lastUpdated: DateTime.now());
    final result = await db.update(
      'adolescents',
      adolescentWithTime.toMap(),
      where: 'id = ?',
      whereArgs: [adolescent.id],
    );
    
    
    return result;
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final adolescent = await getById(id);
    if (adolescent != null) {
      final softDeleted = adolescent.copyWith(isDeleted: true, lastUpdated: DateTime.now());
      await db.update(
        'adolescents',
        softDeleted.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      
    }
    return 1;
  }

  Future<Adolescent?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'adolescents',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Adolescent.fromMap(maps.first);
    }
    return null;
  }
}
