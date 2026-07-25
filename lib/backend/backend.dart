import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'schema/users_record.dart';
import 'schema/cycles_record.dart';
import 'schema/moods_record.dart';
import 'schema/symptoms_record.dart';
import 'schema/sleep_record.dart';
import 'schema/water_record.dart';
import 'schema/exercises_record.dart';
import 'schema/journals_record.dart';
import 'schema/goals_record.dart';
import 'schema/posts_record.dart';
import 'schema/comments_record.dart';
import 'schema/onboarding_assessment_record.dart';
import 'schema/doctor_record.dart';
import 'schema/appointment_record.dart';
import 'schema/medicine_reminder_record.dart';
import 'schema/reminder_log_record.dart';
import 'schema/health_habit_record.dart';
import 'schema/habit_log_record.dart';

export 'schema/users_record.dart';
export 'schema/cycles_record.dart';
export 'schema/moods_record.dart';
export 'schema/symptoms_record.dart';
export 'schema/sleep_record.dart';
export 'schema/water_record.dart';
export 'schema/exercises_record.dart';
export 'schema/journals_record.dart';
export 'schema/goals_record.dart';
export 'schema/posts_record.dart';
export 'schema/comments_record.dart';
export 'schema/onboarding_assessment_record.dart';
export 'schema/doctor_record.dart';
export 'schema/appointment_record.dart';
export 'schema/medicine_reminder_record.dart';
export 'schema/reminder_log_record.dart';
export 'schema/health_habit_record.dart';
export 'schema/habit_log_record.dart';

FirebaseFirestore get _db => FirebaseFirestore.instance;

// ---------------------------------------------------------------------------
// users (doc id = uid)
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> get usersCollection =>
    _db.collection('users');

DocumentReference<Map<String, dynamic>> userRef(String uid) =>
    usersCollection.doc(uid);

Stream<UsersRecord> streamUser(String uid) =>
    userRef(uid).snapshots().map(UsersRecord.fromSnapshot);

Future<UsersRecord?> getUser(String uid) async {
  final snapshot = await userRef(uid).get();
  return snapshot.exists ? UsersRecord.fromSnapshot(snapshot) : null;
}

Future<void> createUser(UsersRecord user) => userRef(user.uid).set(user.toMap());

Future<void> updateUser(String uid, Map<String, dynamic> data) =>
    userRef(uid).update(data);

Future<void> deleteUser(String uid) => userRef(uid).delete();

// ---------------------------------------------------------------------------
// Firebase Storage — profile photos
// ---------------------------------------------------------------------------

/// Free-tier image "upload". Cloud Storage for Firebase needs the Blaze plan,
/// which this pilot deliberately avoids, so instead of a bucket URL we inline
/// the image as a base64 `data:` URI and hand it back for the caller to store
/// in the very same Firestore field it always used (photoUrl / prescriptionUrl
/// / a chat message). `AppImage` renders `data:` URIs directly.
///
/// The 700KB guard keeps a single image well under Firestore's 1MB document
/// limit (base64 inflates ~33%). Callers already downscale at the image picker.
/// ponytail: data-URI-in-Firestore; swap for real Storage once on Blaze.
String _encodeImage(Uint8List bytes, String contentType) {
  const maxBytes = 700 * 1024;
  if (bytes.lengthInBytes > maxBytes) {
    throw Exception(
        'Image is too large. Please choose a smaller or clearer photo.');
  }
  return 'data:$contentType;base64,${base64Encode(bytes)}';
}

/// Returns a storable image reference for the given [bytes]. Signature kept
/// stable (async + returns a String the caller persists) so no call site needed
/// to change when this moved off Cloud Storage.
Future<String> uploadProfilePhoto(
  String uid,
  Uint8List bytes, {
  String contentType = 'image/jpeg',
}) async =>
    _encodeImage(bytes, contentType);

Future<String> uploadPrescription(
  String uid,
  Uint8List bytes, {
  String contentType = 'image/jpeg',
  String extension = 'jpg',
}) async =>
    _encodeImage(bytes, contentType);

// ---------------------------------------------------------------------------
// users/{uid}/cycles
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> cyclesCollection(String uid) =>
    userRef(uid).collection('cycles');

DocumentReference<Map<String, dynamic>> cycleRef(String uid, String id) =>
    cyclesCollection(uid).doc(id);

String newCycleId(String uid) => cyclesCollection(uid).doc().id;

Stream<List<CyclesRecord>> streamCycles(String uid) => cyclesCollection(uid)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((s) => s.docs.map(CyclesRecord.fromSnapshot).toList());

Stream<CyclesRecord> streamCycle(String uid, String id) =>
    cycleRef(uid, id).snapshots().map(CyclesRecord.fromSnapshot);

Future<void> createCycle(String uid, CyclesRecord record) =>
    cycleRef(uid, record.id).set(record.toMap());

