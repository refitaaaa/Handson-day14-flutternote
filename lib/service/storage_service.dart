import 'dart:convert';
import 'package:flutter_note/models/note.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_note/models/note.model.dart';

class StorageService {
  Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    if (notesString == null) return [];

    final List<dynamic> jsonList = jsonDecode(notesString);
    return jsonList.map((e) => NoteModel.fromJson(e)).toList();
  }

  Future<void> saveNote(NoteModel note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    notes.add(note);

    final jsonList = notes.map((e) => e.toJson()).toList();
    prefs.setString("notes", jsonEncode(jsonList));
  }
}
