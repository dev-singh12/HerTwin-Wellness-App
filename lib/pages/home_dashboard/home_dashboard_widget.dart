import '/components/app_image.dart';
import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/components/button/button_widget.dart';
import '/components/calendar_pill/calendar_pill_widget.dart';
import '/components/ritual_tile/ritual_tile_widget.dart';
import '/components/status_card/status_card_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/app_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_dashboard_model.dart';
export 'home_dashboard_model.dart';

/// One entry in the dashboard week strip.
class _WeekDay {
  const _WeekDay(this.name, this.num, this.isPeriod, this.active);
  final String name;
  final String num;
  final bool isPeriod;
  final bool active;
}

const _moodLabels = <String, String>{
  'great': 'Joyful',
  'good': 'Content',
  'okay': 'Peaceful',
  'low': 'Tender',
  'terrible': 'Drained',
};

class HomeDashboardWidget extends StatefulWidget {
  const HomeDashboardWidget({super.key});

  static String routeName = 'HomeDashboard';
  static String routePath = '/homeDashboard';

  @override
  State<HomeDashboardWidget> createState() => _HomeDashboardWidgetState();
}

class _HomeDashboardWidgetState extends State<HomeDashboardWidget> {
  late HomeDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<UsersRecord>? _userSub;
  StreamSubscription<List<CyclesRecord>>? _cyclesSub;
  StreamSubscription<List<MoodsRecord>>? _moodsSub;
  StreamSubscription<List<MedicineReminderRecord>>? _remindersSub;
  StreamSubscription<List<ReminderLogRecord>>? _reminderLogsSub;
  StreamSubscription<List<AppointmentRecord>>? _apptsSub;

