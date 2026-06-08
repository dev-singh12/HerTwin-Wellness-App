import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomsRecord {
  const SymptomsRecord({
    this.id = '',
    this.date,
    this.symptoms = const <String>[],
    this.severity,
    this.category = '',
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final DateTime? date;
  final List<String> symptoms;

  /// 1-5.
  final int? severity;

  /// One of: physical, emotional, digestive, skin.
  final String category;
  final String notes;
  final DateTime? createdAt;

  factory SymptomsRecord.fromMap(Map<String, dynamic> data, String id) =>
      SymptomsRecord(
        id: (data['id'] as String?) ?? id,
        date: (data['date'] as Timestamp?)?.toDate(),
        symptoms: (data['symptoms'] as List?)?.map((e) => e as String).toList() ??
            const <String>[],
        severity: (data['severity'] as num?)?.toInt(),
        category: (data['category'] as String?) ?? '',
        notes: (data['notes'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory SymptomsRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      SymptomsRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date == null ? null : Timestamp.fromDate(date!),
        'symptoms': symptoms,
        'severity': severity,
        'category': category,
        'notes': notes,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  SymptomsRecord copyWith({
    String? id,
    DateTime? date,
    List<String>? symptoms,
    int? severity,
    String? category,
    String? notes,
    DateTime? createdAt,
  }) =>
      SymptomsRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        symptoms: symptoms ?? this.symptoms,
        severity: severity ?? this.severity,
        category: category ?? this.category,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
