import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ritual_tile_model.dart';
export 'ritual_tile_model.dart';

class RitualTileWidget extends StatefulWidget {
  const RitualTileWidget({
    super.key,
    Color? bg,
    Color? color,
    this.icon,
    String? time,
    String? title,
    bool? done,
  })  : this.bg = bg ?? const Color(0xFFFCE4EC),
        this.color = color ?? const Color(0xFFF06292),
        this.time = time ?? '09:00 AM',
        this.title = title ?? 'Vitamin B Complex',
        this.done = done ?? true;

  final Color bg;
  final Color color;
  final Widget? icon;
  final String time;
  final String title;
  final bool done;

  @override
  State<RitualTileWidget> createState() => _RitualTileWidgetState();
}

class _RitualTileWidgetState extends State<RitualTileWidget> {
  late RitualTileModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RitualTileModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: valueOrDefault<Color>(
                widget.bg,
                Color(0xFFFCE4EC),
              ),
              borderRadius: BorderRadius.circular(18.0),
              shape: BoxShape.rectangle,
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: widget.icon!,
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valueOrDefault<String>(
                    widget.title,
                    'Vitamin B Complex',
                  ),
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.5,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  valueOrDefault<String>(
                    widget.time,
                    '09:00 AM',
                  ),
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).labelSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        lineHeight: 1.2,
                      ),
                ),
              ].divide(SizedBox(height: 4.0)),
            ),
          ),
          FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 40.0,
            fillColor: Colors.transparent,
            icon: Icon(
              Icons.check_circle_rounded,
              color: widget.done
                  ? FlutterFlowTheme.of(context).success
                  : FlutterFlowTheme.of(context).accent3,
              size: 24.0,
            ),
            onPressed: () {
              print('IconButton pressed ...');
            },
          ),
        ].divide(SizedBox(width: 16.0)),
      ),
    );
  }
}
