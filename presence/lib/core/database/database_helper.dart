import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'presencia.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE adolescents ADD COLUMN address TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE attendance ADD COLUMN comment TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS adolescent_groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          adolescent_id INTEGER NOT NULL,
          group_id INTEGER NOT NULL,
          FOREIGN KEY (adolescent_id) REFERENCES adolescents (id) ON DELETE CASCADE,
          FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
        )
      ''');
      // Migrate existing group_id to junction table
      await db.execute('''
        INSERT OR IGNORE INTO adolescent_groups (adolescent_id, group_id)
        SELECT id, group_id FROM adolescents WHERE group_id IS NOT NULL
      ''');
    }
    if (oldVersion < 5) {
      final tables = ['groups', 'adolescents', 'parents', 'sessions', 'attendance', 'adolescent_groups'];
      for (var table in tables) {
        await db.execute('ALTER TABLE $table ADD COLUMN server_id TEXT');
        await db.execute('ALTER TABLE $table ADD COLUMN last_updated TEXT');
        await db.execute('ALTER TABLE $table ADD COLUMN is_deleted INTEGER DEFAULT 0');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER,
        created_at TEXT NOT NULL,
        server_id TEXT,
        last_updated TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE adolescents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        gender TEXT,
        birth_date TEXT,
        photo_path TEXT,
        phone TEXT,
        address TEXT,
        active INTEGER DEFAULT 1,
        server_id TEXT,
        last_updated TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE adolescent_groups (
        adolescent_id INTEGER NOT NULL,
        group_id INTEGER NOT NULL,
        server_id TEXT,
        last_updated TEXT,
        is_deleted INTEGER DEFAULT 0,
        PRIMARY KEY (adolescent_id, group_id),
        FOREIGN KEY (adolescent_id) REFERENCES adolescents (id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE parents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        phone TEXT,
        whatsapp TEXT,
        adolescent_id INTEGER,
        relation TEXT,
        server_id TEXT,
        last_updated TEXT,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (adolescent_id) REFERENCES adolescents (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        group_id INTEGER,
        server_id TEXT,
        last_updated TEXT,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        adolescent_id INTEGER NOT NULL,
        session_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        comment TEXT,
        server_id TEXT,
        last_updated TEXT,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (adolescent_id) REFERENCES adolescents (id) ON DELETE CASCADE,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');
  }
}
