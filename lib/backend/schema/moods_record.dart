import 'package:cloud_firestore/cloud_firestore.dart';

class MoodsRecord {
  const MoodsRecord({
    this.id = '',
    this.date,
    this.mood = '',
    this.moodScore,
    this.emotions = const <String>[],
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final DateTime? date;

  /// One of: great, good, okay, low, terrible.
  final String mood;

  /// 1-5.
  final int? moodScore;
  final List<String> emotions;
  final String notes;
  final DateTime? createdAt;

  factory MoodsRecord.fromMap(Map<String, dynamic> data, String id) =>
      MoodsRecord(
        id: (data['id'] as String?) ?? id,
        date: (data['date'] as Timestamp?)?.toDate(),
        mood: (data['mood'] as String?) ?? '',
        moodScore: (data['moodScore'] as num?)?.toInt(),
        emotions: (data['emotions'] as List?)?.map((e) => e as String).toList() ??
            const <String>[],
        notes: (data['notes'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory MoodsRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      MoodsRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date == null ? null : Timestamp.fromDate(date!),
        'mood': mood,
        'moodScore': moodScore,
        'emotions': emotions,
        'notes': notes,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  MoodsRecord copyWith({
    String? id,
    DateTime? date,
    String? mood,
    int? moodScore,
    List<String>? emotions,
    String? notes,
    DateTime? createdAt,
  }) =>
      MoodsRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        mood: mood ?? this.mood,
        moodScore: moodScore ?? this.moodScore,
        emotions: emotions ?? this.emotions,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
