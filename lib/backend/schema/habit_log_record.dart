import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLogRecord {
  const HabitLogRecord({
    this.id = '',
    this.uid = '',
    this.date = '',
    this.completedHabits = const <String, bool>{},
    this.updatedAt,
  });

  final String id;
  final String uid;
  final String date;
  final Map<String, bool> completedHabits;
  final DateTime? updatedAt;

  factory HabitLogRecord.fromMap(Map<String, dynamic> data, String id) =>
      HabitLogRecord(
        id: (data['id'] as String?) ?? id,
        uid: (data['uid'] as String?) ?? '',
        date: (data['date'] as String?) ?? '',
        completedHabits: (data['completedHabits'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as bool)) ??
            const <String, bool>{},
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory HabitLogRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      HabitLogRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'date': date,
        'completedHabits': completedHabits,
        'updatedAt':
            updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  HabitLogRecord copyWith({
    String? id,
    String? uid,
    String? date,
    Map<String, bool>? completedHabits,
    DateTime? updatedAt,
  }) =>
      HabitLogRecord(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        date: date ?? this.date,
        completedHabits: completedHabits ?? this.completedHabits,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
