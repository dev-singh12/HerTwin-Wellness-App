import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorRecord {
  const DoctorRecord({
    this.id = '',
    this.name = '',
    this.specialty = '',
    this.qualifications = '',
    this.photoUrl = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = false,
    this.conditionsTreated = const <String>[],
    this.consultationMode = 'all',
    this.yearsExperience = 0,
    this.bio = '',
    this.languagesSpoken = '',
    this.availableSlots = const <String, List<String>>{},
    this.createdAt,
  });

  final String id;
  final String name;
  final String specialty;
  final String qualifications;
  final String photoUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final List<String> conditionsTreated;
  final String consultationMode;
  final int yearsExperience;
  final String bio;
  final String languagesSpoken;
  final Map<String, List<String>> availableSlots;
  final DateTime? createdAt;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  factory DoctorRecord.fromMap(Map<String, dynamic> data, String id) =>
      DoctorRecord(
        id: (data['doctorId'] as String?) ?? id,
        name: (data['name'] as String?) ?? '',
        specialty: (data['specialty'] as String?) ?? '',
        qualifications: (data['qualifications'] as String?) ?? '',
        photoUrl: (data['photoUrl'] as String?) ?? '',
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
        isAvailable: (data['isAvailable'] as bool?) ?? false,
        conditionsTreated: (data['conditionsTreated'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const <String>[],
        consultationMode: (data['consultationMode'] as String?) ?? 'all',
        yearsExperience: (data['yearsExperience'] as num?)?.toInt() ?? 0,
        bio: (data['bio'] as String?) ?? '',
        languagesSpoken: (data['languagesSpoken'] as String?) ?? '',
        availableSlots: _parseSlots(data['availableSlots']),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  static Map<String, List<String>> _parseSlots(dynamic raw) {
    if (raw == null || raw is! Map) return const <String, List<String>>{};
    return (raw as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        k,
        (v as List?)?.map((e) => e as String).toList() ?? const <String>[],
      ),
    );
  }

  factory DoctorRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      DoctorRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'doctorId': id,
        'name': name,
        'specialty': specialty,
        'qualifications': qualifications,
        'photoUrl': photoUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'isAvailable': isAvailable,
        'conditionsTreated': conditionsTreated,
        'consultationMode': consultationMode,
        'yearsExperience': yearsExperience,
        'bio': bio,
        'languagesSpoken': languagesSpoken,
        'availableSlots': availableSlots,
        'createdAt':
            createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  DoctorRecord copyWith({
    String? id,
    String? name,
    String? specialty,
    String? qualifications,
    String? photoUrl,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    List<String>? conditionsTreated,
    String? consultationMode,
    int? yearsExperience,
    String? bio,
    String? languagesSpoken,
    Map<String, List<String>>? availableSlots,
    DateTime? createdAt,
  }) =>
      DoctorRecord(
        id: id ?? this.id,
        name: name ?? this.name,
        specialty: specialty ?? this.specialty,
        qualifications: qualifications ?? this.qualifications,
        photoUrl: photoUrl ?? this.photoUrl,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        isAvailable: isAvailable ?? this.isAvailable,
        conditionsTreated: conditionsTreated ?? this.conditionsTreated,
        consultationMode: consultationMode ?? this.consultationMode,
        yearsExperience: yearsExperience ?? this.yearsExperience,
        bio: bio ?? this.bio,
        languagesSpoken: languagesSpoken ?? this.languagesSpoken,
        availableSlots: availableSlots ?? this.availableSlots,
        createdAt: createdAt ?? this.createdAt,
      );
}
