import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _notesKey = 'notes_list';
  
  StorageHelper._privateConstructor();
  static final StorageHelper instance = StorageHelper._privateConstructor();

  // Insert note
  Future<int> insertItem(Map<String, dynamic> noteData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing notes
    final notes = await fetchNotes();
    
    // Generate ID
    final newId = notes.isEmpty ? 1 : notes.map((n) => n['note_id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    noteData['note_id'] = newId;
    
    // Add new note
    notes.add(noteData);
    
    // Save back
    await prefs.setString(_notesKey, jsonEncode(notes));
    
    return newId;
  }

  // Fetch all notes
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    
    if (notesJson == null || notesJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> notesList = jsonDecode(notesJson);
    return notesList.map((note) => Map<String, dynamic>.from(note)).toList();
  }

  // Delete note
  Future<int> deleteNote(int noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await fetchNotes();
    
    notes.removeWhere((note) => note['note_id'] == noteId);
    
    await prefs.setString(_notesKey, jsonEncode(notes));
    return 1;
  }

  // Update note
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