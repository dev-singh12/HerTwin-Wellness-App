import '/components/button/button_widget.dart';
import '/components/mood_selector/mood_selector_widget.dart';
import '/components/symptom_chip/symptom_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'log_symptoms_modal_widget.dart' show LogSymptomsModalWidget;
import 'package:flutter/material.dart';

class LogSymptomsModalModel extends FlutterFlowModel<LogSymptomsModalWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for MoodSelector.
  late MoodSelectorModel moodSelectorModel1;
  // Model for MoodSelector.
  late MoodSelectorModel moodSelectorModel2;
  // Model for MoodSelector.
  late MoodSelectorModel moodSelectorModel3;
  // Model for MoodSelector.
  late MoodSelectorModel moodSelectorModel4;
  // Model for MoodSelector.
  late MoodSelectorModel moodSelectorModel5;
  // Model for SymptomChip.
  late SymptomChipModel symptomChipModel1;
  // Model for SymptomChip.
  late SymptomChipModel symptomChipModel2;
  // Model for SymptomChip.
  late SymptomChipModel symptomChipModel3;
  // Model for SymptomChip.
  late SymptomChipModel symptomChipModel4;
  // Model for SymptomChip.
  late SymptomChipModel symptomChipModel5;
  // Model for SymptomChip.
  late SymptomChipModel symptomChipModel6;
  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    moodSelectorModel1 = createModel(context, () => MoodSelectorModel());
    moodSelectorModel2 = createModel(context, () => MoodSelectorModel());
    moodSelectorModel3 = createModel(context, () => MoodSelectorModel());
    moodSelectorModel4 = createModel(context, () => MoodSelectorModel());
    moodSelectorModel5 = createModel(context, () => MoodSelectorModel());
    symptomChipModel1 = createModel(context, () => SymptomChipModel());
    symptomChipModel2 = createModel(context, () => SymptomChipModel());
    symptomChipModel3 = createModel(context, () => SymptomChipModel());
    symptomChipModel4 = createModel(context, () => SymptomChipModel());
    symptomChipModel5 = createModel(context, () => SymptomChipModel());
    symptomChipModel6 = createModel(context, () => SymptomChipModel());
    textFieldModel = createModel(context, () => TextFieldModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel1.dispose();
    moodSelectorModel1.dispose();
    moodSelectorModel2.dispose();
    moodSelectorModel3.dispose();
    moodSelectorModel4.dispose();
    moodSelectorModel5.dispose();
    symptomChipModel1.dispose();
    symptomChipModel2.dispose();
    symptomChipModel3.dispose();
    symptomChipModel4.dispose();
    symptomChipModel5.dispose();
    symptomChipModel6.dispose();
    textFieldModel.dispose();
    buttonModel2.dispose();
  }
}
