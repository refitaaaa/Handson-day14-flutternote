import 'dart:convert';

NoteModel welcomeFromJson(String str) => NoteModel.fromJson(json.decode(str));

String welcomeToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  String? noteId;
  String title;
  String content;
  String createdAt;
  String updatedAt;
  int pinned; // <-- harus int, bukan bool

  NoteModel({
    this.noteId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.pinned,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      noteId: json['noteId'],
      title: json['title'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      pinned: json['pinned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noteId': noteId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'pinned': pinned,
    };
  }
}
