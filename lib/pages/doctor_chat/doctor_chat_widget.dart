import '/auth/auth_manager.dart';
import '/auth/role_manager.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doctor_chat_model.dart';
export 'doctor_chat_model.dart';

/// The clinician's side of a consultation conversation.
///
/// Reuses the same `appointments/{id}/messages` collection the patient writes
/// to — the security rules gate both participants identically, so this needed
/// no new backend. Before this page a doctor had no way to read or reply to a
/// patient at all; the patient could message into a void.
class DoctorChatWidget extends StatefulWidget {
  const DoctorChatWidget({super.key, this.appointmentId});

  final String? appointmentId;

  static String routeName = 'DoctorChat';
  static String routePath = '/clinician/chat';

  @override
  State<DoctorChatWidget> createState() => _DoctorChatWidgetState();
}

class _DoctorChatWidgetState extends State<DoctorChatWidget> {
  late DoctorChatModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DoctorChatModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send(AppointmentRecord appt) async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null) return;
    final text = (_model.inputController?.text ?? '').trim();
    if (text.isEmpty) return;
    if (text.length > kMaxChatMessageLength) {
      _toast('Message is too long (max $kMaxChatMessageLength characters).');
      return;
    }
    _model.inputController?.clear();
    try {
      await sendChatMessage(
        appt.id,
        senderUid: uid,
        senderName: RoleManager.instance.profile?.name ?? 'Doctor',
        content: text,
      );
    } catch (_) {
      _toast('Message failed to send. Check your connection.');
    }
  }

  Future<void> _openVideo(AppointmentRecord appt) async {
    final link = appt.meetingLink;
    if (link == null || link.isEmpty) {
      _toast('This consultation is chat-only.');
      return;
    }
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _toast('Could not open the video room.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final uid = AuthManager.instance.currentUid;
    final id = widget.appointmentId;

    if (id == null || id.isEmpty || uid == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('No conversation selected.')),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: StreamBuilder<AppointmentRecord>(
          stream: streamAppointment(id),
          builder: (context, apptSnap) {
            if (!apptSnap.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: theme.primary));
            }
            final appt = apptSnap.data!;

            return Column(
              children: [
                _ChatHeader(
                  patientName:
                      appt.patientName.isEmpty ? 'Patient' : appt.patientName,
                  subtitle: [
                    if (appt.patientCondition.isNotEmpty)
                      appt.patientCondition.toUpperCase(),
                    if (appt.patientSeverity.isNotEmpty) appt.patientSeverity,
                  ].join('  \u{00B7}  '),
                  initials: appt.patientInitials,
                  isVideo: appt.isVideo,
                  onBack: () => context.safePop(),
                  onVideo: () => _openVideo(appt),
                ),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: streamChatMessages(id),
                    builder: (context, msgSnap) {
                      final messages = msgSnap.data ?? [];
                      if (messages.isEmpty) {
                        return _EmptyChat(patientName: appt.patientName);
                      }
                      // Newest at the bottom; reverse:true keeps the latest
                      // message in view without a manual scroll controller.
                      return ListView.builder(
                        controller: _model.scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final msg = messages[messages.length - 1 - i];
                          final fromDoctor = msg['senderUid'] == uid;
                          return _Bubble(
                            content: (msg['content'] as String?) ?? '',
                            fromMe: fromDoctor,
                            senderName: (msg['senderName'] as String?) ?? '',
                            sentAt: (msg['sentAt'] as Timestamp?)?.toDate(),
                          );
                        },
                      );
                    },
                  ),
                ),
                _Composer(
                  controller: _model.inputController,
                  onSend: () => _send(appt),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.patientName,
    required this.subtitle,
    required this.initials,
    required this.isVideo,
    required this.onBack,
    required this.onVideo,
  });

  final String patientName;
  final String subtitle;
  final String initials;
  final bool isVideo;
  final VoidCallback onBack;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(bottom: BorderSide(color: theme.alternate)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: onBack,
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.secondary.withValues(alpha: 0.20),
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: theme.secondaryText)),
              ],
            ),
          ),
          if (isVideo)
            IconButton(
              tooltip: 'Start video call',
              icon: Icon(Icons.videocam_rounded, color: theme.primary),
              onPressed: onVideo,
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.content,
    required this.fromMe,
    required this.senderName,
    required this.sentAt,
  });

  final String content;
  final bool fromMe;
  final String senderName;
  final DateTime? sentAt;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final time = sentAt != null ? DateFormat('h:mm a').format(sentAt!) : '';
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fromMe ? theme.primary : theme.secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromMe ? 16 : 4),
            bottomRight: Radius.circular(fromMe ? 4 : 16),
          ),
          border: fromMe ? null : Border.all(color: theme.alternate),
        ),
        child: Column(
          crossAxisAlignment:
              fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(content,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.35,
                    color: fromMe ? Colors.white : theme.primaryText)),
            const SizedBox(height: 3),
            Text(time,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: fromMe
                        ? Colors.white.withValues(alpha: 0.8)
                        : theme.secondaryText)),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.patientName});

  final String patientName;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = patientName.isEmpty ? 'your patient' : patientName;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined,
                size: 44, color: theme.secondaryText.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No messages yet.\nSay hello to $name.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: theme.secondaryText)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController? controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(top: BorderSide(color: theme.alternate)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Message your patient\u{2026}',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: theme.secondaryText),
                filled: true,
                fillColor: theme.primaryBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.alternate),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.alternate),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: theme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
