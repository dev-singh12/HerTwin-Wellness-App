import 'package:cloud_firestore/cloud_firestore.dart';

class SleepRecord {
  const SleepRecord({
    this.id = '',
    this.date,
    this.bedtime,
    this.wakeTime,
    this.durationHours,
    this.quality,
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final DateTime? date;
  final DateTime? bedtime;
  final DateTime? wakeTime;
  final double? durationHours;

  /// 1-5.
  final int? quality;
  final String notes;
  final DateTime? createdAt;

  factory SleepRecord.fromMap(Map<String, dynamic> data, String id) =>
      SleepRecord(
        id: (data['id'] as String?) ?? id,
        date: (data['date'] as Timestamp?)?.toDate(),
        bedtime: (data['bedtime'] as Timestamp?)?.toDate(),
        wakeTime: (data['wakeTime'] as Timestamp?)?.toDate(),
        durationHours: (data['durationHours'] as num?)?.toDouble(),
        quality: (data['quality'] as num?)?.toInt(),
        notes: (data['notes'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory SleepRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      SleepRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date == null ? null : Timestamp.fromDate(date!),
        'bedtime': bedtime == null ? null : Timestamp.fromDate(bedtime!),
        'wakeTime': wakeTime == null ? null : Timestamp.fromDate(wakeTime!),
        'durationHours': durationHours,
        'quality': quality,
        'notes': notes,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  SleepRecord copyWith({
    String? id,
    DateTime? date,
    DateTime? bedtime,
    DateTime? wakeTime,
    double? durationHours,
    int? quality,
    String? notes,
    DateTime? createdAt,
  }) =>
      SleepRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        bedtime: bedtime ?? this.bedtime,
        wakeTime: wakeTime ?? this.wakeTime,
        durationHours: durationHours ?? this.durationHours,
        quality: quality ?? this.quality,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
