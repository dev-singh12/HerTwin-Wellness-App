import 'package:flutter/material.dart';

import '/auth/auth_manager.dart';
import '/auth/role_manager.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Shared post-authentication routing for BOTH entry points (the Google button
/// and the email sheet), so "member vs approved doctor vs pending doctor" is
/// decided in one place instead of being duplicated per button.
///
/// [asDoctor] is only the role the user tapped on the auth screen — it grants
/// nothing. Clinician access is still solely the existence of a doctors/{uid}
/// doc (created server-side). All this flag changes is what an *unapproved*
/// doctor sees: a pending-approval message + sign-out, instead of the patient
/// app. A real clinician lands on the dashboard no matter which role they tap.
Future<void> completeAuthNavigation(
  BuildContext context, {
  required bool asDoctor,
  bool wasSignUp = false,
}) async {
  final uid = AuthManager.instance.currentUid;
  if (uid == null) return;

  final clinician = await getDoctorProfile(uid);
  await RoleManager.instance.refreshFor(uid);

  if (clinician != null) {
    if (context.mounted) context.goNamed(DoctorDashboardWidget.routeName);
    return;
  }

  if (asDoctor) {
    // Authenticated, but not an approved clinician. File/refresh an application
    // (idempotent set) so an admin sees them no matter the entry point, then
    // sign out so an unapproved account never sits inside the patient app.
    try {
      await submitDoctorApplication(
        uid,
        name: AuthManager.instance.currentUser?.displayName ?? '',
        email: AuthManager.instance.currentUser?.email ?? '',
      );
    } catch (_) {
      // Best-effort: the auth account still exists and can be promoted.
    }
    await AuthManager.instance.signOut();
    if (context.mounted) await _showPendingDoctorDialog(context, wasSignUp);
    return;
  }

  // Regular member: onboard if new, otherwise straight to the dashboard.
  final record = await getUser(uid);
  final onboarded = record?.onboardingComplete ?? false;
  if (context.mounted) {
    context.goNamed(onboarded
        ? HomeDashboardWidget.routeName
        : OnboardingStepFormWidget.routeName);
  }
}

Future<void> _showPendingDoctorDialog(BuildContext context, bool wasSignUp) {
  final theme = FlutterFlowTheme.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.secondaryBackground,
      icon: Icon(Icons.verified_user_outlined, color: theme.primary, size: 36),
      title: const Text('Doctor account pending approval'),
      content: Text(
        wasSignUp
            ? 'Thanks for signing up. A clinician account must be approved by an admin before it can open the doctor dashboard. You\'ll be able to sign in here once your account is approved.'
            : 'This account is not an approved clinician yet. Please wait for admin approval, or use "I\'m a User" to continue as a member.',
        style: FlutterFlowTheme.of(context).bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}
