import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/components/app_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'Profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<UsersRecord>? _userSub;
  StreamSubscription<List<CyclesRecord>>? _cyclesSub;

  UsersRecord? _user;
  CycleStatus _status = CycleEngine.compute(const []);

  bool _editingName = false;
  bool _savingName = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      _userSub = streamUser(uid).listen((u) {
        if (!mounted) return;
        safeSetState(() {
          _user = u;
          if (!_editingName) {
            _model.nameTextController?.text = u.displayName;
          }
        });
      });
      _cyclesSub = streamCycles(uid).listen((cycles) {
        if (mounted) {
          safeSetState(() => _status = CycleEngine.compute(cycles));
        }
      });
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _cyclesSub?.cancel();
    _model.dispose();
    super.dispose();
  }

  String get _displayName {
    final name = (_user?.displayName ?? '').trim();
    return name.isEmpty ? 'Add your name' : name;
  }

  String get _initials {
    final name = (_user?.displayName ?? '').trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
      ));
  }

  Future<void> _pickAndUploadPhoto() async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null || _uploadingPhoto) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 80,
      );
      if (picked == null) return;
      safeSetState(() => _uploadingPhoto = true);
      final bytes = await picked.readAsBytes();
      final url = await uploadProfilePhoto(uid, bytes);
      await updateUser(uid, {'photoUrl': url});
      if (mounted) _showMessage('Profile photo updated.');
    } catch (e) {
      if (mounted) _showMessage('Could not update photo. Please try again.');
    } finally {
      if (mounted) safeSetState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _saveName() async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null || _savingName) return;
    final newName = (_model.nameTextController?.text ?? '').trim();
    if (newName.isEmpty) {
      _showMessage('Please enter a name.');
      return;
    }
    safeSetState(() => _savingName = true);
    try {
      await updateUser(uid, {'displayName': newName});
      await AuthManager.instance.currentUser?.updateDisplayName(newName);
      if (mounted) {
        safeSetState(() => _editingName = false);
        _showMessage('Name updated.');
      }
    } catch (e) {
      if (mounted) _showMessage('Could not save name. Please try again.');
    } finally {
      if (mounted) safeSetState(() => _savingName = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out',
            style: FlutterFlowTheme.of(context).titleMedium),
        content: Text('Are you sure you want to sign out?',
            style: FlutterFlowTheme.of(context).bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign out',
                style: TextStyle(color: FlutterFlowTheme.of(context).error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthManager.instance.signOut();
    if (mounted) context.goNamed(AuthScreenWidget.routeName);
  }

  /// Permanent account deletion.
  ///
  /// Google Play requires an in-app route to delete the account and its data
  /// for any app that lets users create one. Deliberately two-step and
  /// type-to-confirm: this erases every cycle log, symptom and journal entry
  /// the user has, and none of it is recoverable.
  Future<void> _deleteAccount() async {
    final theme = FlutterFlowTheme.of(context);
    final uid = AuthManager.instance.currentUid;
    if (uid == null) return;

    final confirmCtrl = TextEditingController();
    var canDelete = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete your account?',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: theme.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This permanently erases your cycle history, symptoms, mood '
                'journal, assessments, reminders and habits. It cannot be '
                'undone and we cannot recover it for you.',
                style: GoogleFonts.inter(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Your community posts stay up but are anonymised, so other '
                'people\u{2019}s conversations are not broken.',
                style: GoogleFonts.inter(
                    fontSize: 12, height: 1.5, color: theme.secondaryText),
              ),
              const SizedBox(height: 16),
              Text('Type DELETE to confirm',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: confirmCtrl,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (v) => setDialogState(
                    () => canDelete = v.trim().toUpperCase() == 'DELETE'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            TextButton(
              onPressed:
                  canDelete ? () => Navigator.of(ctx).pop(true) : null,
              child: Text('Delete for ever',
                  style: TextStyle(
                      color: canDelete ? theme.error : theme.secondaryText)),
            ),
          ],
        ),
      ),
    );

    confirmCtrl.dispose();
    if (confirmed != true || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: theme.primary),
      ),
    );

    try {
      // Firestore data first: once the auth user is gone the rules deny
      // every write, which would strand the health data permanently.
      await deleteAccountData(uid);
      await AuthManager.instance.currentUser?.delete();
      if (!mounted) return;
      Navigator.of(context).pop();
      context.goNamed(AuthScreenWidget.routeName);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (e.code == 'requires-recent-login') {
        // Firebase refuses account deletion on a stale session. The data is
        // already gone; the user signs in again to finish the job.
        await AuthManager.instance.signOut();
        if (!mounted) return;
        context.goNamed(AuthScreenWidget.routeName);
        _showMessage(
            'Your data has been deleted. Please sign in once more to remove '
            'the account itself.');
      } else {
        _showMessage('Could not delete the account. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showMessage('Could not delete the account. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final photoUrl = (_user?.photoUrl ?? '').trim();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () => context.safePop(),
                        child: Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              color: theme.primaryText, size: 22.0),
                        ),
                      ),
                      Text('Profile',
                          style: theme.headlineSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold),
                            letterSpacing: 0.0,
                          )),
                      const SizedBox(width: 44.0),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Avatar
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        Container(
                          width: 112.0,
                          height: 112.0,
                          decoration: BoxDecoration(
                            color: theme.primary10,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.primary, width: 2.0),
                          ),
                          alignment: AlignmentDirectional.center,
                          child: ClipOval(
                            child: photoUrl.isNotEmpty
                                ? AppImage(
                                    photoUrl,
                                    width: 108.0,
                                    height: 108.0,
                                    fit: BoxFit.cover,
                                    fallback: _initialsAvatar(theme),
                                  )
                                : _initialsAvatar(theme),
                          ),
                        ),
                        InkWell(
                          onTap: _pickAndUploadPhoto,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: theme.primaryBackground, width: 2.0),
                            ),
                            child: _uploadingPhoto
                                ? Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation(
                                          theme.onPrimary),
                                    ),
                                  )
                                : Icon(Icons.camera_alt_rounded,
                                    color: theme.onPrimary, size: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Name + email
                  if (_editingName)
                    _nameEditor(theme)
                  else
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: InkWell(
                        onTap: () => safeSetState(() => _editingName = true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_displayName,
                                style: theme.titleLarge.override(
                                  font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold),
                                  letterSpacing: 0.0,
                                )),
                            const SizedBox(width: 8.0),
                            Icon(Icons.edit_outlined,
                                color: theme.secondaryText, size: 18.0),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4.0),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Text((_user?.email ?? '').trim(),
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        )),
                  ),
                  const SizedBox(height: 28.0),

                  // Condition card
                  if (_user != null && _user!.conditionType.isNotEmpty)
                    _conditionCard(theme),
                  if (_user != null && _user!.conditionType.isNotEmpty)
                    const SizedBox(height: 16.0),

                  // Stat cards
                  Row(
                    children: [
                      _statCard(theme, 'Cycle Length',
                          '${_status.cycleLength} days', Icons.autorenew_rounded),
                      const SizedBox(width: 12.0),
                      _statCard(
                          theme,
                          'Age',
                          _user?.age != null ? '${_user!.age}' : '—',
                          Icons.cake_outlined),
                      const SizedBox(width: 12.0),
                      _statCard(
                          theme,
                          'Blood Type',
                          (_user?.bloodType ?? '').trim().isEmpty
                              ? '—'
                              : _user!.bloodType,
                          Icons.water_drop_outlined),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Insights entry
                  _actionTile(
                    theme,
                    icon: Icons.insights_rounded,
                    iconBg: theme.secondary10,
                    iconColor: theme.secondary,
                    title: 'My Insights',
                    subtitle: 'Cycle trends, mood & symptom analytics',
                    onTap: () => context.pushNamed(InsightsWidget.routeName),
                  ),
                  const SizedBox(height: 12.0),
                  _actionTile(
                    theme,
                    icon: Icons.favorite_border_rounded,
                    iconBg: theme.primary10,
                    iconColor: theme.primary,
                    title: 'Wellness',
                    subtitle: 'Rituals and recommendations for you',
                    onTap: () => context.pushNamed(WellnessTabWidget.routeName),
                  ),
                  const SizedBox(height: 12.0),
                  _actionTile(
                    theme,
                    icon: Icons.notifications_none_rounded,
                    iconBg: theme.alternate,
                    iconColor: theme.primaryText,
                    title: 'Notifications',
                    subtitle: 'Reminders and cycle alerts',
                    onTap: () => context.pushNamed(ReminderManagementWidget.routeName),
                  ),
                  const SizedBox(height: 12.0),
                  _actionTile(
                    theme,
                    icon: Icons.assignment_rounded,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF388E3C),
                    title: 'Retake Assessment',
                    subtitle: 'Update your condition & wellness score',
                    onTap: () => context.pushNamed(OnboardingStepFormWidget.routeName),
                  ),
                  const SizedBox(height: 12.0),
                  _actionTile(
                    theme,
                    icon: Icons.star_border_rounded,
                    iconBg: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFF9A825),
                    title: 'Rate HerTwin',
                    subtitle: 'Share your feedback with us',
                    onTap: () => _showRatingDialog(theme),
                  ),
                  const SizedBox(height: 32.0),

                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmSignOut,
                      icon: Icon(Icons.logout_rounded,
                          color: theme.error, size: 20.0),
                      label: Text('Sign Out',
                          style: theme.titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                            color: theme.error,
                            letterSpacing: 0.0,
                          )),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                        side: BorderSide(color: theme.error, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Account deletion. Play policy requires this to be
                  // reachable in-app, not only by emailing support.
                  Center(
                    child: TextButton(
                      onPressed: _deleteAccount,
                      child: Text(
                        'Delete my account and data',
                        style: GoogleFonts.inter(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: theme.secondaryText,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _initialsAvatar(FlutterFlowTheme theme) => Container(
        width: 108.0,
        height: 108.0,
        alignment: AlignmentDirectional.center,
        color: theme.primary10,
        child: Text(_initials,
            style: theme.displaySmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              color: theme.primary,
              letterSpacing: 0.0,
            )),
      );

  // ── Condition card ──────────────────────────────────────────────────────

  Widget _conditionCard(FlutterFlowTheme theme) {
    final condition = _user!.conditionType.toUpperCase();
    final score = _user!.latestAssessmentScore;
    final severity = _user!.latestSeverityLabel;
    final carePlan = _user!.carePlanType;
    final scoreColor = score >= 70
        ? theme.success
        : score >= 40
            ? theme.warning
            : theme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary.withAlpha(15), theme.secondary.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withAlpha(40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(condition,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w700, color: theme.primary)),
              ),
              const Spacer(),
              if (severity.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(severity,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600, color: scoreColor)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wellness Score',
                      style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText)),
                  const SizedBox(height: 2),
                  Text('$score / 100',
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold, color: scoreColor)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 5,
                  backgroundColor: theme.alternate,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
            ],
          ),
          if (carePlan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Care Plan: $carePlan',
                style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText)),
          ],
        ],
      ),
    );
  }

  // ── Rating dialog ──────────────────────────────────────────────────────

  void _showRatingDialog(FlutterFlowTheme theme) {
    int rating = 0;
    final commentCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Rate HerTwin',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How is your experience so far?',
                  style: GoogleFonts.inter(fontSize: 14, color: theme.secondaryText)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: starIndex <= rating ? const Color(0xFFF9A825) : theme.secondaryText,
                      size: 36,
                    ),
                    onPressed: () => setDialogState(() => rating = starIndex),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Any feedback? (optional)',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: theme.secondaryText),
                  filled: true,
                  fillColor: theme.primaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.alternate),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.alternate),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: theme.secondaryText)),
            ),
            ElevatedButton(
              onPressed: rating == 0 || submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      final uid = AuthManager.instance.currentUid;
                      if (uid != null) {
                        try {
                          await saveFeedback(uid, rating, commentCtrl.text.trim());
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) _showMessage('Thank you for your feedback!');
                        } catch (_) {
                          if (mounted) _showMessage('Could not save feedback. Please try again.');
                        }
                      }
                      if (ctx.mounted) setDialogState(() => submitting = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: submitting
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameEditor(FlutterFlowTheme theme) => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _model.nameTextController,
              focusNode: _model.nameFocusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Your name',
                filled: true,
                fillColor: theme.secondaryBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: theme.alternate, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: theme.primary, width: 1.5),
                ),
              ),
              style: theme.bodyLarge,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: _savingName ? null : _saveName,
            icon: _savingName
                ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor:
                            AlwaysStoppedAnimation(theme.primary)),
                  )
                : Icon(Icons.check_circle, color: theme.primary, size: 28.0),
          ),
          IconButton(
            onPressed: () {
              _model.nameTextController?.text = _user?.displayName ?? '';
              safeSetState(() => _editingName = false);
            },
            icon: Icon(Icons.cancel, color: theme.secondaryText, size: 28.0),
          ),
        ],
      );

  Widget _statCard(
          FlutterFlowTheme theme, String label, String value, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: theme.alternate, width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.primary, size: 22.0),
              const SizedBox(height: 8.0),
              Text(value,
                  textAlign: TextAlign.center,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                    letterSpacing: 0.0,
                  )),
              const SizedBox(height: 2.0),
              Text(label,
                  textAlign: TextAlign.center,
                  style: theme.labelSmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  )),
            ],
          ),
        ),
      );

  Widget _actionTile(
    FlutterFlowTheme theme, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: theme.alternate, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: iconColor, size: 22.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        )),
                    const SizedBox(height: 2.0),
                    Text(subtitle,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.secondaryText, size: 22.0),
            ],
          ),
        ),
      );
}