Future<void> updateCycle(String uid, String id, Map<String, dynamic> data) =>
    cycleRef(uid, id).update(data);

Future<void> deleteCycle(String uid, String id) => cycleRef(uid, id).delete();

// ---------------------------------------------------------------------------
// users/{uid}/moods
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> moodsCollection(String uid) =>
    userRef(uid).collection('moods');

DocumentReference<Map<String, dynamic>> moodRef(String uid, String id) =>
    moodsCollection(uid).doc(id);

String newMoodId(String uid) => moodsCollection(uid).doc().id;

Stream<List<MoodsRecord>> streamMoods(String uid) => moodsCollection(uid)
    .orderBy('date', descending: true)
    .snapshots()
    .map((s) => s.docs.map(MoodsRecord.fromSnapshot).toList());

Stream<MoodsRecord> streamMood(String uid, String id) =>
    moodRef(uid, id).snapshots().map(MoodsRecord.fromSnapshot);

Future<void> createMood(String uid, MoodsRecord record) =>
    moodRef(uid, record.id).set(record.toMap());

Future<void> updateMood(String uid, String id, Map<String, dynamic> data) =>
    moodRef(uid, id).update(data);

Future<void> deleteMood(String uid, String id) => moodRef(uid, id).delete();

// ---------------------------------------------------------------------------
// users/{uid}/symptoms
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> symptomsCollection(String uid) =>
    userRef(uid).collection('symptoms');

DocumentReference<Map<String, dynamic>> symptomRef(String uid, String id) =>
    symptomsCollection(uid).doc(id);

String newSymptomId(String uid) => symptomsCollection(uid).doc().id;

Stream<List<SymptomsRecord>> streamSymptoms(String uid) =>
    symptomsCollection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(SymptomsRecord.fromSnapshot).toList());

Stream<SymptomsRecord> streamSymptom(String uid, String id) =>
    symptomRef(uid, id).snapshots().map(SymptomsRecord.fromSnapshot);

Future<void> createSymptom(String uid, SymptomsRecord record) =>
    symptomRef(uid, record.id).set(record.toMap());

Future<void> updateSymptom(String uid, String id, Map<String, dynamic> data) =>
    symptomRef(uid, id).update(data);

Future<void> deleteSymptom(String uid, String id) =>
    symptomRef(uid, id).delete();

// ---------------------------------------------------------------------------
// users/{uid}/sleep
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> sleepCollection(String uid) =>
    userRef(uid).collection('sleep');

DocumentReference<Map<String, dynamic>> sleepRef(String uid, String id) =>
    sleepCollection(uid).doc(id);

String newSleepId(String uid) => sleepCollection(uid).doc().id;

Stream<List<SleepRecord>> streamSleep(String uid) => sleepCollection(uid)
    .orderBy('date', descending: true)
    .snapshots()
    .map((s) => s.docs.map(SleepRecord.fromSnapshot).toList());

Stream<SleepRecord> streamSleepEntry(String uid, String id) =>
    sleepRef(uid, id).snapshots().map(SleepRecord.fromSnapshot);

Future<void> createSleep(String uid, SleepRecord record) =>
    sleepRef(uid, record.id).set(record.toMap());

Future<void> updateSleep(String uid, String id, Map<String, dynamic> data) =>
    sleepRef(uid, id).update(data);

Future<void> deleteSleep(String uid, String id) => sleepRef(uid, id).delete();

// ---------------------------------------------------------------------------
// users/{uid}/water (doc id = yyyy-MM-dd date key)
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> waterCollection(String uid) =>
    userRef(uid).collection('water');

DocumentReference<Map<String, dynamic>> waterRef(String uid, String date) =>
    waterCollection(uid).doc(date);

Stream<List<WaterRecord>> streamWater(String uid) => waterCollection(uid)
    .orderBy('date', descending: true)
    .snapshots()
    .map((s) => s.docs.map(WaterRecord.fromSnapshot).toList());

Stream<WaterRecord> streamWaterForDate(String uid, String date) =>
    waterRef(uid, date).snapshots().map(WaterRecord.fromSnapshot);

Future<WaterRecord?> getWaterForDate(String uid, String date) async {
  final snapshot = await waterRef(uid, date).get();
  return snapshot.exists ? WaterRecord.fromSnapshot(snapshot) : null;
}

Future<void> setWater(String uid, WaterRecord record) =>
    waterRef(uid, record.date).set(record.toMap());

Future<void> updateWater(String uid, String date, Map<String, dynamic> data) =>
    waterRef(uid, date).set(data, SetOptions(merge: true));

// ---------------------------------------------------------------------------
// users/{uid}/exercises
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> exercisesCollection(String uid) =>
    userRef(uid).collection('exercises');

DocumentReference<Map<String, dynamic>> exerciseRef(String uid, String id) =>
    exercisesCollection(uid).doc(id);

