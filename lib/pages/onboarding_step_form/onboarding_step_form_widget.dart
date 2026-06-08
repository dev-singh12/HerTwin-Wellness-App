import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/components/button/button_widget.dart';
import '/components/condition_chip/condition_chip_widget.dart';
import '/components/step_indicator/step_indicator_widget.dart';
import '/components/symptom_item/symptom_item_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final Set<String> _selectedSymptoms = <String>{};
  bool _saving = false;

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
      if (!_selectedConditions.add(condition)) {
        _selectedConditions.remove(condition);
      }
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (!_selectedSymptoms.add(symptom)) {
        _selectedSymptoms.remove(symptom);
      }
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

  Future<void> _completeOnboarding({bool skip = false}) async {
    if (_saving) return;

    final uid = AuthManager.instance.currentUid;
    if (uid == null) {
      context.goNamed(AuthScreenWidget.routeName);
      return;
    }

    int? age;
    if (!skip) {
      final ageText =
          _model.textFieldModel.inputTextController?.text.trim() ?? '';
      if (ageText.isNotEmpty) {
        age = int.tryParse(ageText);
        if (age == null || age <= 0 || age > 120) {
          _showError('Please enter a valid age.');
          return;
        }
      }
    }

    setState(() => _saving = true);
    try {
      await userRef(uid).set(
        {
          if (age != null) 'age': age,
          if (!skip) 'conditions': _selectedConditions.toList(),
          if (!skip) 'symptoms': _selectedSymptoms.toList(),
          'onboardingComplete': true,
          'lastActiveAt': Timestamp.fromDate(DateTime.now()),
        },
        SetOptions(merge: true),
      );
      if (!mounted) return;
      context.goNamed(
        skip
            ? HomeDashboardWidget.routeName
            : OnboardingResultWidget.routeName,
      );
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
                          InkWell(
                            onTap: _saving
                                ? null
                                : () => _completeOnboarding(skip: true),
                            child: Text(
                              'Skip',
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                    lineHeight: 1.3,
                                  ),
                            ),
                          ),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                            ].divide(SizedBox(height: 8.0)),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Common symptoms you face?',
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
                                onTap: () => _toggleSymptom('Acne'),
                                child: wrapWithModel(
                                  model: _model.symptomItemModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SymptomItemWidget(
                                    label: 'Acne',
                                    active: _selectedSymptoms.contains('Acne'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleSymptom('Hair Loss'),
                                child: wrapWithModel(
                                  model: _model.symptomItemModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SymptomItemWidget(
                                    label: 'Hair Loss',
                                    active:
                                        _selectedSymptoms.contains('Hair Loss'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleSymptom('Weight Gain'),
                                child: wrapWithModel(
                                  model: _model.symptomItemModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SymptomItemWidget(
                                    label: 'Weight Gain',
                                    active: _selectedSymptoms
                                        .contains('Weight Gain'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleSymptom('Mood Swings'),
                                child: wrapWithModel(
                                  model: _model.symptomItemModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SymptomItemWidget(
                                    label: 'Mood Swings',
                                    active: _selectedSymptoms
                                        .contains('Mood Swings'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleSymptom('Cramps'),
                                child: wrapWithModel(
                                  model: _model.symptomItemModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SymptomItemWidget(
                                    label: 'Cramps',
                                    active: _selectedSymptoms.contains('Cramps'),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleSymptom('Fatigue'),
                                child: wrapWithModel(
                                  model: _model.symptomItemModel6,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SymptomItemWidget(
                                    label: 'Fatigue',
                                    active:
                                        _selectedSymptoms.contains('Fatigue'),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Upload Prescription (Optional)',
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
                          Container(
                            height: 160.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(28.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                            ),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 56.0,
                                  height: 56.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).primary10,
                                    borderRadius: BorderRadius.circular(9999.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Icon(
                                    Icons.cloud_upload_rounded,
                                    color:
                                        FlutterFlowTheme.of(context).onSurface,
                                    size: 28.0,
                                  ),
                                ),
                                Text(
                                  'Tap to upload medical reports',
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
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
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
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
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
                                  _saving ? null : () => _completeOnboarding(),
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
                                  disabled: _saving,
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
