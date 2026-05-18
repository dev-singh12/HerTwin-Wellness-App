import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'condition_chip_model.dart';
export 'condition_chip_model.dart';

class ConditionChipWidget extends StatefulWidget {
  const ConditionChipWidget({
    super.key,
    this.icon,
    String? label,
    bool? selected,
  })  : this.label = label ?? 'PCOS',
        this.selected = selected ?? true;

  final Widget? icon;
  final String label;
  final bool selected;

  @override
  State<ConditionChipWidget> createState() => _ConditionChipWidgetState();
}

class _ConditionChipWidgetState extends State<ConditionChipWidget> {
  late ConditionChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConditionChipModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.selected
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(28.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: widget.selected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).alternate,
          width: widget.selected ? 1.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.icon!,
              Expanded(
                flex: 1,
                child: Text(
                  valueOrDefault<String>(
                    widget.label,
                    'PCOS',
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: widget.selected
                            ? FlutterFlowTheme.of(context).onPrimary
                            : FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.5,
                      ),
                ),
              ),
              Container(
                width: 20.0,
                height: 20.0,
                child: Stack(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  children: [
                    if (widget.selected ? true : false)
                      Icon(
                        Icons.check_circle_rounded,
                        color: widget.selected
                            ? FlutterFlowTheme.of(context).onPrimary
                            : FlutterFlowTheme.of(context).accent3,
                        size: 20.0,
                      ),
                    if (widget.selected ? false : true)
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: widget.selected
                            ? FlutterFlowTheme.of(context).onPrimary
                            : FlutterFlowTheme.of(context).accent3,
                        size: 20.0,
                      ),
                  ],
                ),
              ),
            ].divide(SizedBox(width: 16.0)),
          ),
        ),
      ),
    );
  }
}
