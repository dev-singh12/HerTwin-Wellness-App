import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderLogRecord {
  const ReminderLogRecord({
    this.id = '',
    this.uid = '',
    this.reminderId = '',
    this.date = '',
    this.timesChecked = const <String, bool>{},
    this.updatedAt,
  });

  final String id;
  final String uid;
  final String reminderId;
  final String date;
  final Map<String, bool> timesChecked;
  final DateTime? updatedAt;

  factory ReminderLogRecord.fromMap(Map<String, dynamic> data, String id) =>
      ReminderLogRecord(
        id: (data['id'] as String?) ?? id,
        uid: (data['uid'] as String?) ?? '',
        reminderId: (data['reminderId'] as String?) ?? '',
        date: (data['date'] as String?) ?? '',
        timesChecked: (data['timesChecked'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as bool)) ??
            const <String, bool>{},
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory ReminderLogRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      ReminderLogRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'reminderId': reminderId,
        'date': date,
        'timesChecked': timesChecked,
        'updatedAt':
            updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  ReminderLogRecord copyWith({
    String? id,
    String? uid,
    String? reminderId,
    String? date,
    Map<String, bool>? timesChecked,
    DateTime? updatedAt,
  }) =>
      ReminderLogRecord(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        reminderId: reminderId ?? this.reminderId,
        date: date ?? this.date,
        timesChecked: timesChecked ?? this.timesChecked,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
