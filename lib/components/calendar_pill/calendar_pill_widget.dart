import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_pill_model.dart';
export 'calendar_pill_model.dart';

class CalendarPillWidget extends StatefulWidget {
  const CalendarPillWidget({
    super.key,
    String? day_name,
    String? day_num,
    bool? is_period,
    bool? active,
  })  : this.day_name = day_name ?? 'Mon',
        this.day_num = day_num ?? '18',
        this.is_period = is_period ?? false,
        this.active = active ?? false;

  final String day_name;
  final String day_num;
  final bool is_period;
  final bool active;

  @override
  State<CalendarPillWidget> createState() => _CalendarPillWidgetState();
}

class _CalendarPillWidgetState extends State<CalendarPillWidget> {
  late CalendarPillModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarPillModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.0,
      height: 84.0,
      decoration: BoxDecoration(
        color: widget.active
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(9999.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: widget.active
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).alternate,
          width: widget.active ? 1.0 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            valueOrDefault<String>(
              widget.day_name,
              'Mon',
            ),
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelSmall.fontStyle,
                  ),
                  color: widget.active
                      ? FlutterFlowTheme.of(context).onPrimary
                      : FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelSmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                  lineHeight: 1.2,
                ),
          ),
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: widget.active
                  ? FlutterFlowTheme.of(context).onPrimary30
                  : FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(9999.0),
              shape: BoxShape.rectangle,
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              valueOrDefault<String>(
                widget.day_num,
                '18',
              ),
              style: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight:
                          FlutterFlowTheme.of(context).labelLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    ),
                    color: widget.active
                        ? FlutterFlowTheme.of(context).onPrimary
                        : FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    lineHeight: 1.3,
                  ),
            ),
          ),
          if (valueOrDefault<bool>(
            widget.is_period,
            false,
          ))
            Container(
              width: 4.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).error,
                borderRadius: BorderRadius.circular(9999.0),
                shape: BoxShape.rectangle,
              ),
            ),
        ].divide(SizedBox(height: 8.0)),
      ),
    );
  }
}