String newExerciseId(String uid) => exercisesCollection(uid).doc().id;

Stream<List<ExercisesRecord>> streamExercises(String uid) =>
    exercisesCollection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ExercisesRecord.fromSnapshot).toList());

Stream<ExercisesRecord> streamExercise(String uid, String id) =>
    exerciseRef(uid, id).snapshots().map(ExercisesRecord.fromSnapshot);

Future<void> createExercise(String uid, ExercisesRecord record) =>
    exerciseRef(uid, record.id).set(record.toMap());

Future<void> updateExercise(String uid, String id, Map<String, dynamic> data) =>
    exerciseRef(uid, id).update(data);

Future<void> deleteExercise(String uid, String id) =>
    exerciseRef(uid, id).delete();

// ---------------------------------------------------------------------------
// users/{uid}/journals
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> journalsCollection(String uid) =>
    userRef(uid).collection('journals');

DocumentReference<Map<String, dynamic>> journalRef(String uid, String id) =>
    journalsCollection(uid).doc(id);

String newJournalId(String uid) => journalsCollection(uid).doc().id;

Stream<List<JournalsRecord>> streamJournals(String uid) =>
    journalsCollection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(JournalsRecord.fromSnapshot).toList());

Stream<JournalsRecord> streamJournal(String uid, String id) =>
    journalRef(uid, id).snapshots().map(JournalsRecord.fromSnapshot);

Future<void> createJournal(String uid, JournalsRecord record) =>
    journalRef(uid, record.id).set(record.toMap());

Future<void> updateJournal(String uid, String id, Map<String, dynamic> data) =>
    journalRef(uid, id).update(data);

Future<void> deleteJournal(String uid, String id) =>
    journalRef(uid, id).delete();

// ---------------------------------------------------------------------------
// users/{uid}/goals
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> goalsCollection(String uid) =>
    userRef(uid).collection('goals');

DocumentReference<Map<String, dynamic>> goalRef(String uid, String id) =>
    goalsCollection(uid).doc(id);

String newGoalId(String uid) => goalsCollection(uid).doc().id;

Stream<List<GoalsRecord>> streamGoals(String uid) => goalsCollection(uid)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((s) => s.docs.map(GoalsRecord.fromSnapshot).toList());

Stream<GoalsRecord> streamGoal(String uid, String id) =>
    goalRef(uid, id).snapshots().map(GoalsRecord.fromSnapshot);

Future<void> createGoal(String uid, GoalsRecord record) =>
    goalRef(uid, record.id).set(record.toMap());

Future<void> updateGoal(String uid, String id, Map<String, dynamic> data) =>
    goalRef(uid, id).update(data);

Future<void> deleteGoal(String uid, String id) => goalRef(uid, id).delete();

// ---------------------------------------------------------------------------
// Community — top-level `posts` (cross-user)
//   posts/{postId}
//   posts/{postId}/likes/{uid}
//   posts/{postId}/comments/{commentId}
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> get postsCollection =>
    _db.collection('posts');

DocumentReference<Map<String, dynamic>> postRef(String id) =>
    postsCollection.doc(id);

String newPostId() => postsCollection.doc().id;

Stream<List<PostsRecord>> streamPosts({int limit = 50, String? category}) {
  Query<Map<String, dynamic>> q = postsCollection;
  if (category != null && category.isNotEmpty) {
    q = q.where('category', isEqualTo: category);
  }
  return q
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(PostsRecord.fromSnapshot).toList());
}

Future<void> createPost(PostsRecord record) =>
    postRef(record.id).set(record.toMap());

Future<void> deletePost(String id) => postRef(id).delete();

// --- likes ---------------------------------------------------------------

CollectionReference<Map<String, dynamic>> postLikesCollection(String postId) =>
    postRef(postId).collection('likes');

DocumentReference<Map<String, dynamic>> postLikeRef(
        String postId, String uid) =>
    postLikesCollection(postId).doc(uid);

/// Whether [uid] has liked [postId] (live).
Stream<bool> streamPostLiked(String postId, String uid) =>
    postLikeRef(postId, uid).snapshots().map((s) => s.exists);

