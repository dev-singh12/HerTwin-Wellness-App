import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

FirebaseStorage get _storage => FirebaseStorage.instance;

/// Uploads raw image [bytes] to `users/{uid}/profile.jpg` and returns the
/// public download URL. Works on web and mobile (bytes-based, no dart:io).
Future<String> uploadProfilePhoto(
  String uid,
  Uint8List bytes, {
  String contentType = 'image/jpeg',
}) async {
  final ref = _storage.ref().child('users/$uid/profile.jpg');
  await ref.putData(bytes, SettableMetadata(contentType: contentType));
  return ref.getDownloadURL();
}

/// Uploads a prescription / medical report to
/// `users/{uid}/prescriptions/{timestamp}.{ext}` and returns the download URL.
/// Works on web and mobile (bytes-based, no dart:io).
Future<String> uploadPrescription(
  String uid,
  Uint8List bytes, {
  String contentType = 'image/jpeg',
  String extension = 'jpg',
}) async {
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final ref =
      _storage.ref().child('users/$uid/prescriptions/$stamp.$extension');
  await ref.putData(bytes, SettableMetadata(contentType: contentType));
  return ref.getDownloadURL();
}

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

Stream<List<PostsRecord>> streamPosts({int limit = 50}) => postsCollection
    .orderBy('createdAt', descending: true)
    .limit(limit)
    .snapshots()
    .map((s) => s.docs.map(PostsRecord.fromSnapshot).toList());

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
  return doc.availableSlots[date] ?? _generateDefaultSlots();
}

List<String> _generateDefaultSlots() {
  return [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
  ];
}

// ---------------------------------------------------------------------------
// users/{uid}/appointments
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> appointmentsCollection(String uid) =>
    userRef(uid).collection('appointments');

String newAppointmentId(String uid) => appointmentsCollection(uid).doc().id;

Stream<List<AppointmentRecord>> streamAppointments(String uid) =>
    appointmentsCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AppointmentRecord.fromSnapshot).toList());

Future<void> bookAppointment(String uid, AppointmentRecord record) =>
    appointmentsCollection(uid).doc(record.id).set(record.toMap());

Future<void> updateAppointmentStatus(
        String uid, String appointmentId, String status) =>
    appointmentsCollection(uid).doc(appointmentId).update({'status': status});

Stream<AppointmentRecord?> streamNextAppointment(String uid) =>
    appointmentsCollection(uid)
        .where('status', whereIn: ['booked', 'ongoing'])
        .orderBy('scheduledAt')
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : AppointmentRecord.fromSnapshot(s.docs.first));

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
