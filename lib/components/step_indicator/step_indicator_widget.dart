import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'step_indicator_model.dart';
export 'step_indicator_model.dart';

class StepIndicatorWidget extends StatefulWidget {
  const StepIndicatorWidget({
    super.key,
    double? step,
  }) : this.step = step ?? 2.0;

  final double step;

  @override
  State<StepIndicatorWidget> createState() => _StepIndicatorWidgetState();
}

class _StepIndicatorWidgetState extends State<StepIndicatorWidget> {
  late StepIndicatorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StepIndicatorModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: widget.step >= 1.0
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(9999.0),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          width: 24.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: widget.step >= 2.0
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(9999.0),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          width: 24.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: widget.step >= 3.0
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(9999.0),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          width: 24.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: widget.step >= 4.0
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(9999.0),
            shape: BoxShape.rectangle,
          ),
        ),
      ].divide(SizedBox(width: 8.0)),
    );
  }
}
