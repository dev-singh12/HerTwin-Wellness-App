import 'package:cloud_firestore/cloud_firestore.dart';

/// Call once from HomeDashboard initState (guarded by Firestore meta doc).
Future<void> seedDoctorsIfNeeded() async {
  final metaDoc =
      await FirebaseFirestore.instance.doc('meta/seeded_doctors').get();
  if (metaDoc.exists) return;

  final batch = FirebaseFirestore.instance.batch();

  final doctors = <Map<String, dynamic>>[
    {
      'name': 'Dr. Sarah Jenkins',
      'specialty': 'Gynaecologist',
      'qualifications': 'MBBS, MD (Obstetrics & Gynaecology)',
      'rating': 4.9,
      'reviewCount': 247,
      'isAvailable': true,
      'conditionsTreated': ['pcos', 'pcod', 'irregular', 'pms'],
      'consultationMode': 'all',
      'yearsExperience': 12,
      'bio':
          'Specializing in hormonal disorders and women\'s reproductive health.',
      'languagesSpoken': 'English, Hindi',
      'photoUrl': '',
    },
    {
      'name': 'Dr. Priya Mehta',
      'specialty': 'Endocrinologist',
      'qualifications': 'MBBS, MD (Endocrinology)',
      'rating': 4.8,
      'reviewCount': 183,
      'isAvailable': true,
      'conditionsTreated': ['pcos', 'pcod'],
      'consultationMode': 'all',
      'yearsExperience': 9,
      'bio':
          'Expert in insulin resistance, hormonal balance, and PCOS management.',
      'languagesSpoken': 'English, Hindi, Marathi',
      'photoUrl': '',
    },
    {
      'name': 'Dr. Ananya Roy',
      'specialty': 'Gynaecologist',
      'qualifications': 'MBBS, DNB (Gynaecology)',
      'rating': 4.7,
      'reviewCount': 156,
      'isAvailable': true,
      'conditionsTreated': ['pms', 'pmdd', 'irregular'],
      'consultationMode': 'all',
      'yearsExperience': 7,
      'bio': 'Focused on menstrual disorders and premenstrual syndromes.',
      'languagesSpoken': 'English, Bengali, Hindi',
      'photoUrl': '',
    },
    {
      'name': 'Dr. Kavya Nair',
      'specialty': 'Psychologist',
      'qualifications': 'MSc (Clinical Psychology), MPhil',
      'rating': 4.9,
      'reviewCount': 89,
      'isAvailable': false,
      'conditionsTreated': ['pmdd', 'pms'],
      'consultationMode': 'chat',
      'yearsExperience': 5,
      'bio':
          'Specializing in PMDD, mood disorders, and women\'s mental health.',
      'languagesSpoken': 'English, Malayalam, Hindi',
      'photoUrl': '',
    },
    {
      'name': 'Dr. Ritu Sharma',
      'specialty': 'Nutritionist & Dietician',
      'qualifications': 'MSc (Clinical Nutrition), RD',
      'rating': 4.8,
      'reviewCount': 201,
      'isAvailable': true,
      'conditionsTreated': ['pcos', 'pcod', 'pms'],
      'consultationMode': 'all',
      'yearsExperience': 8,
      'bio': 'Evidence-based nutrition plans for hormonal conditions.',
      'languagesSpoken': 'English, Hindi, Punjabi',
      'photoUrl': '',
    },
    {
      'name': 'Dr. Meena Krishnan',
      'specialty': 'Gynaecologist',
      'qualifications': 'MBBS, MS (Obstetrics & Gynaecology)',
      'rating': 4.6,
      'reviewCount': 134,
      'isAvailable': true,
      'conditionsTreated': ['pcos', 'pcod', 'pms', 'pmdd', 'irregular'],
      'consultationMode': 'all',
      'yearsExperience': 15,
      'bio': 'Senior gynaecologist with 15+ years in hormonal care.',
      'languagesSpoken': 'English, Tamil, Hindi',
      'photoUrl': '',
    },
  ];

  for (int i = 0; i < doctors.length; i++) {
    final ref =
        FirebaseFirestore.instance.collection('doctors').doc('doctor_$i');
    batch.set(ref, {
      ...doctors[i],
      'doctorId': 'doctor_$i',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  batch.set(
    FirebaseFirestore.instance.doc('meta/seeded_doctors'),
    {'seededAt': FieldValue.serverTimestamp()},
  );

  await batch.commit();
}
