import 'package:firebase_auth/firebase_auth.dart';

/// Maps a [FirebaseAuthException] (or any error) to a user-friendly message.
String mapFirebaseAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'wrong-password':
        return 'Incorrect password. Try again or reset it.';
      case 'invalid-credential':
        return 'Incorrect email or password. Try again or reset it.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Enable it in Firebase.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
