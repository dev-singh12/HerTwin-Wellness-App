import '/components/chat_bubble/chat_bubble_widget.dart';
import '/components/report_attachment/report_attachment_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'consultation_chat_widget.dart' show ConsultationChatWidget;
import 'package:flutter/material.dart';

class ConsultationChatModel extends FlutterFlowModel<ConsultationChatWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ChatBubble.
  late ChatBubbleModel chatBubbleModel1;
  // Model for ChatBubble.
  late ChatBubbleModel chatBubbleModel2;
  // Model for ChatBubble.
  late ChatBubbleModel chatBubbleModel3;
  // Model for ReportAttachment.
  late ReportAttachmentModel reportAttachmentModel;
  // Model for ChatBubble.
  late ChatBubbleModel chatBubbleModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel;

  @override
  void initState(BuildContext context) {
    chatBubbleModel1 = createModel(context, () => ChatBubbleModel());
    chatBubbleModel2 = createModel(context, () => ChatBubbleModel());
    chatBubbleModel3 = createModel(context, () => ChatBubbleModel());
    reportAttachmentModel = createModel(context, () => ReportAttachmentModel());
    chatBubbleModel4 = createModel(context, () => ChatBubbleModel());
    textFieldModel = createModel(context, () => TextFieldModel());
  }

  @override
  void dispose() {
    chatBubbleModel1.dispose();
    chatBubbleModel2.dispose();
    chatBubbleModel3.dispose();
    reportAttachmentModel.dispose();
    chatBubbleModel4.dispose();
    textFieldModel.dispose();
  }
}
