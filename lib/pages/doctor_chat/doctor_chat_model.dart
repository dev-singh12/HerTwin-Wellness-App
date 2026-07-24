import '/flutter_flow/flutter_flow_util.dart';
import 'doctor_chat_widget.dart' show DoctorChatWidget;
import 'package:flutter/material.dart';

class DoctorChatModel extends FlutterFlowModel<DoctorChatWidget> {
  TextEditingController? inputController;
  final scrollController = ScrollController();

  @override
  void initState(BuildContext context) {
    inputController = TextEditingController();
  }

  @override
  void dispose() {
    inputController?.dispose();
    scrollController.dispose();
  }
}