  UsersRecord? _user;
  CycleStatus _status = CycleEngine.compute(const []);
  MoodsRecord? _todayMood;
  List<MedicineReminderRecord> _reminders = [];
  List<ReminderLogRecord> _reminderLogs = [];
  List<AppointmentRecord> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeDashboardModel());

    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      // Check onboarding FIRST — only set up streams if user is ready
      getUser(uid).then((user) {
        if (!mounted) return;
        if (user == null || !user.onboardingComplete) {
          context.goNamed(OnboardingStepFormWidget.routeName);
          return;
        }
        // User is onboarded — now safe to set up streams.
        // Doctor seeding used to run from here. It is now server-side only
        // (`node tool/admin.js seed-doctors`): a client that can write the
        // doctors collection is a client that can grant itself the privilege
        // to read other people's medical records.
        safeSetState(() => _loading = false);
        _startStreams(uid);
      }).catchError((_) {
        // If user doc doesn't exist yet (brand new account), redirect to onboarding
        if (mounted) context.goNamed(OnboardingStepFormWidget.routeName);
      });
    }
  }

  void _startStreams(String uid) {
    _userSub = streamUser(uid).listen((u) {
      if (mounted) safeSetState(() => _user = u);
    });
    _cyclesSub = streamCycles(uid).listen((cycles) {
      if (mounted) {
        safeSetState(() => _status = CycleEngine.compute(cycles));
      }
    });
    _moodsSub = streamMoods(uid).listen((moods) {
      final now = DateTime.now();
      MoodsRecord? todays;
      for (final m in moods) {
        if (AppDateUtils.isSameDay(m.date, now)) {
          todays = m;
          break;
        }
      }
      if (mounted) safeSetState(() => _todayMood = todays);
    });
    _remindersSub = streamReminders(uid).listen((list) {
      if (mounted) {
        safeSetState(() => _reminders = list.where((r) => r.isActive).toList());
      }
    });
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _reminderLogsSub = streamReminderLogs(uid, todayStr).listen((logs) {
      if (mounted) safeSetState(() => _reminderLogs = logs);
    });
    // Doctor-written care plan. Firestore is realtime, so the dashboard
    // updates on its own the moment a clinician ends a consultation and saves
    // the prescription — no polling, no delay.
    _apptsSub = streamPatientAppointments(uid).listen((list) {
      if (mounted) safeSetState(() => _appointments = list);
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _cyclesSub?.cancel();
    _moodsSub?.cancel();
    _remindersSub?.cancel();
    _reminderLogsSub?.cancel();
    _apptsSub?.cancel();
    _model.dispose();

    super.dispose();
  }

  /// The patient-facing view of what a doctor prescribed. Renders nothing
  /// until a consultation is completed with notes or a prescription, then
  /// appears at the top of the dashboard. This is the "reflected on the
  /// dashboard as prescribed by the doctor" half of the consultation loop.
  Widget _buildCarePlanCard() {
    final theme = FlutterFlowTheme.of(context);
    // _appointments is newest-first (streamPatientAppointments orders by
    // createdAt DESC), so the first match is the most recent care plan.
    AppointmentRecord? plan;
    for (final a in _appointments) {
      final hasGuidance = (a.prescriptionText ?? '').trim().isNotEmpty ||
          (a.doctorNotes ?? '').trim().isNotEmpty;
      if (a.status == 'completed' && hasGuidance) {
        plan = a;
        break;
      }
    }
    if (plan == null) return const SizedBox.shrink();

    final rx = (plan.prescriptionText ?? '').trim();
    final notes = (plan.doctorNotes ?? '').trim();
    final when = plan.completedAt ?? plan.scheduledAt;
    final subtitle = [
      if (plan.doctorName.isNotEmpty) plan.doctorName,
      if (when != null) DateFormat('d MMM').format(when),
    ].join('  •  ');

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: theme.primary.withAlpha(70), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: theme.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.medical_information_rounded,
                        color: theme.primary, size: 22.0),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your care plan',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryText)),
                        if (subtitle.isNotEmpty)
                          Text(subtitle,
                              style: GoogleFonts.inter(
                                  fontSize: 12.0, color: theme.secondaryText)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.success.withAlpha(45),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text('Prescribed',
                        style: GoogleFonts.inter(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: theme.success)),
                  ),
                ],
              ),
              if (rx.isNotEmpty) ...[
                const SizedBox(height: 16.0),
                _carePlanBlock(
                    theme, Icons.medication_rounded, 'Prescription', rx),
              ],
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                _carePlanBlock(theme, Icons.sticky_note_2_rounded,
                    'Doctor\'s notes', notes),
              ],
              const SizedBox(height: 16.0),
              InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () =>
                    context.pushNamed(ConsultationChatWidget.routeName),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Open consultation',
                          style: GoogleFonts.inter(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: theme.primary)),
                      const SizedBox(width: 4.0),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16.0, color: theme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carePlanBlock(
      FlutterFlowTheme theme, IconData icon, String label, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.0, color: theme.secondaryText),
              const SizedBox(width: 6.0),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryText)),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(body,
              style: GoogleFonts.inter(
                  fontSize: 14.0, height: 1.5, color: theme.primaryText)),
        ],
      ),
    );
  }

  String get _firstName {
    final name = (_user?.displayName ?? '').trim();
    if (name.isNotEmpty) return name.split(' ').first;
    return 'there';
  }

  String get _moodValue {
    final mood = _todayMood?.mood ?? '';
    return _moodLabels[mood] ?? (mood.isEmpty ? 'Not logged' : mood);
  }

  /// Mon-Sun of the current week with period/active flags from the cycle model.
  List<_WeekDay> _weekDays() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = AppDateUtils.startOfDay(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return _WeekDay(
        names[i],
        '${date.day}',
        _status.isPeriodDay(date),
        AppDateUtils.isSameDay(date, today),
      );
    });
  }

  void _openLogSymptoms() =>
      context.pushNamed(LogSymptomsModalWidget.routeName);

  void _openTrack() => context.pushNamed(TrackTabWidget.routeName);

  bool _isTimeChecked(String reminderId, String time) {
    final log = _reminderLogs.where((l) => l.reminderId == reminderId).firstOrNull;
    return log?.timesChecked[time] ?? false;
  }

  void _toggleReminderTime(String reminderId, String time) {
    final uid = AuthManager.instance.currentUid;
    if (uid == null) return;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final checked = !_isTimeChecked(reminderId, time);
    updateReminderLog(uid, reminderId, todayStr, time, checked);
  }

  IconData _reminderIcon(String type) {
    switch (type) {
      case 'vitamin': return Icons.eco;
      case 'syrup': return Icons.local_drink;
      case 'injection': return Icons.vaccines;
      default: return Icons.medication;
    }
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final pieChartPieChartColorsList = [
      FlutterFlowTheme.of(context).onPrimary,
      FlutterFlowTheme.of(context).onPrimary20
    ];
    final week = _weekDays();
    final score = _user?.healthVitalityScore ?? 0;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: _loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
                    const SizedBox(height: 16),
                    Text('Loading your dashboard...', style: GoogleFonts.inter(color: FlutterFlowTheme.of(context).secondaryText)),
                  ],
                ),
              )
            : Stack(
          alignment: AlignmentDirectional(-1.0, -1.0),
          children: [
            SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 120.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 24.0, 24.0, 0.0),
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome, $_firstName',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineMedium
                                                        .fontStyle,
                                                lineHeight: 1.25,
                                              ),
                                        ),
                                        Text(
                                          '${_status.phase.label} • Day ${_status.cycleDay}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(24.0),
                                      onTap: () => context
                                          .pushNamed(ProfileWidget.routeName),
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          // Uploaded photo when there is one,
                                          // otherwise the bundled portrait.
                                          child: AppImage(
                                            (_user?.photoUrl ?? '')
                                                    .trim()
                                                    .isNotEmpty
                                                ? _user!.photoUrl
                                                : AppImages.womanPortraitSoft,
                                            width: 48.0,
                                            height: 48.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 24.0),
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 24.0, 16.0, 24.0),
                                        child: InkWell(
                                          onTap: _openTrack,
                                          child: Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[0].name,
                                                  day_num: week[0].num,
                                                  is_period: week[0].isPeriod,
                                                  active: week[0].active,
                                                ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[1].name,
                                                  day_num: week[1].num,
                                                  is_period: week[1].isPeriod,
                                                  active: week[1].active,
                                                ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[2].name,
                                                  day_num: week[2].num,
                                                  is_period: week[2].isPeriod,
                                                  active: week[2].active,
                                                ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel4,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[3].name,
                                                  day_num: week[3].num,
                                                  is_period: week[3].isPeriod,
                                                  active: week[3].active,
                                                ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel5,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[4].name,
                                                  day_num: week[4].num,
                                                  is_period: week[4].isPeriod,
                                                  active: week[4].active,
                                                ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel6,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[5].name,
                                                  day_num: week[5].num,
                                                  is_period: week[5].isPeriod,
                                                  active: week[5].active,
                                                ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.calendarPillModel7,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: CalendarPillWidget(
                                                  day_name: week[6].name,
                                                  day_num: week[6].num,
                                                  is_period: week[6].isPeriod,
                                                  active: week[6].active,
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 16.0)),
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
                          _buildCarePlanCard(),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 140.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).primary,
                                        FlutterFlowTheme.of(context).secondary
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(-1.0, 0.0),
                                      end: AlignmentDirectional(1.0, 0),
                                    ),
                                    borderRadius: BorderRadius.circular(28.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Container(
                                      child: Container(
                                        height: 92.0,
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Stack(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                children: [
                                                  Container(
                                                    height: 140.0,
                                                    child: FlutterFlowPieChart(
                                                      data: FFPieChartData(
                                                        values: ([
                                                          score.toDouble(),
                                                          (100 - score).toDouble()
                                                        ]),
                                                        colors:
                                                            pieChartPieChartColorsList,
                                                        radius: [45.0],
                                                      ),
                                                      donutHoleRadius: 35.0,
                                                      donutHoleColor:
                                                          Colors.transparent,
                                                      sectionLabelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                                lineHeight: 1.0,
                                                              ),
                                                      sectionsSpace: 2.0,
                                                      startDegreeOffset: -90.0,
                                                      labelPositionOffset: 0.6,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$score',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.25,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Health Vitality',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                  ),
                                                  Text(
                                                    _status.phase.vitalityMessage,
                                                    maxLines: 3,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface90,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 4.0)),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 24.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: wrapWithModel(
                                        model: _model.statusCardModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: StatusCardWidget(
                                          bg: Color(0xFFF3E5F5),
                                          border: Color(0xFFE1BEE7),
                                          icon: Icon(
                                            Icons.mood_rounded,
                                            color: Color(0xFFBA68C8),
                                            size: 18.0,
                                          ),
                                          icon_color: Color(0xFFBA68C8),
                                          label: 'Mood',
                                          value: _moodValue,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: wrapWithModel(
                                        model: _model.statusCardModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: StatusCardWidget(
                                          bg: Color(0xFFE1F5FE),
                                          border: Color(0xFFB3E5FC),
                                          icon: Icon(
                                            Icons.self_improvement_rounded,
                                            color: Color(0xFF03A9F4),
                                            size: 18.0,
                                          ),
                                          icon_color: Color(0xFF03A9F4),
                                          label: 'Energy',
                                          value: _status.phase.energyLevel,
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Today\'s Rituals',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    InkWell(
                                      onTap: () => context.pushNamed(
                                          ReminderManagementWidget.routeName),
                                      child: wrapWithModel(
                                      model: _model.buttonModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ButtonWidget(
                                        content: 'Edit',
                                        icon_present: false,
                                        icon_end_present: false,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        variant: 'ghost',
                                        size: 'small',
                                        full_width: false,
                                        loading: false,
                                        disabled: false,
                                      ),
                                    ),
                                    ),
                                  ],
                                ),
                                if (_reminders.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'No reminders yet \u2014 tap Edit to add one',
                                      style: GoogleFonts.inter(fontSize: 13, color: FlutterFlowTheme.of(context).secondaryText),
                                    ),
                                  )
                                else
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      for (final r in _reminders)
                                        for (final t in r.reminderTimes)
                                          InkWell(
                                            onTap: () => _toggleReminderTime(r.id, t),
                                            child: RitualTileWidget(
                                              bg: Color(r.iconColorValue).withAlpha(30),
                                              color: Color(r.iconColorValue),
                                              icon: Icon(
                                                _reminderIcon(r.iconType),
                                                color: Color(r.iconColorValue),
                                                size: 24.0,
                                              ),
                                              time: _formatTime(t),
                                              title: r.medicineName,
                                              done: _isTimeChecked(r.id, t),
                                            ),
                                          ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Nurture Yourself',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => context.pushNamed(
                                                YogaDetailWidget.routeName),
                                            child: Container(
                                            height: 160.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFF3E0),
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Container(
                                                child: Container(
                                                  height: 112.0,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.spa_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        size: 32.0,
                                                      ),
                                                      Text(
                                                        'Cycle Yoga',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFFE65100),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.3,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 16.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ),
                                          InkWell(
                                            onTap: () => context.pushNamed(
                                                ProfileWidget.routeName),
                                            child: Container(
                                            height: 100.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Container(
                                                child: Container(
                                                  height: 52.0,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .auto_awesome_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        size: 24.0,
                                                      ),
                                                      Text(
                                                        'Feedback',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFF2E7D32),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.3,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ),
                                        ].divide(SizedBox(height: 16.0)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => context.pushNamed(
                                                MoodJournalWidget.routeName),
                                            child: Container(
                                            height: 100.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE8EAF6),
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Container(
                                                child: Container(
                                                  height: 52.0,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .psychology_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        size: 24.0,
                                                      ),
                                                      Text(
                                                        'Journal',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFF3F51B5),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.3,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              final usedFree = _user?.hasUsedFreeConsultation ?? false;
                                              if (usedFree) {
                                                context.pushNamed(DoctorSelectionWidget.routeName,
                                                    extra: {'appointmentType': 'paid'});
                                              } else {
                                                context.pushNamed(DoctorSelectionWidget.routeName,
                                                    extra: {'appointmentType': 'free'});
                                              }
                                            },
                                            child: Container(
                                            height: 160.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFCE4EC),
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Container(
                                                child: Container(
                                                  height: 112.0,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .medical_services_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        size: 32.0,
                                                      ),
                                                      Text(
                                                        (_user?.hasUsedFreeConsultation ?? false)
                                                            ? 'Book Expert'
                                                            : 'Free Consult',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFFC2185B),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.3,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 16.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ),
                                        ].divide(SizedBox(height: 16.0)),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: InkWell(
                              onTap: () => context
                                  .pushNamed(CommunityFeedWidget.routeName),
                              child: Container(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(28.0),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Container(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 44.0,
                                          height: 44.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondary10,
                                            borderRadius:
                                                BorderRadius.circular(9999.0),
                                            shape: BoxShape.rectangle,
                                          ),
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Icon(
                                            Icons.groups_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onSurface,
                                            size: 24.0,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Circle of Support',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                              ),
                                              Text(
                                                'Join 1.2k others in the PCOS group',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .onSurface,
                                          size: 24.0,
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Container(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: FloatingActionButton.extended(
                  onPressed: _openLogSymptoms,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  icon: Icon(
                    Icons.add_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                  elevation: 0.0,
                  label: Text(
                    'Log Symptoms',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).onPrimary,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelLarge.fontStyle,
                          lineHeight: 1.3,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
