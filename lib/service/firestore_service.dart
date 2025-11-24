import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/note.model.dart';

class FirestoreService {
  final CollectionReference noteCollection =
      FirebaseFirestore.instance.collection('notes');

  // CREATE
  Future<void> addNote(NoteModel note) async {
    final doc = noteCollection.doc(); // generate Firestore document ID
    note.noteId = doc.id;             // set noteId to model
    await doc.set(note.toJson());
  }

  // READ (Realtime Stream)
  Stream<List<NoteModel>> getNotesStream() {
    return noteCollection
        .orderBy('pinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) =>
                NoteModel.fromJson(doc.data() as Map<String, dynamic>)
            ).toList());
  }

  // UPDATE
  Future<void> updateNote(NoteModel note) async {
    await noteCollection.doc(note.noteId).update(note.toJson());
  }

  // DELETE
  Future<void> deleteNote(String id) async {
    await noteCollection.doc(id).delete();
  }

  // PIN / UNPIN
  Future<void> togglePin(NoteModel note) async {
    note.pinned = (note.pinned == 1 ? 0 : 1);  // toggle pin state
    note.updatedAt = DateTime.now().toIso8601String();

    await noteCollection.doc(note.noteId).update({
      'pinned': note.pinned,
      'updatedAt': note.updatedAt,
    });
  }
}
