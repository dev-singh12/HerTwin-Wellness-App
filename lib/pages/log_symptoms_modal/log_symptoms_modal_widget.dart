import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/components/button/button_widget.dart';
import '/components/mood_selector/mood_selector_widget.dart';
import '/components/symptom_chip/symptom_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'log_symptoms_modal_model.dart';
export 'log_symptoms_modal_model.dart';

/// Maps each on-screen mood option to the stored mood key and a 1-5 score.
const _moodMap = <String, (String, int)>{
  'Happy': ('great', 5),
  'Calm': ('good', 4),
  'Tired': ('okay', 3),
  'Low': ('low', 2),
  'Angry': ('terrible', 1),
};

class LogSymptomsModalWidget extends StatefulWidget {
  const LogSymptomsModalWidget({super.key});

  static String routeName = 'LogSymptomsModal';
  static String routePath = '/logSymptomsModal';

  @override
  State<LogSymptomsModalWidget> createState() => _LogSymptomsModalWidgetState();
}

class _LogSymptomsModalWidgetState extends State<LogSymptomsModalWidget> {
  late LogSymptomsModalModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedMood;
  final Set<String> _selectedSymptoms = {};
  String? _flow;
  bool _saving = false;
  CycleStatus _status = CycleEngine.compute(const []);
  StreamSubscription<List<CyclesRecord>>? _cyclesSub;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LogSymptomsModalModel());
    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      _cyclesSub = streamCycles(uid).listen((c) {
        if (mounted) safeSetState(() => _status = CycleEngine.compute(c));
      });
    }
  }

  @override
  void dispose() {
    _cyclesSub?.cancel();
    _model.dispose();

    super.dispose();
  }

  void _selectMood(String label) =>
      safeSetState(() => _selectedMood = _selectedMood == label ? null : label);

  void _toggleSymptom(String label) => safeSetState(() {
        if (!_selectedSymptoms.add(label)) _selectedSymptoms.remove(label);
      });

  void _selectFlow(String label) =>
      safeSetState(() => _flow = _flow == label ? null : label);

  Widget _flowTile(String label) {
    final selected = _flow == label;
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () => _selectFlow(label),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? FlutterFlowTheme.of(context).primary10
                : FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(18.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: selected
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: selected
                          ? FlutterFlowTheme.of(context).onSurface
                          : FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      lineHeight: 1.5,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final uid = AuthManager.instance.currentUid;
    if (uid == null) {
      context.safePop();
      return;
    }
    if (_selectedMood == null && _selectedSymptoms.isEmpty && _flow == null) {
      _showMessage('Select a mood, symptom, or flow before saving.');
      return;
    }
    safeSetState(() => _saving = true);
    final now = DateTime.now();
    final notes =
        _model.textFieldModel.inputTextController?.text.trim() ?? '';
    try {
      if (_selectedMood != null) {
        final entry = _moodMap[_selectedMood]!;
        final id = newMoodId(uid);
        await createMood(
          uid,
          MoodsRecord(
            id: id,
            date: now,
            mood: entry.$1,
            moodScore: entry.$2,
            notes: notes,
            createdAt: now,
          ),
        );
      }
      if (_selectedSymptoms.isNotEmpty) {
        final id = newSymptomId(uid);
        await createSymptom(
          uid,
          SymptomsRecord(
            id: id,
            date: now,
            symptoms: _selectedSymptoms.toList(),
            category: 'physical',
            notes: notes,
            createdAt: now,
          ),
        );
      }
      if (_flow != null) {
        await _logPeriodFlow(uid, now);
      }

      // Auto-update health vitality score + last log date
      final moodScore = _selectedMood != null ? _moodMap[_selectedMood]!.$2 : 3;
      final symptomPenalty = (_selectedSymptoms.length * 3).clamp(0, 30);
      final vitalityDelta = moodScore * 5 - symptomPenalty;
      final user = await getUser(uid);
      final oldScore = user?.healthVitalityScore ?? 50;
      final newScore = (oldScore + vitalityDelta).clamp(0, 100);
      await updateUser(uid, {
        'healthVitalityScore': newScore,
        'lastLogDate': now.toIso8601String(),
      });
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      await saveScoreLog(uid, todayStr, newScore);
      if (!mounted) return;
      _showMessage('Daily log saved.');
      context.safePop();
    } catch (e) {
      _showMessage('Could not save your log. Please try again.');
    } finally {
      if (mounted) safeSetState(() => _saving = false);
    }
  }

  /// Records a period start for [now] when flow is logged, unless a recent
  /// cycle already covers today (prevents duplicate starts skewing estimates).
  Future<void> _logPeriodFlow(String uid, DateTime now) async {
    final snap = await cyclesCollection(uid)
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final last = CyclesRecord.fromSnapshot(snap.docs.first);
      final start = last.startDate;
      if (start != null &&
          now.difference(start).inDays.abs() <
              CycleEngine.defaultPeriodLength) {
        await updateCycle(uid, last.id, {'flow': _flow!.toLowerCase()});
        return;
      }
    }
    final id = newCycleId(uid);
    await createCycle(
      uid,
      CyclesRecord(
        id: id,
        startDate: now,
        flow: _flow!.toLowerCase(),
        periodLength: CycleEngine.defaultPeriodLength,
        createdAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.close_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            onPressed:
                                _saving ? null : () => context.safePop(),
                          ),
                          Text(
                            'Log Symptoms',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                  lineHeight: 1.3,
                                ),
                          ),
                          InkWell(
                            onTap: _saving ? null : () => _save(),
                            child: wrapWithModel(
                              model: _model.buttonModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonWidget(
                                content: 'Save',
                                icon_present: false,
                                icon_end_present: false,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                variant: 'ghost',
                                size: 'small',
                                full_width: false,
                                loading: _saving,
                                disabled: _saving,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phase indicator
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).primary.withAlpha(20),
                              FlutterFlowTheme.of(context).secondary.withAlpha(20),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18, color: FlutterFlowTheme.of(context).primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_status.phase.label} \u{2022} Day ${_status.cycleDay} of ${_status.cycleLength}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                            ),
                            Text(
                              _status.phase.energyLevel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(28.0),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM d')
                                            .format(DateTime.now()),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        size: 20.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How are you feeling?',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => _selectMood('Happy'),
                                      child: wrapWithModel(
                                        model: _model.moodSelectorModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: MoodSelectorWidget(
                                          color: Color(0xFFFFF9C4),
                                          emoji: '😊',
                                          label: 'Happy',
                                          selected: _selectedMood == 'Happy',
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _selectMood('Calm'),
                                      child: wrapWithModel(
                                        model: _model.moodSelectorModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: MoodSelectorWidget(
                                          color: Color(0xFFE1F5FE),
                                          emoji: '😌',
                                          label: 'Calm',
                                          selected: _selectedMood == 'Calm',
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _selectMood('Low'),
                                      child: wrapWithModel(
                                        model: _model.moodSelectorModel3,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: MoodSelectorWidget(
                                          color: Color(0xFFE8EAF6),
                                          emoji: '😔',
                                          label: 'Low',
                                          selected: _selectedMood == 'Low',
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _selectMood('Tired'),
                                      child: wrapWithModel(
                                        model: _model.moodSelectorModel4,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: MoodSelectorWidget(
                                          color: Color(0xFFF3E5F5),
                                          emoji: '😫',
                                          label: 'Tired',
                                          selected: _selectedMood == 'Tired',
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _selectMood('Angry'),
                                      child: wrapWithModel(
                                        model: _model.moodSelectorModel5,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: MoodSelectorWidget(
                                          color: Color(0xFFFFEBEE),
                                          emoji: '😡',
                                          label: 'Angry',
                                          selected: _selectedMood == 'Angry',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Physical Symptoms',
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
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  direction: Axis.horizontal,
                                  runAlignment: WrapAlignment.start,
                                  verticalDirection: VerticalDirection.down,
                                  clipBehavior: Clip.none,
                                  children: [
                                    InkWell(
                                      onTap: () => _toggleSymptom('Cramps'),
                                      child: wrapWithModel(
                                        model: _model.symptomChipModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SymptomChipWidget(
                                          icon: Icon(
                                            Icons.water_drop_rounded,
                                            color: _selectedSymptoms
                                                    .contains('Cramps')
                                                ? FlutterFlowTheme.of(context)
                                                    .onPrimary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            size: 18.0,
                                          ),
                                          label: 'Cramps',
                                          selected: _selectedSymptoms
                                              .contains('Cramps'),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleSymptom('Bloating'),
                                      child: wrapWithModel(
                                        model: _model.symptomChipModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SymptomChipWidget(
                                          icon: Icon(
                                            Icons.thermostat_rounded,
                                            color: _selectedSymptoms
                                                    .contains('Bloating')
                                                ? FlutterFlowTheme.of(context)
                                                    .onPrimary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            size: 18.0,
                                          ),
                                          label: 'Bloating',
                                          selected: _selectedSymptoms
                                              .contains('Bloating'),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _toggleSymptom('Acne Breakout'),
                                      child: wrapWithModel(
                                        model: _model.symptomChipModel3,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SymptomChipWidget(
                                          icon: Icon(
                                            Icons.face_6_rounded,
                                            color: _selectedSymptoms
                                                    .contains('Acne Breakout')
                                                ? FlutterFlowTheme.of(context)
                                                    .onPrimary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            size: 18.0,
                                          ),
                                          label: 'Acne Breakout',
                                          selected: _selectedSymptoms
                                              .contains('Acne Breakout'),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleSymptom('Headache'),
                                      child: wrapWithModel(
                                        model: _model.symptomChipModel4,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SymptomChipWidget(
                                          icon: Icon(
                                            Icons.air_rounded,
                                            color: _selectedSymptoms
                                                    .contains('Headache')
                                                ? FlutterFlowTheme.of(context)
                                                    .onPrimary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            size: 18.0,
                                          ),
                                          label: 'Headache',
                                          selected: _selectedSymptoms
                                              .contains('Headache'),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _toggleSymptom('Breast Tenderness'),
                                      child: wrapWithModel(
                                        model: _model.symptomChipModel5,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SymptomChipWidget(
                                          icon: Icon(
                                            Icons.speed_rounded,
                                            color: _selectedSymptoms.contains(
                                                    'Breast Tenderness')
                                                ? FlutterFlowTheme.of(context)
                                                    .onPrimary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            size: 18.0,
                                          ),
                                          label: 'Breast Tenderness',
                                          selected: _selectedSymptoms
                                              .contains('Breast Tenderness'),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleSymptom('Back Pain'),
                                      child: wrapWithModel(
                                        model: _model.symptomChipModel6,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SymptomChipWidget(
                                          icon: Icon(
                                            Icons.bolt_rounded,
                                            color: _selectedSymptoms
                                                    .contains('Back Pain')
                                                ? FlutterFlowTheme.of(context)
                                                    .onPrimary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            size: 18.0,
                                          ),
                                          label: 'Back Pain',
                                          selected: _selectedSymptoms
                                              .contains('Back Pain'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Flow Intensity',
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _flowTile('Light'),
                                    _flowTile('Medium'),
                                    _flowTile('Heavy'),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notes',
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
                                wrapWithModel(
                                  model: _model.textFieldModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TextFieldWidget(
                                    label: false,
                                    helper: false,
                                    hint: 'Describe how you\'re feeling today',
                                    value: '',
                                    leading_icon_present: false,
                                    trailing_icon_present: false,
                                    variant: 'outlined',
                                    error: false,
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                            InkWell(
                              onTap: () async {
                                final uid = AuthManager.instance.currentUid;
                                if (uid == null) return;
                                try {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
                                  if (picked == null) return;
                                  _showMessage('Uploading report...');
                                  final bytes = await picked.readAsBytes();
                                  await uploadPrescription(uid, bytes);
                                  if (!mounted) return;
                                  _showMessage('Report uploaded successfully.');
                                } catch (_) {
                                  _showMessage('Upload failed. Try again.');
                                }
                              },
                              child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(28.0),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        size: 32.0,
                                      ),
                                      Text(
                                        'Upload Prescription or Report',
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                      Text(
                                        'PDF, JPG or PNG (Max 5MB)',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onSurface,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.2,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                ),
                              ),
                            ),
                            ),
                            Container(
                              height: 40.0,
                            ),
                          ].divide(SizedBox(height: 24.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      child: InkWell(
                        onTap: _saving ? null : () => _save(),
                        child: wrapWithModel(
                          model: _model.buttonModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: ButtonWidget(
                            content: 'Save Daily Log',
                            icon_present: false,
                            icon_end_present: false,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            variant: 'primary',
                            size: 'large',
                            full_width: true,
                            loading: _saving,
                            disabled: _saving,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
