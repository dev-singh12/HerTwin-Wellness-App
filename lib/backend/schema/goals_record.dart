import 'package:cloud_firestore/cloud_firestore.dart';

class GoalsRecord {
  const GoalsRecord({
    this.id = '',
    this.title = '',
    this.category = '',
    this.targetValue,
    this.currentValue,
    this.unit = '',
    this.deadline,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String category;
  final double? targetValue;
  final double? currentValue;
  final String unit;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory GoalsRecord.fromMap(Map<String, dynamic> data, String id) =>
      GoalsRecord(
        id: (data['id'] as String?) ?? id,
        title: (data['title'] as String?) ?? '',
        category: (data['category'] as String?) ?? '',
        targetValue: (data['targetValue'] as num?)?.toDouble(),
        currentValue: (data['currentValue'] as num?)?.toDouble(),
        unit: (data['unit'] as String?) ?? '',
        deadline: (data['deadline'] as Timestamp?)?.toDate(),
        isCompleted: (data['isCompleted'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory GoalsRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      GoalsRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unit': unit,
        'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
        'isCompleted': isCompleted,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  GoalsRecord copyWith({
    String? id,
    String? title,
    String? category,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      GoalsRecord(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        targetValue: targetValue ?? this.targetValue,
        currentValue: currentValue ?? this.currentValue,
        unit: unit ?? this.unit,
        deadline: deadline ?? this.deadline,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
