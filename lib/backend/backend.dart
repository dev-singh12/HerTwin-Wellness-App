import 'package:cloud_firestore/cloud_firestore.dart';

import 'schema/users_record.dart';
import 'schema/cycles_record.dart';
import 'schema/moods_record.dart';
import 'schema/symptoms_record.dart';
import 'schema/sleep_record.dart';
import 'schema/water_record.dart';
import 'schema/exercises_record.dart';
import 'schema/journals_record.dart';
import 'schema/goals_record.dart';

export 'schema/users_record.dart';
export 'schema/cycles_record.dart';
export 'schema/moods_record.dart';
export 'schema/symptoms_record.dart';
export 'schema/sleep_record.dart';
export 'schema/water_record.dart';
export 'schema/exercises_record.dart';
export 'schema/journals_record.dart';
export 'schema/goals_record.dart';

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
