import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

import '/backend/backend.dart';
import 'error_mapper.dart';

/// Central authentication entry point. Use [AuthManager.instance].
class AuthManager {
  AuthManager._();
  static final AuthManager instance = AuthManager._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _usedGoogle = false;
  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStream => _auth.authStateChanges();

  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(displayName.trim());

      final now = DateTime.now();
      await _safeFirestore(() => createUser(
            UsersRecord(
              uid: user.uid,
              email: email.trim(),
              displayName: displayName.trim(),
              onboardingComplete: false,
              createdAt: now,
              lastActiveAt: now,
            ),
          ));

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthError(e);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _touchLastActive(_auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthError(e);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      late final UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        if (!_googleInitialized) {
          await GoogleSignIn.instance.initialize();
          _googleInitialized = true;
        }
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        final oauthCredential =
            GoogleAuthProvider.credential(idToken: idToken);
        credential = await _auth.signInWithCredential(oauthCredential);
      }

      _usedGoogle = true;
      final user = credential.user!;

      await _safeFirestore(() async {
        final existing = await getUser(user.uid);
        if (existing == null) {
          final now = DateTime.now();
          await createUser(UsersRecord(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? '',
            photoUrl: user.photoURL ?? '',
            onboardingComplete: false,
            createdAt: now,
            lastActiveAt: now,
          ));
        } else {
          await _touchLastActive(user.uid);
        }
      });
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw 'Sign in cancelled.';
      }
      throw 'Google sign-in failed. Please try again.';
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (_usedGoogle && !kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Ignore: Firebase sign-out already succeeded.
      }
    }
    _usedGoogle = false;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthError(e);
    }
  }

  Future<void> _touchLastActive(String uid) => _safeFirestore(
        () => userRef(uid).set(
          {'lastActiveAt': Timestamp.fromDate(DateTime.now())},
          SetOptions(merge: true),
        ),
      );

  /// Runs a Firestore op without letting its failure undo a successful auth.
  Future<void> _safeFirestore(Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      // Auth has already succeeded; a Firestore hiccup (e.g. DB not yet
      // provisioned, offline, or rules denying access) shouldn't surface as
      // an auth failure — but log it so it isn't silently invisible.
      // A `permission-denied` here usually means firestore.rules haven't been
      // deployed for this project.
      debugPrint('[AuthManager] Firestore write skipped after auth: $e');
    }
  }
}
