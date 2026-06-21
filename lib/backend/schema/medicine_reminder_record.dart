import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineReminderRecord {
  const MedicineReminderRecord({
    this.id = '',
    this.uid = '',
    this.medicineName = '',
    this.dosage = '',
    this.frequency = 'daily',
    this.reminderTimes = const <String>[],
    this.iconType = 'pill',
    this.iconColorValue = 0xFFEFA6B3,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String medicineName;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes;
  final String iconType;
  final int iconColorValue;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  factory MedicineReminderRecord.fromMap(
          Map<String, dynamic> data, String id) =>
      MedicineReminderRecord(
        id: (data['reminderId'] as String?) ?? id,
        uid: (data['uid'] as String?) ?? '',
        medicineName: (data['medicineName'] as String?) ?? '',
        dosage: (data['dosage'] as String?) ?? '',
        frequency: (data['frequency'] as String?) ?? 'daily',
        reminderTimes: (data['reminderTimes'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const <String>[],
        iconType: (data['iconType'] as String?) ?? 'pill',
        iconColorValue: (data['iconColorValue'] as num?)?.toInt() ?? 0xFFEFA6B3,
        isActive: (data['isActive'] as bool?) ?? true,
        startDate: (data['startDate'] as Timestamp?)?.toDate(),
        endDate: (data['endDate'] as Timestamp?)?.toDate(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory MedicineReminderRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      MedicineReminderRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'reminderId': id,
        'uid': uid,
        'medicineName': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'reminderTimes': reminderTimes,
        'iconType': iconType,
        'iconColorValue': iconColorValue,
        'isActive': isActive,
        'startDate':
            startDate == null ? null : Timestamp.fromDate(startDate!),
        'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
        'createdAt':
            createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  MedicineReminderRecord copyWith({
    String? id,
    String? uid,
    String? medicineName,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    String? iconType,
    int? iconColorValue,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) =>
      MedicineReminderRecord(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        medicineName: medicineName ?? this.medicineName,
        dosage: dosage ?? this.dosage,
        frequency: frequency ?? this.frequency,
        reminderTimes: reminderTimes ?? this.reminderTimes,
        iconType: iconType ?? this.iconType,
        iconColorValue: iconColorValue ?? this.iconColorValue,
        isActive: isActive ?? this.isActive,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        createdAt: createdAt ?? this.createdAt,
      );
}
