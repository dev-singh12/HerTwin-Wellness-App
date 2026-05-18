import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'symptom_chip_model.dart';
export 'symptom_chip_model.dart';

class SymptomChipWidget extends StatefulWidget {
  const SymptomChipWidget({
    super.key,
    this.icon,
    String? label,
    bool? selected,
  })  : this.label = label ?? 'Cramps',
        this.selected = selected ?? true;

  final Widget? icon;
  final String label;
  final bool selected;

  @override
  State<SymptomChipWidget> createState() => _SymptomChipWidgetState();
}

class _SymptomChipWidgetState extends State<SymptomChipWidget> {
  late SymptomChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SymptomChipModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 8.0),
      child: Container(
        child: Container(
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
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.icon!,
                  Text(
                    valueOrDefault<String>(
                      widget.label,
                      'Cramps',
                    ),
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                          ),
                          color: widget.selected
                              ? FlutterFlowTheme.of(context).onPrimary
                              : FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontStyle,
                          lineHeight: 1.3,
                        ),
                  ),
                ].divide(SizedBox(width: 4.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
