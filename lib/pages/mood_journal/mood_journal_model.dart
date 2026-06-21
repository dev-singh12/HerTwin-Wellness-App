import '/flutter_flow/flutter_flow_util.dart';
import 'mood_journal_widget.dart' show MoodJournalWidget;
import 'package:flutter/material.dart';

class MoodJournalModel extends FlutterFlowModel<MoodJournalWidget> {
  FocusNode? contentFocusNode;
  TextEditingController? contentTextController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    contentFocusNode?.dispose();
    contentTextController?.dispose();
  }
}
