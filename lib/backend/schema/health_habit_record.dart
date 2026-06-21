import 'package:cloud_firestore/cloud_firestore.dart';

class HealthHabitRecord {
  const HealthHabitRecord({
    this.id = '',
    this.uid = '',
    this.title = '',
    this.category = '',
    this.icon = '',
    this.isSystemGenerated = false,
    this.conditionTag = '',
    this.isActive = true,
    this.targetDays = 7,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String title;
  final String category;
  final String icon;
  final bool isSystemGenerated;
  final String conditionTag;
  final bool isActive;
  final int targetDays;
  final DateTime? createdAt;

  factory HealthHabitRecord.fromMap(Map<String, dynamic> data, String id) =>
      HealthHabitRecord(
        id: (data['habitId'] as String?) ?? id,
        uid: (data['uid'] as String?) ?? '',
        title: (data['title'] as String?) ?? '',
        category: (data['category'] as String?) ?? '',
        icon: (data['icon'] as String?) ?? '',
        isSystemGenerated: (data['isSystemGenerated'] as bool?) ?? false,
        conditionTag: (data['conditionTag'] as String?) ?? '',
        isActive: (data['isActive'] as bool?) ?? true,
        targetDays: (data['targetDays'] as num?)?.toInt() ?? 7,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory HealthHabitRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      HealthHabitRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'habitId': id,
        'uid': uid,
        'title': title,
        'category': category,
        'icon': icon,
        'isSystemGenerated': isSystemGenerated,
        'conditionTag': conditionTag,
        'isActive': isActive,
        'targetDays': targetDays,
        'createdAt':
            createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  HealthHabitRecord copyWith({
    String? id,
    String? uid,
    String? title,
    String? category,
    String? icon,
    bool? isSystemGenerated,
    String? conditionTag,
    bool? isActive,
    int? targetDays,
    DateTime? createdAt,
  }) =>
      HealthHabitRecord(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        title: title ?? this.title,
        category: category ?? this.category,
        icon: icon ?? this.icon,
        isSystemGenerated: isSystemGenerated ?? this.isSystemGenerated,
        conditionTag: conditionTag ?? this.conditionTag,
        isActive: isActive ?? this.isActive,
        targetDays: targetDays ?? this.targetDays,
        createdAt: createdAt ?? this.createdAt,
      );
}
