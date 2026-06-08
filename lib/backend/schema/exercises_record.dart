import 'package:cloud_firestore/cloud_firestore.dart';

class ExercisesRecord {
  const ExercisesRecord({
    this.id = '',
    this.date,
    this.activityType = '',
    this.durationMinutes,
    this.caloriesBurned,
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final DateTime? date;
  final String activityType;
  final int? durationMinutes;
  final int? caloriesBurned;
  final String notes;
  final DateTime? createdAt;

  factory ExercisesRecord.fromMap(Map<String, dynamic> data, String id) =>
      ExercisesRecord(
        id: (data['id'] as String?) ?? id,
        date: (data['date'] as Timestamp?)?.toDate(),
        activityType: (data['activityType'] as String?) ?? '',
        durationMinutes: (data['durationMinutes'] as num?)?.toInt(),
        caloriesBurned: (data['caloriesBurned'] as num?)?.toInt(),
        notes: (data['notes'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory ExercisesRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      ExercisesRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date == null ? null : Timestamp.fromDate(date!),
        'activityType': activityType,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'notes': notes,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  ExercisesRecord copyWith({
    String? id,
    DateTime? date,
    String? activityType,
    int? durationMinutes,
    int? caloriesBurned,
    String? notes,
    DateTime? createdAt,
  }) =>
      ExercisesRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        activityType: activityType ?? this.activityType,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        caloriesBurned: caloriesBurned ?? this.caloriesBurned,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
