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
      );
}
