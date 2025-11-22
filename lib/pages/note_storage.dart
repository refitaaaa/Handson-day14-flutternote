import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class NoteStorage {
  Future<int> insertItem(Map<String, dynamic> noteData);
  Future<List<Map<String, dynamic>>> fetchNotes();
  Future<int> deleteNote(int noteId);
  Future<int> updateNote(Map<String, dynamic> noteData);
  
  static NoteStorage get instance {
    if (kIsWeb) {
      return WebStorage.instance;
    } else {
      return MobileStorage.instance;
    }
  }
}

// Storage untuk Web (SharedPreferences)
class WebStorage implements NoteStorage {
  static const String _notesKey = 'notes_list';
  
  WebStorage._privateConstructor();
  static final WebStorage instance = WebStorage._privateConstructor();

  @override
  Future<int> insertItem(Map<String, dynamic> noteData) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await fetchNotes();
    
    final newId = notes.isEmpty 
        ? 1 
        : notes.map((n) => n['note_id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    noteData['note_id'] = newId;
    
    notes.add(noteData);
    await prefs.setString(_notesKey, jsonEncode(notes));
    
    return newId;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    
    if (notesJson == null || notesJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> notesList = jsonDecode(notesJson);
    return notesList.map((note) => Map<String, dynamic>.from(note)).toList();
  }

  @override
  Future<int> deleteNote(int noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await fetchNotes();
    
    notes.removeWhere((note) => note['note_id'] == noteId);
    await prefs.setString(_notesKey, jsonEncode(notes));
    
    return 1;
  }

  @override
  Future<int> updateNote(Map<String, dynamic> noteData) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await fetchNotes();
    
    final index = notes.indexWhere((note) => note['note_id'] == noteData['note_id']);
    
    if (index != -1) {
      notes[index] = noteData;
      await prefs.setString(_notesKey, jsonEncode(notes));
      return 1;
    }
    
    return 0;
  }
}

// Storage untuk Mobile (SQLite)
class MobileStorage implements NoteStorage {
  static const String _databaseName = "note.db";
  static const String _tableName = 'notes';
  static const int _databaseVersion = 1;

  MobileStorage._privateConstructor();
  static final MobileStorage instance = MobileStorage._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialDatabase();
    return _database!;
  }

  Future<Database> _initialDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
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
      },
    );
  }

  @override
  Future<int> insertItem(Map<String, dynamic> noteData) async {
    final db = await database;
    return await db.insert(
      _tableName,
      noteData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'pinned DESC, created_at DESC',
    );
    return maps;
  }

  @override
  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  @override
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