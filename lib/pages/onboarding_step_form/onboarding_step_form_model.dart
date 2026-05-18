import '/components/button/button_widget.dart';
import '/components/condition_chip/condition_chip_widget.dart';
import '/components/step_indicator/step_indicator_widget.dart';
import '/components/symptom_item/symptom_item_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'onboarding_step_form_widget.dart' show OnboardingStepFormWidget;
import 'package:flutter/material.dart';

class OnboardingStepFormModel
    extends FlutterFlowModel<OnboardingStepFormWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel;
  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for ConditionChip.
  late ConditionChipModel conditionChipModel1;
  // Model for ConditionChip.
  late ConditionChipModel conditionChipModel2;
  // Model for ConditionChip.
  late ConditionChipModel conditionChipModel3;
  // Model for ConditionChip.
  late ConditionChipModel conditionChipModel4;
  // Model for SymptomItem.
  late SymptomItemModel symptomItemModel1;
  // Model for SymptomItem.
  late SymptomItemModel symptomItemModel2;
  // Model for SymptomItem.
  late SymptomItemModel symptomItemModel3;
  // Model for SymptomItem.
  late SymptomItemModel symptomItemModel4;
  // Model for SymptomItem.
  late SymptomItemModel symptomItemModel5;
  // Model for SymptomItem.
  late SymptomItemModel symptomItemModel6;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    stepIndicatorModel = createModel(context, () => StepIndicatorModel());
    textFieldModel = createModel(context, () => TextFieldModel());
    conditionChipModel1 = createModel(context, () => ConditionChipModel());
    conditionChipModel2 = createModel(context, () => ConditionChipModel());
    conditionChipModel3 = createModel(context, () => ConditionChipModel());
    conditionChipModel4 = createModel(context, () => ConditionChipModel());
    symptomItemModel1 = createModel(context, () => SymptomItemModel());
    symptomItemModel2 = createModel(context, () => SymptomItemModel());
    symptomItemModel3 = createModel(context, () => SymptomItemModel());
    symptomItemModel4 = createModel(context, () => SymptomItemModel());
    symptomItemModel5 = createModel(context, () => SymptomItemModel());
    symptomItemModel6 = createModel(context, () => SymptomItemModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    stepIndicatorModel.dispose();
    textFieldModel.dispose();
    conditionChipModel1.dispose();
    conditionChipModel2.dispose();
    conditionChipModel3.dispose();
    conditionChipModel4.dispose();
    symptomItemModel1.dispose();
    symptomItemModel2.dispose();
    symptomItemModel3.dispose();
    symptomItemModel4.dispose();
    symptomItemModel5.dispose();
    symptomItemModel6.dispose();
    buttonModel.dispose();
  }
}
