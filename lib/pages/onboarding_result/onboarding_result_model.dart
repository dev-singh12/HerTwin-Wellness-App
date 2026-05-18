import '/components/button/button_widget.dart';
import '/components/insight_row/insight_row_widget.dart';
import '/components/result_metric/result_metric_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'onboarding_result_widget.dart' show OnboardingResultWidget;
import 'package:flutter/material.dart';

class OnboardingResultModel extends FlutterFlowModel<OnboardingResultWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ResultMetric.
  late ResultMetricModel resultMetricModel1;
  // Model for ResultMetric.
  late ResultMetricModel resultMetricModel2;
  // Model for InsightRow.
  late InsightRowModel insightRowModel1;
  // Model for InsightRow.
  late InsightRowModel insightRowModel2;
  // Model for InsightRow.
  late InsightRowModel insightRowModel3;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    resultMetricModel1 = createModel(context, () => ResultMetricModel());
    resultMetricModel2 = createModel(context, () => ResultMetricModel());
    insightRowModel1 = createModel(context, () => InsightRowModel());
    insightRowModel2 = createModel(context, () => InsightRowModel());
    insightRowModel3 = createModel(context, () => InsightRowModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    resultMetricModel1.dispose();
    resultMetricModel2.dispose();
    insightRowModel1.dispose();
    insightRowModel2.dispose();
    insightRowModel3.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
