import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  dynamic noteId;
  String title;
  String content;
  String createdAt;
  String updatedAt;
  bool pinned;

  Welcome({
    required this.noteId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.pinned,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    noteId: json["note_id"],
    title: json["title"],
    content: json["content"] ?? "",
    createdAt: json["created_at"] ?? "",
    updatedAt: json["updated_at"] ?? "",
    pinned: json["pinned"] == 1 || json["pinned"] == true ? true : false,
  );

  Map<String, dynamic> toJson() => {
    "note_id": noteId,
    "title": title,
    "content": content,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "pinned": pinned,
  };
}
