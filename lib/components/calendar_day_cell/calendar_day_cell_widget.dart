import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_day_cell_model.dart';
export 'calendar_day_cell_model.dart';

class CalendarDayCellWidget extends StatefulWidget {
  CalendarDayCellWidget({
    super.key,
    String? day_num,
    bool? has_event,
    Color? phase_color,
    bool? is_selected,
    bool? is_today,
  })  : this.day_num = day_num ?? '25',
        this.has_event = has_event ?? false,
        this.phase_color = phase_color,
        this.is_selected = is_selected ?? true,
        this.is_today = is_today ?? false;

  final String day_num;
  final bool has_event;
  final Color? phase_color;
  final bool is_selected;
  final bool is_today;

  @override
  State<CalendarDayCellWidget> createState() => _CalendarDayCellWidgetState();
}

class _CalendarDayCellWidgetState extends State<CalendarDayCellWidget> {
  late CalendarDayCellModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarDayCellModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.0,
      height: 64.0,
      decoration: BoxDecoration(
        color: () {
          if (widget.is_today) {
            return FlutterFlowTheme.of(context).primary;
          } else if (widget.is_selected) {
            return FlutterFlowTheme.of(context).primary10;
          } else {
            return Colors.transparent;
          }
        }(),
        borderRadius: BorderRadius.circular(18.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: widget.is_selected
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            valueOrDefault<String>(
              widget.day_num,
              '25',
            ),
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: widget.is_today
                      ? FlutterFlowTheme.of(context).onPrimary
                      : FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.3,
                ),
          ),
          if (valueOrDefault<bool>(
            widget.has_event,
            false,
          ))
            Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: valueOrDefault<Color>(
                  widget.phase_color,
                  FlutterFlowTheme.of(context).primary,
                ),
                borderRadius: BorderRadius.circular(9999.0),
                shape: BoxShape.rectangle,
              ),
            ),
        ].divide(SizedBox(height: 4.0)),
      ),
    );
  }
}
