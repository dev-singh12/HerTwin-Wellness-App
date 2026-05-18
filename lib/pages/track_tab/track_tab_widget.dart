import '/components/calendar_day_cell/calendar_day_cell_widget.dart';
import '/components/history_item/history_item_widget.dart';
import '/components/phase_legend_item/phase_legend_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'track_tab_model.dart';
export 'track_tab_model.dart';

class TrackTabWidget extends StatefulWidget {
  const TrackTabWidget({super.key});

  static String routeName = 'TrackTab';
  static String routePath = '/trackTab';

  @override
  State<TrackTabWidget> createState() => _TrackTabWidgetState();
}

class _TrackTabWidgetState extends State<TrackTabWidget> {
  late TrackTabModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrackTabModel());
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
            Column(
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
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cycle Tracker',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .headlineMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .headlineMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
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
                                    'October 2023',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                              FlutterFlowIconButton(
                                borderRadius: 18.0,
                                buttonSize: 40.0,
                                fillColor:
                                    FlutterFlowTheme.of(context).secondary10,
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  size: 24.0,
                                ),
                                onPressed: () {
                                  print('IconButton pressed ...');
                                },
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
                  child: Container(
                    child: SingleChildScrollView(
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                FlutterFlowIconButton(
                                                  borderRadius: 8.0,
                                                  buttonSize: 40.0,
                                                  fillColor: Colors.transparent,
                                                  icon: Icon(
                                                    Icons.chevron_left_rounded,
                                                    size: 24.0,
                                                  ),
                                                  onPressed: () {
                                                    print(
                                                        'IconButton pressed ...');
                                                  },
                                                ),
                                                Text(
                                                  'October 2023',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                                FlutterFlowIconButton(
                                                  borderRadius: 8.0,
                                                  buttonSize: 40.0,
                                                  fillColor: Colors.transparent,
                                                  icon: Icon(
                                                    Icons.chevron_right_rounded,
                                                    size: 24.0,
                                                  ),
                                                  onPressed: () {
                                                    print(
                                                        'IconButton pressed ...');
                                                  },
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'M',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Text(
                                                  'T',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Text(
                                                  'W',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Text(
                                                  'T',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Text(
                                                  'F',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Text(
                                                  'S',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                                Text(
                                                  'S',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onSurface,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.2,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel1,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '25',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel2,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '26',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel3,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '27',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel4,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '28',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel5,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '29',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel6,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '30',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel7,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '1',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel8,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '2',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel9,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '3',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel10,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '4',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel11,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '5',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel12,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '6',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel13,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '7',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel14,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '8',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel15,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '9',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel16,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '10',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel17,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '11',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel18,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '12',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel19,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '13',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel20,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '14',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel21,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '15',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel22,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '16',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel23,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '17',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel24,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '18',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel25,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '19',
                                                        has_event: false,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel26,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '20',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel27,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '21',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        is_selected: true,
                                                        is_today: false,
                                                      ),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .calendarDayCellModel28,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          CalendarDayCellWidget(
                                                        day_num: '22',
                                                        has_event: true,
                                                        phase_color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        is_selected: true,
                                                        is_today: true,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 8.0)),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Wrap(
                                                spacing: 16.0,
                                                runSpacing: 8.0,
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.start,
                                                direction: Axis.horizontal,
                                                runAlignment:
                                                    WrapAlignment.start,
                                                verticalDirection:
                                                    VerticalDirection.down,
                                                clipBehavior: Clip.none,
                                                children: [
                                                  wrapWithModel(
                                                    model: _model
                                                        .phaseLegendItemModel1,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child:
                                                        PhaseLegendItemWidget(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      label: 'Menstruation',
                                                    ),
                                                  ),
                                                  wrapWithModel(
                                                    model: _model
                                                        .phaseLegendItemModel2,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child:
                                                        PhaseLegendItemWidget(
                                                      color: Color(0xFFCE93D8),
                                                      label: 'Follicular',
                                                    ),
                                                  ),
                                                  wrapWithModel(
                                                    model: _model
                                                        .phaseLegendItemModel3,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child:
                                                        PhaseLegendItemWidget(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                      label: 'Luteal',
                                                    ),
                                                  ),
                                                  wrapWithModel(
                                                    model: _model
                                                        .phaseLegendItemModel4,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child:
                                                        PhaseLegendItemWidget(
                                                      color: Color(0xFF81C784),
                                                      label: 'Ovulation',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 24.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cycle Insights',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFCE4EC),
                                          borderRadius:
                                              BorderRadius.circular(28.0),
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                            color: Color(0xFFF8BBD0),
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
                                                Icon(
                                                  Icons.auto_awesome_rounded,
                                                  color: Color(0xFFD81B60),
                                                  size: 28.0,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Next Period Prediction',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFFAD1457),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.2,
                                                                ),
                                                      ),
                                                      Text(
                                                        'In 6 Days (Oct 28)',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyLarge
                                                            .override(
                                                              font: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontStyle,
                                                              ),
                                                              color: Color(
                                                                  0xFF880E4F),
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                              lineHeight: 1.5,
                                                            ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 4.0)),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 16.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 16.0)),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Recent History',
                                            style: FlutterFlowTheme.of(context)
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
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
                                            'See All',
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .onSurface,
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
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.historyItemModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: HistoryItemWidget(
                                              bg_color: Color(0xFFFCE4EC),
                                              date: 'Sep 28 - Oct 2',
                                              icon: Icon(
                                                Icons.water_drop_rounded,
                                                color: Color(0xFFF06292),
                                                size: 22.0,
                                              ),
                                              icon_color: Color(0xFFF06292),
                                              subtitle: '5 days • Normal flow',
                                              title: 'Last Period',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.historyItemModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: HistoryItemWidget(
                                              bg_color: Color(0xFFE8F5E9),
                                              date: 'Oct 14',
                                              icon: Icon(
                                                Icons.favorite_rounded,
                                                color: Color(0xFF66BB6A),
                                                size: 22.0,
                                              ),
                                              icon_color: Color(0xFF66BB6A),
                                              subtitle: 'Recorded via LH test',
                                              title: 'Ovulation Peak',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.historyItemModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: HistoryItemWidget(
                                              bg_color: Color(0xFFE8EAF6),
                                              date: 'Yesterday',
                                              icon: Icon(
                                                Icons.psychology_rounded,
                                                color: Color(0xFF7986CB),
                                                size: 22.0,
                                              ),
                                              icon_color: Color(0xFF7986CB),
                                              subtitle: 'Cramps, Low Energy',
                                              title: 'Symptom Log',
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 8.0)),
                                      ),
                                    ].divide(SizedBox(height: 16.0)),
                                  ),
                                ].divide(SizedBox(height: 24.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