/// Toggles a like for [uid] on [postId] and keeps `likeCount` in sync.
/// Returns the new liked state (true = now liked).
Future<bool> togglePostLike(String postId, String uid) {
  final postDoc = postRef(postId);
  final likeDoc = postLikeRef(postId, uid);
  return _db.runTransaction<bool>((txn) async {
    final likeSnap = await txn.get(likeDoc);
    final postSnap = await txn.get(postDoc);
    final current = (postSnap.data()?['likeCount'] as num?)?.toInt() ?? 0;
    if (likeSnap.exists) {
      txn.delete(likeDoc);
      txn.update(postDoc, {'likeCount': current > 0 ? current - 1 : 0});
      return false;
    }
    txn.set(likeDoc, {
      'uid': uid,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    txn.update(postDoc, {'likeCount': current + 1});
    return true;
  });
}

/// Live set of post IDs that [uid] has liked (used by the "Saved" tab).
/// Backed by a collection-group query on `likes` (see firestore.indexes.json).
Stream<Set<String>> streamLikedPostIds(String uid) => _db
    .collectionGroup('likes')
    .where('uid', isEqualTo: uid)
    .snapshots()
    .map((s) => s.docs
        .map((d) => d.reference.parent.parent?.id)
        .whereType<String>()
        .toSet());

// --- comments ------------------------------------------------------------

CollectionReference<Map<String, dynamic>> postCommentsCollection(
        String postId) =>
    postRef(postId).collection('comments');

Stream<List<CommentsRecord>> streamComments(String postId) =>
    postCommentsCollection(postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(CommentsRecord.fromSnapshot).toList());

/// Adds [comment] to [postId] and increments `commentCount` atomically.
Future<void> addComment(String postId, CommentsRecord comment) {
  final postDoc = postRef(postId);
  final commentDoc = postCommentsCollection(postId).doc();
  return _db.runTransaction((txn) async {
    final postSnap = await txn.get(postDoc);
    final current = (postSnap.data()?['commentCount'] as num?)?.toInt() ?? 0;
    txn.set(commentDoc, comment.copyWith(id: commentDoc.id).toMap());
    txn.update(postDoc, {'commentCount': current + 1});
  });
}

// ---------------------------------------------------------------------------
// Community moderation — reporting and blocking.
//
// Google Play requires any app carrying user-generated content to offer
// in-app reporting AND blocking. Both are policy requirements, not features.
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> get reportsCollection =>
    _db.collection('reports');

/// Files a moderation report. Reports are write-only from the client: a user
/// can create one but cannot read, edit or delete anyone's — including their
/// own — so the queue cannot be inspected or tampered with from the app.
Future<void> reportContent({
  required String reporterUid,
  required String contentType,
  required String contentId,
  required String reason,
  String? authorUid,
}) =>
    reportsCollection.doc().set({
      'reporterUid': reporterUid,
      'contentType': contentType,
      'contentId': contentId,
      'authorUid': authorUid ?? '',
      'reason': reason,
      'status': 'open',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

CollectionReference<Map<String, dynamic>> blockedCollection(String uid) =>
    userRef(uid).collection('blocked');

/// Live set of uids [uid] has blocked. Filtering happens client-side: hiding
/// a blocked author's posts must not require a rule that would let one user
/// suppress another's content for everybody.
Stream<Set<String>> streamBlockedUids(String uid) => blockedCollection(uid)
    .snapshots()
    .map((s) => s.docs.map((d) => d.id).toSet());

Future<void> blockUser(String uid, String blockedUid) =>
    blockedCollection(uid).doc(blockedUid).set({
      'blockedUid': blockedUid,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

Future<void> unblockUser(String uid, String blockedUid) =>
    blockedCollection(uid).doc(blockedUid).delete();

// ---------------------------------------------------------------------------
// Account deletion
//
// Google Play requires an in-app route to delete the account and its data.
// ---------------------------------------------------------------------------

/// Every subcollection under `users/{uid}`. Kept explicit rather than
/// discovered at runtime, because the client SDK cannot enumerate
/// subcollections — a forgotten name here means orphaned health data.
const _userSubcollections = <String>[
  'cycles', 'moods', 'symptoms', 'sleep', 'water', 'exercises',
  'journals', 'goals', 'assessments', 'reminders', 'reminder_logs',
  'habits', 'habit_logs', 'feedback', 'score_logs', 'consents', 'blocked',
];

/// Deletes all of a user's health data, then the profile document itself.
///
/// Deliberately does NOT delete their community posts: those are visible to
/// others and deleting them would tear holes in other people's comment
/// threads. They are anonymised instead.
///
/// Appointments are also left alone — a clinician's consultation record may
/// be subject to medical retention obligations. The consent documents are
/// removed, which cuts off the clinician's access to the chart immediately.
Future<void> deleteAccountData(String uid) async {
  for (final name in _userSubcollections) {
    // Page through in batches; a long-running user can exceed the 500-write
    // limit of a single batch.
    while (true) {
      final snap = await userRef(uid).collection(name).limit(400).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < 400) break;
    }
  }

  await _anonymisePosts(uid);
  await userRef(uid).delete();
}

/// Strips identity from a departing user's community posts while leaving the
/// thread intact for everyone else.
Future<void> _anonymisePosts(String uid) async {
  final posts = await postsCollection.where('authorUid', isEqualTo: uid).get();
  for (final doc in posts.docs) {
    await doc.reference.update({
      'authorName': 'Deleted user',
      'authorInitials': '?',
      'authorPhotoUrl': '',
    });
  }
}

// ---------------------------------------------------------------------------
// Community — group membership
//   groups/{groupId}/members/{uid}
// Group metadata itself is a fixed in-app catalog (see community_groups.dart);
// only membership is persisted, enabling real cross-user member counts.
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> groupMembersCollection(
        String groupId) =>
    _db.collection('groups').doc(groupId).collection('members');

DocumentReference<Map<String, dynamic>> groupMemberRef(
        String groupId, String uid) =>
    groupMembersCollection(groupId).doc(uid);

/// Whether [uid] is a member of [groupId] (live).
Stream<bool> streamGroupJoined(String groupId, String uid) =>
    groupMemberRef(groupId, uid).snapshots().map((s) => s.exists);

/// Live member count for [groupId].
Stream<int> streamGroupMemberCount(String groupId) =>
    groupMembersCollection(groupId).snapshots().map((s) => s.size);

/// Joins/leaves [groupId] for [uid]. Returns the new joined state.
Future<bool> toggleGroupMembership(String groupId, String uid) async {
  final ref = groupMemberRef(groupId, uid);
  final snap = await ref.get();
  if (snap.exists) {
    await ref.delete();
    return false;
  }
  await ref.set({'createdAt': Timestamp.fromDate(DateTime.now())});
  return true;
}

// ---------------------------------------------------------------------------
// users/{uid}/assessments
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> assessmentsCollection(String uid) =>
    userRef(uid).collection('assessments');

String newAssessmentId(String uid) => assessmentsCollection(uid).doc().id;

Stream<OnboardingAssessmentRecord?> streamLatestAssessment(String uid) =>
    assessmentsCollection(uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : OnboardingAssessmentRecord.fromSnapshot(s.docs.first));

Future<void> saveAssessment(
    String uid, OnboardingAssessmentRecord record) =>
    assessmentsCollection(uid).doc(record.id).set(record.toMap());

// ---------------------------------------------------------------------------
// doctors (top-level, admin-seeded)
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> get doctorsCollection =>
    _db.collection('doctors');

/// Whether [uid] is a clinician account.
///
/// A `doctors/{uid}` document keyed by the auth uid IS the role. It can only
/// be created server-side (see `tool/seed_doctors.js`), so a client cannot
/// promote itself — the same check backs every doctor rule in firestore.rules.
Future<bool> isDoctorAccount(String uid) async {
  if (uid.isEmpty) return false;
  final snap = await doctorsCollection.doc(uid).get();
  return snap.exists;
}

Future<DoctorRecord?> getDoctorProfile(String uid) async {
  final snap = await doctorsCollection.doc(uid).get();
  return snap.exists ? DoctorRecord.fromSnapshot(snap) : null;
}

/// Files a request to become a clinician at `doctor_applications/{uid}`.
///
/// Clients can only CREATE their own application (rules forbid read/update/
/// delete), so this is a one-way outbox. Being unapproved grants nothing — the
/// account stays a normal patient until an admin reviews the request and
/// provisions `doctors/{uid}` server-side (`node tool/admin.js promote`). This
/// is what keeps "sign up as a doctor" from being a privilege-escalation hole.
Future<void> submitDoctorApplication(
  String uid, {
  required String name,
  required String email,
}) =>
    _db.collection('doctor_applications').doc(uid).set({
      'uid': uid,
      'name': name.length > 120 ? name.substring(0, 120) : name,
      'email': email.length > 200 ? email.substring(0, 200) : email,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

Stream<List<DoctorRecord>> streamAvailableDoctors(
        {List<String>? conditions}) =>
    doctorsCollection.snapshots().map((s) {
      var docs = s.docs.map(DoctorRecord.fromSnapshot).toList();
      if (conditions != null && conditions.isNotEmpty) {
        docs = docs
            .where((d) =>
                d.conditionsTreated.any((c) => conditions.contains(c)))
            .toList();
      }
      return docs;
    });

Stream<DoctorRecord> streamDoctorById(String doctorId) =>
    doctorsCollection.doc(doctorId).snapshots().map(DoctorRecord.fromSnapshot);

Future<List<String>> getDoctorSlots(String doctorId, String date) async {
  final snap = await doctorsCollection.doc(doctorId).get();
  if (!snap.exists) return [];
  final doc = DoctorRecord.fromSnapshot(snap);
  final base = doc.availableSlots[date] ?? _generateDefaultSlots();

  // For today, drop slots that have already passed (plus a 30-minute lead
  // time) — you cannot book 9:00am at 4:35pm. Future dates keep every slot.
  final now = DateTime.now();
  final today = DateFormat('yyyy-MM-dd').format(now);
  if (date != today) return base;
  final cutoff = now.add(const Duration(minutes: 30));
  return base.where((s) {
    final parts = s.split(':');
    if (parts.length != 2) return true;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return true;
    final slot = DateTime(now.year, now.month, now.day, h, m);
    return slot.isAfter(cutoff);
  }).toList();
}

List<String> _generateDefaultSlots() {
  return [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
  ];
}

// ---------------------------------------------------------------------------
// users/{uid}/consents/{doctorUid}
//
// The patient's explicit, revocable grant letting one doctor read their health
// data. Firestore rules key doctor access off the existence of this document,
// so revoking it cuts off access on the next read — no cache to invalidate.
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> consentsCollection(String uid) =>
    userRef(uid).collection('consents');

Stream<List<String>> streamConsentedDoctorIds(String uid) =>
    consentsCollection(uid).snapshots().map((s) => s.docs.map((d) => d.id).toList());

Future<void> grantDoctorConsent(
  String patientUid, {
  required String doctorUid,
  required String doctorName,
}) =>
    consentsCollection(patientUid).doc(doctorUid).set({
      'doctorUid': doctorUid,
      'doctorName': doctorName,
      'grantedAt': Timestamp.fromDate(DateTime.now()),
    });

/// Revokes a doctor's access to this patient's health data.
Future<void> revokeDoctorConsent(String patientUid, String doctorUid) =>
    consentsCollection(patientUid).doc(doctorUid).delete();

// ---------------------------------------------------------------------------
// appointments (TOP LEVEL) — appointments/{appointmentId}
//
// Deliberately not nested under users/{uid}: a doctor must be able to read
// bookings made against them, and burying them in the patient's private tree
// makes that impossible without over-granting access to everything else.
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> get appointmentsCollection =>
    _db.collection('appointments');

DocumentReference<Map<String, dynamic>> appointmentRef(String id) =>
    appointmentsCollection.doc(id);

String newAppointmentId() => appointmentsCollection.doc().id;

Stream<AppointmentRecord> streamAppointment(String appointmentId) =>
    appointmentRef(appointmentId)
        .snapshots()
        .map(AppointmentRecord.fromSnapshot);

/// All of a patient's bookings, newest first.
Stream<List<AppointmentRecord>> streamPatientAppointments(String patientUid) =>
    appointmentsCollection
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AppointmentRecord.fromSnapshot).toList());

/// Everything booked against a doctor, soonest first — the doctor's queue.
Stream<List<AppointmentRecord>> streamDoctorAppointments(String doctorUid) =>
    appointmentsCollection
        .where('doctorUid', isEqualTo: doctorUid)
        .orderBy('scheduledAt')
        .snapshots()
        .map((s) => s.docs.map(AppointmentRecord.fromSnapshot).toList());

/// Books a consultation and grants the doctor consent to view the patient's
/// health data, atomically — the doctor should never end up with a booking
/// they cannot open, nor consent without a booking.
Future<void> bookAppointment(AppointmentRecord record) {
  final batch = _db.batch();
  batch.set(appointmentRef(record.id), record.toMap());
  batch.set(
    consentsCollection(record.patientUid).doc(record.doctorUid),
    {
      'doctorUid': record.doctorUid,
      'doctorName': record.doctorName,
      'grantedAt': Timestamp.fromDate(DateTime.now()),
      'appointmentId': record.id,
    },
  );
  return batch.commit();
}

/// Patient-side cancel. Rules permit the patient to set only this one status.
Future<void> cancelAppointment(String appointmentId) =>
    appointmentRef(appointmentId).update({
      'status': 'cancelled',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

/// Doctor-side lifecycle + clinical notes. Rules restrict this field set to
/// the assigned doctor.
Future<void> doctorUpdateAppointment(
  String appointmentId, {
  String? status,
  String? doctorNotes,
  String? prescriptionText,
}) {
  final data = <String, dynamic>{
    'updatedAt': Timestamp.fromDate(DateTime.now()),
  };
  if (status != null) {
    data['status'] = status;
    if (status == 'completed') {
      data['completedAt'] = Timestamp.fromDate(DateTime.now());
    }
  }
  if (doctorNotes != null) data['doctorNotes'] = doctorNotes;
  if (prescriptionText != null) data['prescriptionText'] = prescriptionText;
  return appointmentRef(appointmentId).update(data);
}

Stream<AppointmentRecord?> streamNextAppointment(String patientUid) =>
    appointmentsCollection
        .where('patientUid', isEqualTo: patientUid)
        .where('status', whereIn: ['booked', 'ongoing'])
        .orderBy('scheduledAt')
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : AppointmentRecord.fromSnapshot(s.docs.first));

// ---------------------------------------------------------------------------
// Consultation chat — appointments/{appointmentId}/messages/{messageId}
//
// Messages are immutable by rule: a transcript either side can rewrite after
// the fact is not a clinical record.
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> chatMessagesCollection(
        String appointmentId) =>
    appointmentRef(appointmentId).collection('messages');

Stream<List<Map<String, dynamic>>> streamChatMessages(String appointmentId) =>
    chatMessagesCollection(appointmentId)
        .orderBy('sentAt', descending: false)
        .limit(500)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

/// Maximum characters accepted in one chat message. Mirrors the cap enforced
/// in firestore.rules — the rule is the real boundary, this is the UX hint.
const int kMaxChatMessageLength = 4000;

Future<void> sendChatMessage(
  String appointmentId, {
  required String senderUid,
  required String senderName,
  required String content,
  String type = 'text',
}) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Message content cannot be empty.');
  }
  if (trimmed.length > kMaxChatMessageLength) {
    throw ArgumentError('Message exceeds $kMaxChatMessageLength characters.');
  }
  return chatMessagesCollection(appointmentId).doc().set({
    'senderUid': senderUid,
    'senderName': senderName,
    'content': trimmed,
    'type': type,
    'sentAt': Timestamp.fromDate(DateTime.now()),
  });
}

/// Builds the video room URL for an appointment.
///
/// meet.jit.si rooms are public to anyone holding the URL, so the room name
/// carries a high-entropy secret generated at booking time and stored on the
/// appointment document — which only the two participants can read. Guessing
/// the room from the appointment id alone is not possible.
String jitsiRoomUrl(String appointmentId, String roomSecret) =>
    'https://meet.jit.si/hertwin-$appointmentId-$roomSecret';

/// 160 bits of CSPRNG entropy, hex-encoded, for the video room name.
String generateRoomSecret() {
  final rng = Random.secure();
  return List<String>.generate(
    20,
    (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

// ---------------------------------------------------------------------------
// users/{uid}/reminders
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> remindersCollection(String uid) =>
    userRef(uid).collection('reminders');

String newReminderId(String uid) => remindersCollection(uid).doc().id;

Stream<List<MedicineReminderRecord>> streamReminders(String uid) =>
    remindersCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (s) => s.docs.map(MedicineReminderRecord.fromSnapshot).toList());

Future<void> createReminder(String uid, MedicineReminderRecord record) =>
    remindersCollection(uid).doc(record.id).set(record.toMap());

Future<void> updateReminder(
        String uid, String reminderId, Map<String, dynamic> data) =>
    remindersCollection(uid).doc(reminderId).update(data);

Future<void> deleteReminder(String uid, String reminderId) =>
    remindersCollection(uid).doc(reminderId).delete();

// ---------------------------------------------------------------------------
// users/{uid}/reminder_logs
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> reminderLogsCollection(String uid) =>
    userRef(uid).collection('reminder_logs');

Stream<List<ReminderLogRecord>> streamReminderLogs(
        String uid, String date) =>
    reminderLogsCollection(uid)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((s) => s.docs.map(ReminderLogRecord.fromSnapshot).toList());

Future<void> updateReminderLog(
    String uid, String reminderId, String date, String time, bool checked) {
  final docId = '${date}_$reminderId';
  return reminderLogsCollection(uid).doc(docId).set({
    'uid': uid,
    'reminderId': reminderId,
    'date': date,
    'timesChecked': {time: checked},
    'updatedAt': Timestamp.fromDate(DateTime.now()),
  }, SetOptions(merge: true));
}

// ---------------------------------------------------------------------------
// users/{uid}/habits
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> habitsCollection(String uid) =>
    userRef(uid).collection('habits');

String newHabitId(String uid) => habitsCollection(uid).doc().id;

Stream<List<HealthHabitRecord>> streamHabits(String uid) =>
    habitsCollection(uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(HealthHabitRecord.fromSnapshot).toList());

Future<void> createHabit(String uid, HealthHabitRecord record) =>
    habitsCollection(uid).doc(record.id).set(record.toMap());

Future<void> updateHabitRecord(
        String uid, String habitId, Map<String, dynamic> data) =>
    habitsCollection(uid).doc(habitId).update(data);

Future<void> deleteHabit(String uid, String habitId) =>
    habitsCollection(uid).doc(habitId).delete();

// ---------------------------------------------------------------------------
// users/{uid}/habit_logs
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> habitLogsCollection(String uid) =>
    userRef(uid).collection('habit_logs');

Stream<HabitLogRecord?> streamHabitLog(String uid, String date) =>
    habitLogsCollection(uid)
        .doc(date)
        .snapshots()
        .map((s) =>
            s.exists ? HabitLogRecord.fromSnapshot(s) : null);

Future<void> toggleHabit(
    String uid, String date, String habitId, bool completed) =>
    habitLogsCollection(uid).doc(date).set({
      'uid': uid,
      'date': date,
      'completedHabits': {habitId: completed},
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

Stream<List<HabitLogRecord>> streamRecentHabitLogs(String uid, int days) {
  final startDate = DateFormat('yyyy-MM-dd').format(
    DateTime.now().subtract(Duration(days: days)),
  );
  return habitLogsCollection(uid)
      .where('date', isGreaterThanOrEqualTo: startDate)
      .snapshots()
      .map((s) => s.docs.map(HabitLogRecord.fromSnapshot).toList());
}

// ---------------------------------------------------------------------------
// users/{uid}/feedback
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> feedbackCollection(String uid) =>
    userRef(uid).collection('feedback');

Future<void> saveFeedback(
        String uid, int rating, String comment) =>
    feedbackCollection(uid).doc().set({
      'uid': uid,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

// ---------------------------------------------------------------------------
// users/{uid}/score_logs
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> scoreLogsCollection(String uid) =>
    userRef(uid).collection('score_logs');

Future<void> saveScoreLog(String uid, String date, int score) =>
    scoreLogsCollection(uid).doc(date).set({
      'date': date,
      'score': score,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

Stream<List<Map<String, dynamic>>> streamScoreLogs(
        String uid, int days) =>
    scoreLogsCollection(uid)
        .orderBy('date', descending: true)
        .limit(days)
        .snapshots()
        .map((s) => s.docs
            .map((d) => d.data())
            .toList());

// ---------------------------------------------------------------------------
// meta (seeding guard)
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> get metaCollection =>
    _db.collection('meta');

// ---------------------------------------------------------------------------
// Habit seeding helpers
// ---------------------------------------------------------------------------

Future<void> saveHabitsForCondition(
    String uid, String conditionType, String severity) async {
  final habits = _habitsForCondition(conditionType, severity);
  final batch = _db.batch();
  final ids = <String>[];
  for (final h in habits) {
    final id = newHabitId(uid);
    ids.add(id);
    batch.set(habitsCollection(uid).doc(id), h.copyWith(
      id: id,
      uid: uid,
      conditionTag: conditionType,
      createdAt: DateTime.now(),
    ).toMap());
  }
  batch.update(userRef(uid), {'activeHabitIds': ids});
  await batch.commit();
}

List<HealthHabitRecord> _habitsForCondition(
    String conditionType, String severity) {
  switch (conditionType) {
    case 'pcos':
    case 'pcod':
      if (severity == 'severe' || severity == 'moderate') {
        return const [
          HealthHabitRecord(title: 'Drink 8 glasses of water', category: 'nutrition', icon: '\u{1F4A7}', isSystemGenerated: true, targetDays: 7),
          HealthHabitRecord(title: 'Eat a low-glycemic meal', category: 'nutrition', icon: '\u{1F957}', isSystemGenerated: true, targetDays: 7),
          HealthHabitRecord(title: '30 min low-impact exercise', category: 'exercise', icon: '\u{1F3C3}', isSystemGenerated: true, targetDays: 5),
          HealthHabitRecord(title: 'Sleep by 10:30 PM', category: 'sleep', icon: '\u{1F634}', isSystemGenerated: true, targetDays: 7),
          HealthHabitRecord(title: 'Take prescribed supplements', category: 'medication', icon: '\u{1F48A}', isSystemGenerated: true, targetDays: 7),
          HealthHabitRecord(title: 'Write in mood journal', category: 'mindfulness', icon: '\u{1F4D4}', isSystemGenerated: true, targetDays: 7),
        ];
      }
      return const [
        HealthHabitRecord(title: 'Balanced meal with protein', category: 'nutrition', icon: '\u{1F957}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: '30 min walk', category: 'exercise', icon: '\u{1F6B6}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: '8 glasses of water', category: 'nutrition', icon: '\u{1F4A7}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: 'Sleep 7-9 hours', category: 'sleep', icon: '\u{1F634}', isSystemGenerated: true, targetDays: 7),
      ];
    case 'pms':
    case 'pmdd':
      return const [
        HealthHabitRecord(title: 'Take magnesium supplement', category: 'medication', icon: '\u{1F33F}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: '10 min breathwork or meditation', category: 'mindfulness', icon: '\u{1F9D8}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: 'Limit caffeine today', category: 'nutrition', icon: '\u{2615}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: '20 min gentle walk', category: 'exercise', icon: '\u{1F6B6}', isSystemGenerated: true, targetDays: 5),
        HealthHabitRecord(title: 'Drink 8 glasses of water', category: 'nutrition', icon: '\u{1F4A7}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: 'Track mood in journal', category: 'mindfulness', icon: '\u{1F4D4}', isSystemGenerated: true, targetDays: 7),
      ];
    case 'irregular':
    default:
      return const [
        HealthHabitRecord(title: 'Balanced meal with protein', category: 'nutrition', icon: '\u{1F957}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: '30 min walk', category: 'exercise', icon: '\u{1F6B6}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: '8 glasses of water', category: 'nutrition', icon: '\u{1F4A7}', isSystemGenerated: true, targetDays: 7),
        HealthHabitRecord(title: 'Sleep 7-9 hours', category: 'sleep', icon: '\u{1F634}', isSystemGenerated: true, targetDays: 7),
      ];
  }
}
