import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
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
                                ? CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    width: 108.0,
                                    height: 108.0,
                                    fit: BoxFit.cover,
                                    errorWidget: (c, u, e) =>
                                        _initialsAvatar(theme),
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
                    onTap: () => _showMessage('Notification settings coming soon.'),
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
