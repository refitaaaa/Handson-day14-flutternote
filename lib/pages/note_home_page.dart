import 'package:flutter/material.dart';
import 'package:flutter_note/models/note.model.dart';
import 'package:flutter_note/service/firestore_service.dart';
import 'package:flutter_note/pages/note_editor_page.dart';

class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToCreateNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );

    if (result == true) {
      setState(() {}); // Refresh UI
    }
  }

  void _navigateToEditNote(NoteModel note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _deleteNote(String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.deleteNote(noteId);
              if (!mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Note deleted"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return "Today";
      if (diff.inDays == 1) return "Yesterday";
      if (diff.inDays < 7) return "${diff.inDays} days ago";

      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNote,
        tooltip: "Create Note",
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: _firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(note.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(note.noteId!),
                  ),
                  onTap: () => _navigateToEditNote(note),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No notes yet",
            style: TextStyle(fontSize: 24, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add your first note",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
