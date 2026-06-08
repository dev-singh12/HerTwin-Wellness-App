import 'package:cloud_firestore/cloud_firestore.dart';

class CyclesRecord {
  const CyclesRecord({
    this.id = '',
    this.startDate,
    this.endDate,
    this.periodLength,
    this.flow = '',
    this.symptoms = const <String>[],
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? periodLength;

  /// One of: light, medium, heavy.
  final String flow;
  final List<String> symptoms;
  final String notes;
  final DateTime? createdAt;

  factory CyclesRecord.fromMap(Map<String, dynamic> data, String id) =>
      CyclesRecord(
        id: (data['id'] as String?) ?? id,
        startDate: (data['startDate'] as Timestamp?)?.toDate(),
        endDate: (data['endDate'] as Timestamp?)?.toDate(),
        periodLength: (data['periodLength'] as num?)?.toInt(),
        flow: (data['flow'] as String?) ?? '',
        symptoms: (data['symptoms'] as List?)?.map((e) => e as String).toList() ??
            const <String>[],
        notes: (data['notes'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory CyclesRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      CyclesRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
        'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
        'periodLength': periodLength,
        'flow': flow,
        'symptoms': symptoms,
        'notes': notes,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  CyclesRecord copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? periodLength,
    String? flow,
    List<String>? symptoms,
    String? notes,
    DateTime? createdAt,
  }) =>
      CyclesRecord(
        id: id ?? this.id,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        periodLength: periodLength ?? this.periodLength,
        flow: flow ?? this.flow,
        symptoms: symptoms ?? this.symptoms,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
