import 'package:cloud_firestore/cloud_firestore.dart';

/// A consultation booking, stored at top level in `appointments/{id}`.
///
/// This record deliberately lives outside `users/{uid}` so that both sides of
/// the consultation can read it: a doctor cannot see a booking made against
/// them if it is buried in the patient's private tree.
///
/// Patient- and doctor-facing display fields are denormalized onto the record
/// so neither dashboard needs a second read per row.
class AppointmentRecord {
  const AppointmentRecord({
    this.id = '',
    // --- patient side ---
    this.patientUid = '',
    this.patientName = '',
    this.patientPhotoUrl = '',
    this.patientAge = 0,
    this.patientCondition = '',
    this.patientSeverity = '',
    this.patientScore = 0,
    // --- doctor side ---
    this.doctorUid = '',
    this.doctorName = '',
    this.doctorPhotoUrl = '',
    this.doctorSpecialty = '',
    // --- booking ---
    this.consultationType = '',
    this.priceRs = 0,
    this.paymentStatus = 'demo',
    this.status = 'booked',
    this.scheduledAt,
    this.meetingLink,
    this.reasonForVisit,
    // --- clinical outcome (doctor-written) ---
    this.doctorNotes,
    this.prescriptionText,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  final String patientUid;
  final String patientName;
  final String patientPhotoUrl;
  final int patientAge;

  /// Condition summary carried over from onboarding, so the doctor sees the
  /// clinical context in the queue without opening the full chart.
  final String patientCondition;
  final String patientSeverity;
  final int patientScore;

  /// Firebase Auth uid of the doctor. Doubles as the `doctors/{id}` doc id,
  /// which is what the security rules key doctor privileges on.
  final String doctorUid;
  final String doctorName;
  final String doctorPhotoUrl;
  final String doctorSpecialty;

  /// 'chat' or 'video'.
  final String consultationType;
  final int priceRs;

  /// 'demo' for the pilot — no real money moves. A real gateway would set
  /// this server-side only, never from the client.
  final String paymentStatus;

  /// 'booked' | 'ongoing' | 'completed' | 'cancelled'.
  final String status;

  final DateTime? scheduledAt;
  final String? meetingLink;
  final String? reasonForVisit;

  final String? doctorNotes;
  final String? prescriptionText;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'booked' || status == 'ongoing';
  bool get isVideo => consultationType == 'video';

  /// Whether a real age was captured. Age is denormalized as 0 when unknown,
  /// so display sites gate on this rather than repeating `patientAge > 0` — one
  /// source of truth keeps the dashboard card and the chart in sync.
  bool get hasAge => patientAge > 0;

  /// Formatted age label, e.g. "24 yrs". Only meaningful when [hasAge].
  String get ageLabel => '$patientAge yrs';

  String get patientInitials {
    final parts = patientName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  factory AppointmentRecord.fromMap(Map<String, dynamic> data, String id) =>
      AppointmentRecord(
        id: (data['appointmentId'] as String?) ?? id,
        patientUid: (data['patientUid'] as String?) ?? '',
        patientName: (data['patientName'] as String?) ?? '',
        patientPhotoUrl: (data['patientPhotoUrl'] as String?) ?? '',
        patientAge: (data['patientAge'] as num?)?.toInt() ?? 0,
        patientCondition: (data['patientCondition'] as String?) ?? '',
        patientSeverity: (data['patientSeverity'] as String?) ?? '',
        patientScore: (data['patientScore'] as num?)?.toInt() ?? 0,
        doctorUid: (data['doctorUid'] as String?) ?? '',
        doctorName: (data['doctorName'] as String?) ?? '',
        doctorPhotoUrl: (data['doctorPhotoUrl'] as String?) ?? '',
        doctorSpecialty: (data['doctorSpecialty'] as String?) ?? '',
        consultationType: (data['consultationType'] as String?) ?? '',
        priceRs: (data['priceRs'] as num?)?.toInt() ?? 0,
        paymentStatus: (data['paymentStatus'] as String?) ?? 'demo',
        status: (data['status'] as String?) ?? 'booked',
        scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
        meetingLink: data['meetingLink'] as String?,
        reasonForVisit: data['reasonForVisit'] as String?,
        doctorNotes: data['doctorNotes'] as String?,
        prescriptionText: data['prescriptionText'] as String?,
        completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory AppointmentRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      AppointmentRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'appointmentId': id,
        'patientUid': patientUid,
        'patientName': patientName,
        'patientPhotoUrl': patientPhotoUrl,
        'patientAge': patientAge,
        'patientCondition': patientCondition,
        'patientSeverity': patientSeverity,
        'patientScore': patientScore,
        'doctorUid': doctorUid,
        'doctorName': doctorName,
        'doctorPhotoUrl': doctorPhotoUrl,
        'doctorSpecialty': doctorSpecialty,
        'consultationType': consultationType,
        'priceRs': priceRs,
        'paymentStatus': paymentStatus,
        'status': status,
        'scheduledAt':
            scheduledAt == null ? null : Timestamp.fromDate(scheduledAt!),
        'meetingLink': meetingLink,
        'reasonForVisit': reasonForVisit,
        'doctorNotes': doctorNotes,
        'prescriptionText': prescriptionText,
        'completedAt':
            completedAt == null ? null : Timestamp.fromDate(completedAt!),
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  AppointmentRecord copyWith({
    String? id,
    String? patientUid,
    String? patientName,
    String? patientPhotoUrl,
    int? patientAge,
    String? patientCondition,
    String? patientSeverity,
    int? patientScore,
    String? doctorUid,
    String? doctorName,
    String? doctorPhotoUrl,
    String? doctorSpecialty,
    String? consultationType,
    int? priceRs,
    String? paymentStatus,
    String? status,
    DateTime? scheduledAt,
    String? meetingLink,
    String? reasonForVisit,
    String? doctorNotes,
    String? prescriptionText,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AppointmentRecord(
        id: id ?? this.id,
        patientUid: patientUid ?? this.patientUid,
        patientName: patientName ?? this.patientName,
        patientPhotoUrl: patientPhotoUrl ?? this.patientPhotoUrl,
        patientAge: patientAge ?? this.patientAge,
        patientCondition: patientCondition ?? this.patientCondition,
        patientSeverity: patientSeverity ?? this.patientSeverity,
        patientScore: patientScore ?? this.patientScore,
        doctorUid: doctorUid ?? this.doctorUid,
        doctorName: doctorName ?? this.doctorName,
        doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
        doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
        consultationType: consultationType ?? this.consultationType,
        priceRs: priceRs ?? this.priceRs,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        status: status ?? this.status,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        meetingLink: meetingLink ?? this.meetingLink,
        reasonForVisit: reasonForVisit ?? this.reasonForVisit,
        doctorNotes: doctorNotes ?? this.doctorNotes,
        prescriptionText: prescriptionText ?? this.prescriptionText,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
