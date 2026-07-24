import 'package:cloud_firestore/cloud_firestore.dart';

class UsersRecord {
  const UsersRecord({
    required this.uid,
    this.email = '',
    this.displayName = '',
    this.photoUrl = '',
    this.dateOfBirth,
    this.age,
    this.height,
    this.weight,
    this.bloodType = '',
    this.conditions = const <String>[],
    this.symptoms = const <String>[],
    this.onboardingComplete = false,
    this.createdAt,
    this.lastActiveAt,
    this.conditionType = '',
    this.latestAssessmentScore = 0,
    this.latestSeverityLabel = '',
    this.carePlanType = '',
    this.hasUsedFreeConsultation = false,
    this.primaryDoctorId,
    this.primaryDoctorName,
    this.doctorNotes,
    this.activeHabitIds = const <String>[],
    this.healthVitalityScore = 0,
    this.lastLogDate,
    this.prescriptionUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime? dateOfBirth;
  final int? age;
  final double? height;
  final double? weight;
  final String bloodType;
  final List<String> conditions;
  final List<String> symptoms;
  final bool onboardingComplete;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final String conditionType;
  final int latestAssessmentScore;
  final String latestSeverityLabel;
  final String carePlanType;
  final bool hasUsedFreeConsultation;
  final String? primaryDoctorId;
  final String? primaryDoctorName;
  final String? doctorNotes;
  final List<String> activeHabitIds;
  final int healthVitalityScore;
  final DateTime? lastLogDate;
  final String? prescriptionUrl;

  /// Age to use anywhere age is displayed or denormalized.
  ///
  /// Prefers an explicitly-stored [age], and falls back to computing it from
  /// [dateOfBirth] when only that was captured — so a patient who gave their
  /// birth date but not their age is not shown as ageless. Returns null when
  /// neither is known, which every display site must treat as "omit".
  int? get effectiveAge {
    if (age != null && age! > 0) return age;
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years > 0 && years < 130 ? years : null;
  }

  factory UsersRecord.fromMap(Map<String, dynamic> data, String id) =>
      UsersRecord(
        uid: (data['uid'] as String?) ?? id,
        email: (data['email'] as String?) ?? '',
        displayName: (data['displayName'] as String?) ?? '',
        photoUrl: (data['photoUrl'] as String?) ?? '',
        dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
        age: (data['age'] as num?)?.toInt(),
        height: (data['height'] as num?)?.toDouble(),
        weight: (data['weight'] as num?)?.toDouble(),
        bloodType: (data['bloodType'] as String?) ?? '',
        conditions: (data['conditions'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const <String>[],
        symptoms:
            (data['symptoms'] as List?)?.map((e) => e as String).toList() ??
                const <String>[],
        onboardingComplete: (data['onboardingComplete'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
        conditionType: (data['conditionType'] as String?) ?? '',
        latestAssessmentScore:
            (data['latestAssessmentScore'] as num?)?.toInt() ?? 0,
        latestSeverityLabel:
            (data['latestSeverityLabel'] as String?) ?? '',
        carePlanType: (data['carePlanType'] as String?) ?? '',
        hasUsedFreeConsultation:
            (data['hasUsedFreeConsultation'] as bool?) ?? false,
        primaryDoctorId: data['primaryDoctorId'] as String?,
        primaryDoctorName: data['primaryDoctorName'] as String?,
        doctorNotes: data['doctorNotes'] as String?,
        activeHabitIds: (data['activeHabitIds'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const <String>[],
        healthVitalityScore:
            (data['healthVitalityScore'] as num?)?.toInt() ?? 0,
        lastLogDate: (data['lastLogDate'] as Timestamp?)?.toDate(),
        prescriptionUrl: data['prescriptionUrl'] as String?,
      );

  factory UsersRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      UsersRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'dateOfBirth':
            dateOfBirth == null ? null : Timestamp.fromDate(dateOfBirth!),
        'age': age,
        'height': height,
        'weight': weight,
        'bloodType': bloodType,
        'conditions': conditions,
        'symptoms': symptoms,
        'onboardingComplete': onboardingComplete,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'lastActiveAt':
            lastActiveAt == null ? null : Timestamp.fromDate(lastActiveAt!),
        'conditionType': conditionType,
        'latestAssessmentScore': latestAssessmentScore,
        'latestSeverityLabel': latestSeverityLabel,
        'carePlanType': carePlanType,
        'hasUsedFreeConsultation': hasUsedFreeConsultation,
        'primaryDoctorId': primaryDoctorId,
        'primaryDoctorName': primaryDoctorName,
        'doctorNotes': doctorNotes,
        'activeHabitIds': activeHabitIds,
        'healthVitalityScore': healthVitalityScore,
        'lastLogDate':
            lastLogDate == null ? null : Timestamp.fromDate(lastLogDate!),
        'prescriptionUrl': prescriptionUrl,
      };

  UsersRecord copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? dateOfBirth,
    int? age,
    double? height,
    double? weight,
    String? bloodType,
    List<String>? conditions,
    List<String>? symptoms,
    bool? onboardingComplete,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? conditionType,
    int? latestAssessmentScore,
    String? latestSeverityLabel,
    String? carePlanType,
    bool? hasUsedFreeConsultation,
    String? primaryDoctorId,
    String? primaryDoctorName,
    String? doctorNotes,
    List<String>? activeHabitIds,
    int? healthVitalityScore,
    DateTime? lastLogDate,
    String? prescriptionUrl,
  }) =>
      UsersRecord(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        age: age ?? this.age,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        bloodType: bloodType ?? this.bloodType,
        conditions: conditions ?? this.conditions,
        symptoms: symptoms ?? this.symptoms,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        createdAt: createdAt ?? this.createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        conditionType: conditionType ?? this.conditionType,
        latestAssessmentScore:
            latestAssessmentScore ?? this.latestAssessmentScore,
        latestSeverityLabel:
            latestSeverityLabel ?? this.latestSeverityLabel,
        carePlanType: carePlanType ?? this.carePlanType,
        hasUsedFreeConsultation:
            hasUsedFreeConsultation ?? this.hasUsedFreeConsultation,
        primaryDoctorId: primaryDoctorId ?? this.primaryDoctorId,
        primaryDoctorName: primaryDoctorName ?? this.primaryDoctorName,
        doctorNotes: doctorNotes ?? this.doctorNotes,
        activeHabitIds: activeHabitIds ?? this.activeHabitIds,
        healthVitalityScore:
            healthVitalityScore ?? this.healthVitalityScore,
        lastLogDate: lastLogDate ?? this.lastLogDate,
        prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      );
}
