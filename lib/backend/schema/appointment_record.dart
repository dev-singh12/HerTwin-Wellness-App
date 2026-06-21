import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentRecord {
  const AppointmentRecord({
    this.id = '',
    this.uid = '',
    this.doctorId = '',
    this.doctorName = '',
    this.doctorPhotoUrl = '',
    this.doctorSpecialty = '',
    this.consultationType = '',
    this.priceRs = 0,
    this.status = 'booked',
    this.scheduledAt,
    this.meetingLink,
    this.callbackPhone,
    this.notes,
    this.dashboardEnriched = false,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String doctorSpecialty;
  final String consultationType;
  final int priceRs;
  final String status;
  final DateTime? scheduledAt;
  final String? meetingLink;
  final String? callbackPhone;
  final String? notes;
  final bool dashboardEnriched;
  final DateTime? createdAt;

  factory AppointmentRecord.fromMap(Map<String, dynamic> data, String id) =>
      AppointmentRecord(
        id: (data['appointmentId'] as String?) ?? id,
        uid: (data['uid'] as String?) ?? '',
        doctorId: (data['doctorId'] as String?) ?? '',
        doctorName: (data['doctorName'] as String?) ?? '',
        doctorPhotoUrl: (data['doctorPhotoUrl'] as String?) ?? '',
        doctorSpecialty: (data['doctorSpecialty'] as String?) ?? '',
        consultationType: (data['consultationType'] as String?) ?? '',
        priceRs: (data['priceRs'] as num?)?.toInt() ?? 0,
        status: (data['status'] as String?) ?? 'booked',
        scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
        meetingLink: data['meetingLink'] as String?,
        callbackPhone: data['callbackPhone'] as String?,
        notes: data['notes'] as String?,
        dashboardEnriched: (data['dashboardEnriched'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory AppointmentRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      AppointmentRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'appointmentId': id,
        'uid': uid,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorPhotoUrl': doctorPhotoUrl,
        'doctorSpecialty': doctorSpecialty,
        'consultationType': consultationType,
        'priceRs': priceRs,
        'status': status,
        'scheduledAt':
            scheduledAt == null ? null : Timestamp.fromDate(scheduledAt!),
        'meetingLink': meetingLink,
        'callbackPhone': callbackPhone,
        'notes': notes,
        'dashboardEnriched': dashboardEnriched,
        'createdAt':
            createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  AppointmentRecord copyWith({
    String? id,
    String? uid,
    String? doctorId,
    String? doctorName,
    String? doctorPhotoUrl,
    String? doctorSpecialty,
    String? consultationType,
    int? priceRs,
    String? status,
    DateTime? scheduledAt,
    String? meetingLink,
    String? callbackPhone,
    String? notes,
    bool? dashboardEnriched,
    DateTime? createdAt,
  }) =>
      AppointmentRecord(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        doctorId: doctorId ?? this.doctorId,
        doctorName: doctorName ?? this.doctorName,
        doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
        doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
        consultationType: consultationType ?? this.consultationType,
        priceRs: priceRs ?? this.priceRs,
        status: status ?? this.status,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        meetingLink: meetingLink ?? this.meetingLink,
        callbackPhone: callbackPhone ?? this.callbackPhone,
        notes: notes ?? this.notes,
        dashboardEnriched: dashboardEnriched ?? this.dashboardEnriched,
        createdAt: createdAt ?? this.createdAt,
      );
}
