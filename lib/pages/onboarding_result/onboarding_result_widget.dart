import '/components/app_image.dart';
import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/scoring_engine.dart';
import '/components/button/button_widget.dart';
import '/components/insight_row/insight_row_widget.dart';
import '/components/result_metric/result_metric_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'onboarding_result_model.dart';
export 'onboarding_result_model.dart';

class OnboardingResultWidget extends StatefulWidget {
  const OnboardingResultWidget({super.key});

  static String routeName = 'OnboardingResult';
  static String routePath = '/onboardingResult';

  @override
  State<OnboardingResultWidget> createState() => _OnboardingResultWidgetState();
}

class _OnboardingResultWidgetState extends State<OnboardingResultWidget> {
  late OnboardingResultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<OnboardingAssessmentRecord?>? _assessmentSub;
  ScoringResult? _result;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingResultModel());
    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      _assessmentSub = streamLatestAssessment(uid).listen((rec) async {
        if (rec != null && mounted) {
          final user = await getUser(uid);
          final result = ScoringEngine.compute(
            conditionType: rec.conditionType,
            answers: rec.answers,
            age: user?.age ?? 25,
          );
          if (mounted) safeSetState(() => _result = result);
        }
      });
    }
  }

  @override
  void dispose() {
    _assessmentSub?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = _result?.healthScore ?? 0;
    final scoreD = score.toDouble();
    final pieChartPieChartColorsList = [
      FlutterFlowTheme.of(context).onPrimary,
      FlutterFlowTheme.of(context).onPrimary20
    ];
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
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              AppImages.lottieSuccessCheckmark,
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.contain,
                              repeat: false,
                              animate: true,
                            ),
                            Text(
                              'Your Profile is Ready',
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                            ),
                            Text(
                              'Based on your symptoms and profile, here is your initial health assessment.',
                              textAlign: TextAlign.center,
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
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        child: Container(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary,
                                  FlutterFlowTheme.of(context).secondary
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(1.0, 1.0),
                                end: AlignmentDirectional(-1.0, -1.0),
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      children: [
                                        Container(
                                          width: 180.0,
                                          height: 180.0,
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Container(
                                            height: 140.0,
                                            child: FlutterFlowPieChart(
                                              data: FFPieChartData(
                                                values: ([scoreD, (100 - scoreD)]),
                                                colors:
                                                    pieChartPieChartColorsList,
                                                radius: [15.0],
                                              ),
                                              donutHoleRadius: 65.0,
                                              donutHoleColor:
                                                  Colors.transparent,
                                              sectionLabelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
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
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$score',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineLarge
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface,
                                                          fontSize: 48.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLarge
                                                                  .fontStyle,
                                                          lineHeight: 1.2,
                                                        ),
                                              ),
                                              Text(
                                                'Health Score',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface80,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .onPrimary20,
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _result?.diagnosisLabel ?? 'Health Assessment',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .onSurface,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                        Text(
                                          _result?.explanation ?? 'Based on your answers, we have created a personalized wellness plan for you.',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
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
                                                    FlutterFlowTheme.of(context)
                                                        .onSurface90,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 4.0)),
                                    ),
                                  ].divide(SizedBox(height: 24.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.resultMetricModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: ResultMetricWidget(
                                  color: Color(0xFFF06292),
                                  icon: Icon(
                                    Icons.water_drop_rounded,
                                    color: Color(0xFFF06292),
                                    size: 20.0,
                                  ),
                                  label: 'Cycle Regularity',
                                  value: _result?.cycleRegularity ?? '—',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.resultMetricModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: ResultMetricWidget(
                                  color: Color(0xFF7986CB),
                                  icon: Icon(
                                    Icons.speed_rounded,
                                    color: Color(0xFFF06292),
                                    size: 20.0,
                                  ),
                                  label: 'Metabolic Rate',
                                  value: _result?.metabolicRate ?? '—',
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: 16.0)),
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
                              'Personalized Focus Areas',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
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
                                padding: EdgeInsets.all(24.0),
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (_result != null)
                                        for (var i = 0; i < _result!.focusAreas.length && i < 3; i++)
                                          wrapWithModel(
                                            model: i == 0
                                                ? _model.insightRowModel1
                                                : i == 1
                                                    ? _model.insightRowModel2
                                                    : _model.insightRowModel3,
                                            updateCallback: () => safeSetState(() {}),
                                            child: InsightRowWidget(
                                              bg: [const Color(0xFFFFF3E0), const Color(0xFFE8EAF6), const Color(0xFFE8F5E9)][i % 3],
                                              color: [const Color(0xFFE65100), const Color(0xFF3F51B5), const Color(0xFF2E7D32)][i % 3],
                                              desc: _result!.focusAreas[i].subtitle,
                                              icon: Icon(
                                                [Icons.restaurant_rounded, Icons.self_improvement_rounded, Icons.fitness_center_rounded][i % 3],
                                                color: [const Color(0xFFE65100), const Color(0xFF3F51B5), const Color(0xFF2E7D32)][i % 3],
                                                size: 18.0,
                                              ),
                                              title: _result!.focusAreas[i].title,
                                            ),
                                          ),
                                    ].divide(SizedBox(height: 24.0)),
                                  ),
                                ),
                              ),
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
                            // Primary CTA out of the results screen: book the
                            // free first consultation. The score is only useful
                            // if it leads somewhere — this is that step.
                            InkWell(
                              onTap: () => context.pushNamed(
                                DoctorSelectionWidget.routeName,
                                extra: {'appointmentType': 'free'},
                              ),
                              child: wrapWithModel(
                                model: _model.buttonModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  content: 'Book your free appointment now',
                                  icon: Icon(
                                    Icons.event_available_rounded,
                                    color: FlutterFlowTheme.of(context).onPrimary,
                                    size: 18.0,
                                  ),
                                  icon_present: true,
                                  icon_end_present: false,
                                  color:
                                      FlutterFlowTheme.of(context).secondaryText,
                                  variant: 'primary',
                                  size: 'large',
                                  full_width: true,
                                  loading: false,
                                  disabled: false,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => context
                                  .goNamed(HomeDashboardWidget.routeName),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  'Skip for now — go to dashboard',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w600),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => context.goNamed(
                                  OnboardingStepFormWidget.routeName),
                              child: wrapWithModel(
                                model: _model.buttonModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  content: 'Retake Assessment',
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 16.0,
                                ),
                                icon_present: true,
                                icon_end_present: false,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                variant: 'ghost',
                                size: 'medium',
                                full_width: true,
                                loading: false,
                                disabled: false,
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                      Container(
                        height: 24.0,
                      ),
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
}
