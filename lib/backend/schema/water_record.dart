import 'package:cloud_firestore/cloud_firestore.dart';

class WaterRecord {
  const WaterRecord({
    this.id = '',
    this.date = '',
    this.glasses = 0,
    this.targetGlasses = 8,
    this.updatedAt,
  });

  final String id;

  /// `yyyy-MM-dd`.
  final String date;
  final int glasses;
  final int targetGlasses;
  final DateTime? updatedAt;

  factory WaterRecord.fromMap(Map<String, dynamic> data, String id) =>
      WaterRecord(
        id: (data['id'] as String?) ?? id,
        date: (data['date'] as String?) ?? '',
        glasses: (data['glasses'] as num?)?.toInt() ?? 0,
        targetGlasses: (data['targetGlasses'] as num?)?.toInt() ?? 8,
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory WaterRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      WaterRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'glasses': glasses,
        'targetGlasses': targetGlasses,
        'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  WaterRecord copyWith({
    String? id,
    String? date,
    int? glasses,
    int? targetGlasses,
    DateTime? updatedAt,
  }) =>
      WaterRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        glasses: glasses ?? this.glasses,
        targetGlasses: targetGlasses ?? this.targetGlasses,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
