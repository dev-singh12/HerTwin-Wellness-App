import 'package:cloud_firestore/cloud_firestore.dart';

class JournalsRecord {
  const JournalsRecord({
    this.id = '',
    this.date,
    this.title = '',
    this.content = '',
    this.tags = const <String>[],
    this.mood = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DateTime? date;
  final String title;
  final String content;
  final List<String> tags;
  final String mood;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory JournalsRecord.fromMap(Map<String, dynamic> data, String id) =>
      JournalsRecord(
        id: (data['id'] as String?) ?? id,
        date: (data['date'] as Timestamp?)?.toDate(),
        title: (data['title'] as String?) ?? '',
        content: (data['content'] as String?) ?? '',
        tags: (data['tags'] as List?)?.map((e) => e as String).toList() ??
            const <String>[],
        mood: (data['mood'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory JournalsRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      JournalsRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date == null ? null : Timestamp.fromDate(date!),
        'title': title,
        'content': content,
        'tags': tags,
        'mood': mood,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  JournalsRecord copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    List<String>? tags,
    String? mood,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      JournalsRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        title: title ?? this.title,
        content: content ?? this.content,
        tags: tags ?? this.tags,
        mood: mood ?? this.mood,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
