import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static const String _databaseName = "note.db";
  static const String _tableName = 'notes';
  static const int _databaseVersion = 1;

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  // Getter database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialDatabase();
    return _database!;
  }

  // Initializing database
  Future<Database> _initialDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await createTable(db);
      },
    );
  }

  // Create table
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        note_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        pinned INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Insert note
  Future<int> insertItem(Map<String, dynamic> noteData) async {
    final db = await database;
    return await db.insert(
      _tableName,
      noteData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all notes
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'pinned DESC, created_at DESC',
    );
    return maps;
  }

  // Delete note
  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  // Update note
  Future<int> updateNote(Map<String, dynamic> noteData) async {
    final db = await database;
    return await db.update(
      _tableName,
      noteData,
      where: 'note_id = ?',
      whereArgs: [noteData['note_id']],
    );
  }
}