import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingAssessmentRecord {
  const OnboardingAssessmentRecord({
    this.id = '',
    this.uid = '',
    this.conditionType = '',
    this.answers = const <String, int>{},
    this.totalScore = 0,
    this.severityLevel = '',
    this.diagnosisLabel = '',
    this.carePlanType = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String uid;
  final String conditionType;
  final Map<String, int> answers;
  final int totalScore;
  final String severityLevel;
  final String diagnosisLabel;
  final String carePlanType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OnboardingAssessmentRecord.fromMap(
          Map<String, dynamic> data, String id) =>
      OnboardingAssessmentRecord(
        id: (data['id'] as String?) ?? id,
        uid: (data['uid'] as String?) ?? '',
        conditionType: (data['conditionType'] as String?) ?? '',
        answers: (data['answers'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            const <String, int>{},
        totalScore: (data['totalScore'] as num?)?.toInt() ?? 0,
        severityLevel: (data['severityLevel'] as String?) ?? '',
        diagnosisLabel: (data['diagnosisLabel'] as String?) ?? '',
        carePlanType: (data['carePlanType'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory OnboardingAssessmentRecord.fromSnapshot(
          DocumentSnapshot snapshot) =>
      OnboardingAssessmentRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'conditionType': conditionType,
        'answers': answers,
        'totalScore': totalScore,
        'severityLevel': severityLevel,
        'diagnosisLabel': diagnosisLabel,
        'carePlanType': carePlanType,
        'createdAt':
            createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'updatedAt':
            updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      };

  OnboardingAssessmentRecord copyWith({
    String? id,
    String? uid,
    String? conditionType,
    Map<String, int>? answers,
    int? totalScore,
    String? severityLevel,
    String? diagnosisLabel,
    String? carePlanType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      OnboardingAssessmentRecord(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        conditionType: conditionType ?? this.conditionType,
        answers: answers ?? this.answers,
        totalScore: totalScore ?? this.totalScore,
        severityLevel: severityLevel ?? this.severityLevel,
        diagnosisLabel: diagnosisLabel ?? this.diagnosisLabel,
        carePlanType: carePlanType ?? this.carePlanType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
