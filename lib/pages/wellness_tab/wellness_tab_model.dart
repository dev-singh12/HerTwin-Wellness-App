import '/components/category_chip/category_chip_widget.dart';
import '/components/wellness_card/wellness_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'wellness_tab_widget.dart' show WellnessTabWidget;
import 'package:flutter/material.dart';

class WellnessTabModel extends FlutterFlowModel<WellnessTabWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel1;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel2;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel3;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel4;
  // Model for CategoryChip.
  late CategoryChipModel categoryChipModel5;
  // Model for WellnessCard.
  late WellnessCardModel wellnessCardModel1;
  // Model for WellnessCard.
  late WellnessCardModel wellnessCardModel2;
  // Model for WellnessCard.
  late WellnessCardModel wellnessCardModel3;

  @override
  void initState(BuildContext context) {
    categoryChipModel1 = createModel(context, () => CategoryChipModel());
    categoryChipModel2 = createModel(context, () => CategoryChipModel());
    categoryChipModel3 = createModel(context, () => CategoryChipModel());
    categoryChipModel4 = createModel(context, () => CategoryChipModel());
    categoryChipModel5 = createModel(context, () => CategoryChipModel());
    wellnessCardModel1 = createModel(context, () => WellnessCardModel());
    wellnessCardModel2 = createModel(context, () => WellnessCardModel());
    wellnessCardModel3 = createModel(context, () => WellnessCardModel());
  }

  @override
  void dispose() {
    categoryChipModel1.dispose();
    categoryChipModel2.dispose();
    categoryChipModel3.dispose();
    categoryChipModel4.dispose();
    categoryChipModel5.dispose();
    wellnessCardModel1.dispose();
    wellnessCardModel2.dispose();
    wellnessCardModel3.dispose();
  }
}
