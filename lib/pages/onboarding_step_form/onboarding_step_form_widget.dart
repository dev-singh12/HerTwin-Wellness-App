import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/assessment_questions.dart';
import '/business/scoring_engine.dart';
import '/components/button/button_widget.dart';
import '/components/condition_chip/condition_chip_widget.dart';
import '/components/step_indicator/step_indicator_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'onboarding_step_form_model.dart';
export 'onboarding_step_form_model.dart';

class OnboardingStepFormWidget extends StatefulWidget {
  const OnboardingStepFormWidget({super.key});

  static String routeName = 'OnboardingStepForm';
  static String routePath = '/onboardingStepForm';

  @override
  State<OnboardingStepFormWidget> createState() =>
      _OnboardingStepFormWidgetState();
}

class _OnboardingStepFormWidgetState extends State<OnboardingStepFormWidget> {
  late OnboardingStepFormModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Set<String> _selectedConditions = <String>{};
  final Map<String, int> _answers = {};
  bool _saving = false;
  bool _uploadingPrescription = false;
  String? _prescriptionUrl;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingStepFormModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        // Deselect
        _selectedConditions.remove(condition);
      } else {
        // Max 2 conditions allowed
        if (_selectedConditions.length >= 2) {
          _selectedConditions.clear();
        }
        // Enforce exclusion rules
        if (condition == 'Don\'t Know') {
          // "Don't Know" can only pair with "Irregular Periods"
          _selectedConditions.removeWhere((c) => c != 'Irregular Periods');
        } else if (condition == 'Irregular Periods') {
          // Irregular can pair with anything — no removals needed
        } else {
          // Selecting a specific condition removes "Don't Know"
          _selectedConditions.remove('Don\'t Know');
          // PCOS ↔ PCOD mutually exclusive
          if (condition == 'PCOS') _selectedConditions.remove('PCOD');
          if (condition == 'PCOD') _selectedConditions.remove('PCOS');
          // PMS ↔ PMDD mutually exclusive
          if (condition == 'PMS') _selectedConditions.remove('PMDD');
          if (condition == 'PMDD') _selectedConditions.remove('PMS');
        }
        _selectedConditions.add(condition);
      }
      // Clear answers when conditions change (new question set)
      _answers.clear();
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
  }

  List<AssessmentQuestion> _questionsForCondition() {
    if (_selectedConditions.isEmpty) return [];

    // Collect all selected condition keys
    final condKeys = _selectedConditions.map((c) =>
        c.toLowerCase().replaceAll(' ', '_').replaceAll("'", '')).toList();

    // Single condition → take first 7 from its question set
    if (condKeys.length == 1) {
      final key = condKeys.first;
      switch (key) {
        case 'pcos':
        case 'pcod':
          return pcosQuestions.take(7).toList();
        case 'pms':
        case 'pmdd':
          return pmsQuestions.take(7).toList();
        case 'irregular_periods':
        case 'irregular':
          return irregularQuestions.take(7).toList();
        case 'dont_know':
          return unknownQuestions.take(7).toList();
        default:
          return unknownQuestions.take(7).toList();
      }
    }

    // Multiple conditions → mix questions proportionally, max 7 total
    final allSets = <List<AssessmentQuestion>>[];
    for (final key in condKeys) {
      switch (key) {
        case 'pcos':
        case 'pcod':
          allSets.add(pcosQuestions);
          break;
        case 'pms':
        case 'pmdd':
          allSets.add(pmsQuestions);
          break;
        case 'irregular_periods':
        case 'irregular':
          allSets.add(irregularQuestions);
          break;
        default:
          allSets.add(unknownQuestions);
      }
    }

    // Distribute 7 questions across condition sets
    final mixed = <AssessmentQuestion>[];
    final perSet = (7 / allSets.length).floor().clamp(1, 7);
    final usedIds = <String>{};
    for (final qs in allSets) {
      var taken = 0;
      for (final q in qs) {
        if (taken >= perSet || mixed.length >= 7) break;
        if (!usedIds.contains(q.id)) {
          mixed.add(q);
          usedIds.add(q.id);
          taken++;
        }
      }
    }
    // Fill remaining slots from the first set
    if (mixed.length < 7 && allSets.isNotEmpty) {
      for (final q in allSets.first) {
        if (mixed.length >= 7) break;
        if (!usedIds.contains(q.id)) {
          mixed.add(q);
          usedIds.add(q.id);
        }
      }
    }
    return mixed;
  }

  bool get _questionsAnswered {
    final questions = _questionsForCondition();
    if (questions.isEmpty) return false;
    return questions.every((q) => _answers.containsKey(q.id));
  }

  Widget _buildQuestionsSection(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final questions = _questionsForCondition();
    if (questions.isEmpty) return const SizedBox.shrink();

    final answered = questions.where((q) => _answers.containsKey(q.id)).length;
    final total = questions.length;
    final done = answered == total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Assessment',
                      style: theme.titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600),
                        letterSpacing: 0.0,
                      )),
                  const SizedBox(height: 2),
                  Text('Answer these to get a personalized wellness score.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: theme.secondaryText)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Live answered-count pill so the user always knows how many
            // questions remain before the Continue button unlocks.
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: done
                    ? theme.success.withAlpha(40)
                    : theme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$answered / $total',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: done ? theme.success : theme.primary,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : answered / total,
            minHeight: 6,
            backgroundColor: theme.alternate,
            valueColor: AlwaysStoppedAnimation(
                done ? theme.success : theme.primary),
          ),
        ),
        const SizedBox(height: 16),
        ...questions
            .asMap()
            .entries
            .map((e) => _buildQuestionCard(theme, e.value, e.key + 1)),
      ],
    );
  }

  Widget _buildQuestionCard(
      FlutterFlowTheme theme, AssessmentQuestion q, int number) {
    final answered = _answers.containsKey(q.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answered ? theme.primary.withAlpha(90) : theme.alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numbered badge, flips to a check once the question is answered.
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: answered ? theme.primary : theme.alternate,
                  shape: BoxShape.circle,
                ),
                child: answered
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : Text('$number',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryText,
                        )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(q.text,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: theme.primaryText)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...q.options.map((opt) {
            final selected = _answers[q.id] == opt.score;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _answers[q.id] = opt.score),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.primary.withAlpha(15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? theme.primary : theme.alternate,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: selected ? theme.primary : theme.secondaryText,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(opt.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: selected
                                  ? theme.primaryText
                                  : theme.secondaryText,
                              fontWeight: selected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPrescription() async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null || _uploadingPrescription) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _uploadingPrescription = true);
      final bytes = await picked.readAsBytes();
      final url = await uploadPrescription(uid, bytes);
      if (!mounted) return;
      setState(() => _prescriptionUrl = url);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Medical report uploaded.'),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
    } catch (e) {
      _showError('Could not upload report. Please try again.');
    } finally {
      if (mounted) setState(() => _uploadingPrescription = false);
    }
  }

  Future<void> _completeOnboarding() async {
    if (_saving) return;

    final uid = AuthManager.instance.currentUid;
    if (uid == null) {
      context.goNamed(AuthScreenWidget.routeName);
      return;
    }

    int? age;
    final ageText =
        _model.textFieldModel.inputTextController?.text.trim() ?? '';
    if (ageText.isNotEmpty) {
      age = int.tryParse(ageText);
      if (age == null || age <= 0 || age > 120) {
        _showError('Please enter a valid age.');
        return;
      }
    }

    setState(() => _saving = true);
    try {
      // Determine primary condition from selections
      final condition = _selectedConditions.isNotEmpty
          ? _selectedConditions.first.toLowerCase().replaceAll(' ', '_')
          : 'unknown';

      // Compute a basic score from conditions/symptoms count
      final result = ScoringEngine.compute(
        conditionType: condition == 'irregular_periods' ? 'irregular' : condition,
        answers: _answers,
        age: age ?? 25,
      );

      // Save assessment record
      final assessmentId = newAssessmentId(uid);
      await saveAssessment(
        uid,
        OnboardingAssessmentRecord(
          id: assessmentId,
          uid: uid,
          conditionType: condition == 'irregular_periods' ? 'irregular' : condition,
          answers: _answers,
          totalScore: result.totalScore,
          severityLevel: result.severityLevel,
          diagnosisLabel: result.diagnosisLabel,
          carePlanType: result.carePlanType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Save habits for condition
      await saveHabitsForCondition(
        uid,
        condition == 'irregular_periods' ? 'irregular' : condition,
        result.severityLevel,
      );

      await userRef(uid).set(
        {
          if (age != null) 'age': age,
          'conditions': _selectedConditions.toList(),
          if (_prescriptionUrl != null)
            'prescriptionUrl': _prescriptionUrl,
          'conditionType': condition == 'irregular_periods' ? 'irregular' : condition,
          'latestAssessmentScore': result.totalScore,
          'latestSeverityLabel': result.severityLevel,
          'carePlanType': result.carePlanType,
          'healthVitalityScore': result.healthScore,
          'onboardingComplete': true,
          'lastActiveAt': Timestamp.fromDate(DateTime.now()),
        },
        SetOptions(merge: true),
      );
      if (!mounted) return;
      context.goNamed(OnboardingResultWidget.routeName);
    } catch (e) {
      _showError('Could not save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
            heroTag: 'prescription_fab',
            onPressed: _uploadingPrescription ? null : _pickAndUploadPrescription,
            backgroundColor: _prescriptionUrl != null
                ? FlutterFlowTheme.of(context).success
                : FlutterFlowTheme.of(context).secondary,
            icon: Icon(
              _prescriptionUrl != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              _uploadingPrescription
                  ? 'Uploading...'
                  : _prescriptionUrl != null
                      ? 'Uploaded'
                      : 'Upload Report',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 20.0,
                            ),
                            onPressed: _saving ? null : () => context.safePop(),
                          ),
                          wrapWithModel(
                            model: _model.stepIndicatorModel,
                            updateCallback: () => safeSetState(() {}),
                            child: StepIndicatorWidget(
                              step: 2.0,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tell us about yourself',
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                  lineHeight: 1.25,
                                ),
                          ),
                          Text(
                            'This helps HerTwin personalize your health journey and hormonal insights.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  lineHeight: 1.5,
                                ),
                          ),
                        ].divide(SizedBox(height: 4.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How old are you?',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
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
                              Container(
                                width: 100.0,
                                child: wrapWithModel(
                                  model: _model.textFieldModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TextFieldWidget(
                                    label: false,
                                    helper: false,
                                    hint: 'Age',
                                    value: '',
                                    leading_icon_present: false,
                                    trailing_icon_present: false,
                                    variant: 'outlined',
                                    error: false,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'years old',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Do you have any diagnosed conditions?',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: () => _toggleCondition('PCOS'),
                                child: wrapWithModel(
                                  model: _model.conditionChipModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ConditionChipWidget(
                                    icon: Icon(
                                      Icons.spa_rounded,
                                      color: _selectedConditions.contains('PCOS')
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'PCOS',
                                    selected:
                                        _selectedConditions.contains('PCOS'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleCondition('PCOD'),
                                child: wrapWithModel(
                                  model: _model.conditionChipModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ConditionChipWidget(
                                    icon: Icon(
                                      Icons.local_florist_rounded,
                                      color: _selectedConditions.contains('PCOD')
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'PCOD',
                                    selected:
                                        _selectedConditions.contains('PCOD'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleCondition('PMS'),
                                child: wrapWithModel(
                                  model: _model.conditionChipModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ConditionChipWidget(
                                    icon: Icon(
                                      Icons.water_drop_rounded,
                                      color: _selectedConditions.contains('PMS')
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'PMS',
                                    selected:
                                        _selectedConditions.contains('PMS'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _toggleCondition('Irregular Periods'),
                                child: wrapWithModel(
                                  model: _model.conditionChipModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ConditionChipWidget(
                                    icon: Icon(
                                      Icons.event_busy_rounded,
                                      color: _selectedConditions
                                              .contains('Irregular Periods')
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'Irregular Periods',
                                    selected: _selectedConditions
                                        .contains('Irregular Periods'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleCondition('PMDD'),
                                child: ConditionChipWidget(
                                  icon: Icon(
                                    Icons.mood_bad_rounded,
                                    color: _selectedConditions.contains('PMDD')
                                        ? FlutterFlowTheme.of(context).onPrimary
                                        : FlutterFlowTheme.of(context).secondaryText,
                                    size: 20.0,
                                  ),
                                  label: 'PMDD',
                                  selected: _selectedConditions.contains('PMDD'),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleCondition('Don\'t Know'),
                                child: ConditionChipWidget(
                                  icon: Icon(
                                    Icons.help_outline_rounded,
                                    color: _selectedConditions.contains('Don\'t Know')
                                        ? FlutterFlowTheme.of(context).onPrimary
                                        : FlutterFlowTheme.of(context).secondaryText,
                                    size: 20.0,
                                  ),
                                  label: 'Don\'t Know',
                                  selected: _selectedConditions.contains('Don\'t Know'),
                                ),
                              ),
                            ].divide(SizedBox(height: 8.0)),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      // Dynamic assessment questions (right after condition selection)
                      if (_selectedConditions.isNotEmpty)
                        _buildQuestionsSection(context),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap:
                                  (_saving || !_questionsAnswered) ? null : () => _completeOnboarding(),
                              child: wrapWithModel(
                                model: _model.buttonModel,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  content: 'Continue to Dashboard',
                                  icon_present: false,
                                  icon_end_present: false,
                                  color:
                                      FlutterFlowTheme.of(context).secondaryText,
                                  variant: 'primary',
                                  size: 'large',
                                  full_width: true,
                                  loading: _saving,
                                  disabled: _saving || !_questionsAnswered,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: FlutterFlowTheme.of(context).onSurface,
                                  size: 14.0,
                                ),
                                Text(
                                  'Your health data is private and encrypted',
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
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                        lineHeight: 1.2,
                                      ),
                                ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                    ].divide(SizedBox(height: 32.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
