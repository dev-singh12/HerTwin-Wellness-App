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

  /// Web sign-in error codes that mean "the popup route is unavailable here",
  /// as opposed to "the user declined". Each of these should transparently
  /// fall back to a full-page redirect rather than surfacing an error.
  static const _popupUnavailableCodes = {
    'popup-blocked',
    'operation-not-supported-in-this-environment',
    'web-storage-unsupported',
    'internal-error',
  };

  /// The user shut the popup themselves. Not a failure — do NOT respond by
  /// yanking them through a full-page redirect they did not ask for.
  static const _userCancelledCodes = {
    'popup-closed-by-user',
    'cancelled-popup-request',
    'user-cancelled',
  };

  /// Creates the `users/{uid}` document on first sign-in, or refreshes the
  /// last-active stamp on subsequent ones. Shared by the popup and redirect
  /// paths so a redirect sign-in is not left without a profile document.
  Future<void> _provisionUserDocument(User user) async {
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
  }

  /// Completes a redirect-based sign-in, if one is pending.
  ///
  /// Call once at startup. When [signInWithGoogle] falls back to redirect the
  /// browser navigates away, so the user document has to be provisioned when
  /// the app reloads rather than inside the original call.
  Future<void> completePendingRedirect() async {
    if (!kIsWeb) return;
    try {
      final result = await _auth.getRedirectResult();
      final user = result.user;
      if (user != null) {
        _usedGoogle = true;
        await _provisionUserDocument(user);
      }
    } catch (e) {
      debugPrint('No pending redirect sign-in: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      late final UserCredential credential;
      if (kIsWeb) {
        // Popups are blocked in embedded webviews, in-app browsers, and by
        // some privacy settings. Firebase can hang silently in that case
        // rather than throwing, so fall back to a redirect instead of
        // leaving the user staring at a spinner.
        final startedAt = DateTime.now();
        try {
          credential = await _auth
              .signInWithPopup(GoogleAuthProvider())
              .timeout(const Duration(seconds: 90));
        } on TimeoutException {
          await _auth.signInWithRedirect(GoogleAuthProvider());
          return; // Page navigates away; resumes in completePendingRedirect.
        } on FirebaseAuthException catch (e) {
          debugPrint('Google popup sign-in failed: ${e.code} — ${e.message}');

          if (_userCancelledCodes.contains(e.code)) {
            // Firebase reports "popup closed by user" both when someone
            // genuinely dismisses the window AND when the popup closes
            // itself — which is what happens when third-party cookies are
            // blocked, since the flow cannot reach its own auth domain.
            //
            // The two are indistinguishable by error code, but not by time:
            // nobody finds, reads and dismisses a Google account chooser in
            // under three seconds. A near-instant close is the browser, not
            // the user, so fall back to redirect instead of blaming them.
            final elapsed = DateTime.now().difference(startedAt);
            if (elapsed < const Duration(seconds: 3)) {
              await _auth.signInWithRedirect(GoogleAuthProvider());
              return;
            }
            throw 'Sign in cancelled.';
          }

          if (!_popupUnavailableCodes.contains(e.code)) rethrow;
          await _auth.signInWithRedirect(GoogleAuthProvider());
          return;
        }
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
      await _provisionUserDocument(credential.user!);
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
