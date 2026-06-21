import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/components/chat_bubble/chat_bubble_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'consultation_chat_model.dart';
export 'consultation_chat_model.dart';

class ConsultationChatWidget extends StatefulWidget {
  const ConsultationChatWidget({super.key});

  static String routeName = 'ConsultationChat';
  static String routePath = '/consultationChat';

  @override
  State<ConsultationChatWidget> createState() => _ConsultationChatWidgetState();
}

class _ConsultationChatWidgetState extends State<ConsultationChatWidget> {
  late ConsultationChatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<AppointmentRecord?>? _apptSub;
  AppointmentRecord? _appointment;
  String _doctorName = 'Dr. Sarah Jenkins';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConsultationChatModel());

    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      _apptSub = streamNextAppointment(uid).listen((appt) {
        if (mounted) {
          safeSetState(() {
            _appointment = appt;
            if (appt != null && appt.doctorName.isNotEmpty) {
              _doctorName = appt.doctorName;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _apptSub?.cancel();
    _model.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _uploadReport() async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      _showMessage('Uploading report...');
      final bytes = await picked.readAsBytes();
      await uploadPrescription(uid, bytes);
      if (!mounted) return;
      _showMessage('Report uploaded successfully.');
    } catch (e) {
      _showMessage('Could not upload report. Please try again.');
    }
  }

  void _sendMessage() {
    final uid = AuthManager.instance.currentUid;
    if (uid == null || _appointment == null) return;
    final controller = _model.textFieldModel.inputTextController;
    final text = (controller?.text ?? '').trim();
    if (text.isEmpty) return;
    controller?.clear();
    sendChatMessage(uid, _appointment!.id,
      senderUid: uid,
      senderName: 'You',
      content: text,
    );
  }

  void _launchVideoCall() async {
    if (_appointment == null) {
      _showMessage('No active appointment found.');
      return;
    }
    final url = Uri.parse(jitsiRoomUrl(_appointment!.id));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Could not open video call.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 20.0,
                            ),
                            onPressed: () => context.safePop(),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9999.0),
                            child: Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9999.0),
                                shape: BoxShape.rectangle,
                              ),
                              child: CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 0),
                                fadeOutDuration: Duration(milliseconds: 0),
                                imageUrl:
                                    'https://dimg.dreamflow.cloud/v1/image/professional%20female%20doctor%20portrait%2C%20soft%20lighting',
                                fit: BoxFit.cover,
                                alignment: Alignment(0.0, 0.0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _doctorName,
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .success,
                                        borderRadius:
                                            BorderRadius.circular(9999.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    Text(
                                      'Online • Gynaecologist',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ],
                            ),
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.videocam_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: _launchVideoCall,
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _appointment == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: FlutterFlowTheme.of(context).secondaryText.withAlpha(100)),
                            const SizedBox(height: 12),
                            Text('No active consultation.\nBook a doctor to start chatting.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 14, color: FlutterFlowTheme.of(context).secondaryText)),
                          ],
                        ),
                      ),
                    )
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: streamChatMessages(
                          AuthManager.instance.currentUid!, _appointment!.id),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? [];
                        if (messages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.waving_hand_rounded, size: 40, color: FlutterFlowTheme.of(context).primary),
                                  const SizedBox(height: 12),
                                  Text('Say hello to $_doctorName!\nYour messages appear here in real time.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(fontSize: 14, color: FlutterFlowTheme.of(context).secondaryText)),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: messages.length,
                          itemBuilder: (context, i) {
                            final msg = messages[i];
                            final isSent = msg['senderUid'] == AuthManager.instance.currentUid;
                            final sentAt = (msg['sentAt'] as Timestamp?)?.toDate();
                            final timeStr = sentAt != null
                                ? TimeOfDay.fromDateTime(sentAt).format(context)
                                : '';
                            return ChatBubbleWidget(
                              message: msg['content'] as String? ?? '',
                              time: timeStr,
                              is_sent: isSent,
                            );
                          },
                        );
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => _uploadReport(),
                                child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8EAF6),
                                  borderRadius: BorderRadius.circular(9999.0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 8.0, 16.0, 8.0),
                                  child: Container(
                                    child: Container(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Color(0xFF3F51B5),
                                            size: 18.0,
                                          ),
                                          Text(
                                            'Upload Report',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF3F51B5),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 4.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                              InkWell(
                                onTap: () => _showMessage(
                                    'Prescription request sent to doctor.'),
                                child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(9999.0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 8.0, 16.0, 8.0),
                                  child: Container(
                                    child: Container(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.medication_rounded,
                                            color: Color(0xFFC2185B),
                                            size: 18.0,
                                          ),
                                          Text(
                                            'Request Rx',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFFC2185B),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 4.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.textFieldModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TextFieldWidget(
                                    label: false,
                                    helper: false,
                                    hint: 'Type your message...',
                                    value: '',
                                    leading_icon: Icon(
                                      Icons.sentiment_satisfied_alt_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 16.0,
                                    ),
                                    leading_icon_present: true,
                                    trailing_icon_present: false,
                                    variant: 'ghost',
                                    error: false,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _sendMessage,
                                child: Container(
                                width: 48.0,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).primary,
                                      FlutterFlowTheme.of(context).secondary
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  borderRadius: BorderRadius.circular(9999.0),
                                  shape: BoxShape.rectangle,
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: FlutterFlowTheme.of(context).onSurface,
                                  size: 22.0,
                                ),
                              ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
