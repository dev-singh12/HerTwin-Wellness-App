import '/components/category_chip/category_chip_widget.dart';
import '/components/wellness_card/wellness_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wellness_tab_model.dart';
export 'wellness_tab_model.dart';

class WellnessTabWidget extends StatefulWidget {
  const WellnessTabWidget({super.key});

  static String routeName = 'WellnessTab';
  static String routePath = '/wellnessTab';

  @override
  State<WellnessTabWidget> createState() => _WellnessTabWidgetState();
}

class _WellnessTabWidgetState extends State<WellnessTabWidget> {
  late WellnessTabModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WellnessTabModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        body: Stack(
          alignment: AlignmentDirectional(-1.0, -1.0),
          children: [
            SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 24.0, 24.0, 16.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wellness Library',
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
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
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
                              'Holistic tools for your cycle harmony',
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
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 16.0),
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                wrapWithModel(
                                  model: _model.categoryChipModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.grid_view_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      size: 18.0,
                                    ),
                                    label: 'All',
                                    selected: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.categoryChipModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.spa_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Yoga',
                                    selected: false,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.categoryChipModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.psychology_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Mind',
                                    selected: false,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.categoryChipModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.auto_stories_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Guides',
                                    selected: false,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.categoryChipModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.self_improvement_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Meditation',
                                    selected: false,
                                  ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Recommended for You',
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
                            Text(
                              'See All',
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
                                    color:
                                        FlutterFlowTheme.of(context).onSurface,
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
                          ],
                        ),
                        wrapWithModel(
                          model: _model.wellnessCardModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: WellnessCardWidget(
                            duration: '15 mins',
                            img_desc:
                                'https://dimg.dreamflow.cloud/v1/image/woman%20doing%20yoga%20in%20a%20sunlit%20minimal%20room',
                            subtitle:
                                'Boost energy and flexibility during your follicular phase.',
                            title: 'Follicular Flow Yoga',
                            type: 'video',
                          ),
                        ),
                        Container(
                          height: 16.0,
                        ),
                        Text(
                          'Mental Well-being',
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
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
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 120.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3E5F5),
                                  borderRadius: BorderRadius.circular(28.0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Container(
                                    child: Container(
                                      height: 72.0,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.favorite_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onSurface,
                                            size: 28.0,
                                          ),
                                          Text(
                                            'Mood Journal',
                                            style: FlutterFlowTheme.of(context)
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
                                                  color: Color(0xFF7B1FA2),
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
                                        ].divide(SizedBox(height: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 120.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE1F5FE),
                                  borderRadius: BorderRadius.circular(28.0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Container(
                                    child: Container(
                                      height: 72.0,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.air_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onSurface,
                                            size: 28.0,
                                          ),
                                          Text(
                                            'Breathwork',
                                            style: FlutterFlowTheme.of(context)
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
                                                  color: Color(0xFF0288D1),
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
                                        ].divide(SizedBox(height: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: 16.0)),
                        ),
                        Container(
                          height: 24.0,
                        ),
                        Text(
                          'Educational Articles',
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
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
                        wrapWithModel(
                          model: _model.wellnessCardModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: WellnessCardWidget(
                            duration: '8 min read',
                            img_desc:
                                'https://dimg.dreamflow.cloud/v1/image/abstract%20soft%20pastel%20medical%20illustration',
                            subtitle:
                                'A deep dive into hormonal imbalances and how to manage them naturally.',
                            title: 'Understanding PCOS',
                            type: 'article',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.wellnessCardModel3,
                          updateCallback: () => safeSetState(() {}),
                          child: WellnessCardWidget(
                            duration: '5 min read',
                            img_desc:
                                'https://dimg.dreamflow.cloud/v1/image/healthy%20colorful%20bowl%20of%20fruits%20and%20seeds',
                            subtitle:
                                'Foods that help reduce bloating and mood swings before your period.',
                            title: 'Nutrition for PMS',
                            type: 'article',
                          ),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                  Container(
                    height: 100.0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Container(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    print('FAB pressed ...');
                  },
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
