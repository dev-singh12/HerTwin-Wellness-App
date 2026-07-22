import 'package:flutter/foundation.dart';

import '/backend/backend.dart';

/// Resolves whether the signed-in account is a clinician.
///
/// The role is not a claim the client invents: it is the existence of a
/// `doctors/{uid}` document, which `firestore.rules` forbids clients from
/// creating. So this class can only ever *observe* a privilege that the
/// backend already grants — it cannot manufacture one. Faking `isDoctor` in
/// the client would change which screens render, but every read behind them
/// would still be denied by the rules.
class RoleManager extends ChangeNotifier {
  RoleManager._();

  static final RoleManager instance = RoleManager._();

  bool _isDoctor = false;
  String? _resolvedForUid;
  DoctorRecord? _profile;

  bool get isDoctor => _isDoctor;

  /// The clinician's own profile, or null for patients.
  DoctorRecord? get profile => _profile;

  /// Whether the role for [uid] is known. The router holds navigation until
  /// this is true, so a clinician never sees a flash of the patient dashboard.
  bool isResolvedFor(String? uid) => uid != null && _resolvedForUid == uid;

  Future<void> refreshFor(String? uid) async {
    if (uid == null) {
      clear();
      return;
    }
    try {
      final profile = await getDoctorProfile(uid);
      _profile = profile;
      _isDoctor = profile != null;
    } catch (_) {
      // Fail closed: on any error treat the account as a patient. Granting
      // clinician screens on a failed lookup would be the wrong default.
      _profile = null;
      _isDoctor = false;
    }
    _resolvedForUid = uid;
    notifyListeners();
  }

  void clear() {
    _isDoctor = false;
    _profile = null;
    _resolvedForUid = null;
    notifyListeners();
  }
}
