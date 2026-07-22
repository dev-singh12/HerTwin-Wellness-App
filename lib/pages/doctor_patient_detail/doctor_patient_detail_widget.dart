import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doctor_patient_detail_model.dart';
export 'doctor_patient_detail_model.dart';

/// The clinician's view of one consultation and the patient behind it.
///
/// The patient's chart is read live from `users/{patientUid}/...`. That read
/// only succeeds because the patient granted consent at booking time — the
/// consent document is what `firestore.rules` checks. If the patient revokes
/// it, these sections stop resolving on the next read, by design.
class DoctorPatientDetailWidget extends StatefulWidget {
  const DoctorPatientDetailWidget({super.key, this.appointmentId});

  final String? appointmentId;

  static String routeName = 'DoctorPatientDetail';
  static String routePath = '/clinician/patient';

  @override
  State<DoctorPatientDetailWidget> createState() =>
      _DoctorPatientDetailWidgetState();
}

class _DoctorPatientDetailWidgetState extends State<DoctorPatientDetailWidget> {
  late DoctorPatientDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DoctorPatientDetailModel());
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

  Future<void> _setStatus(AppointmentRecord a, String status) async {
    try {
      await doctorUpdateAppointment(a.id, status: status);
      _toast('Consultation marked $status.');
    } catch (_) {
      _toast('Could not update. Check your connection.');
    }
  }

  Future<void> _openVideo(AppointmentRecord a) async {
    final link = a.meetingLink;
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

  Future<void> _saveClinicalNotes(AppointmentRecord a) async {
    if (_model.saving) return;
    safeSetState(() => _model.saving = true);
    try {
      await doctorUpdateAppointment(
        a.id,
        doctorNotes: _model.notesController?.text.trim(),
        prescriptionText: _model.prescriptionController?.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
      _toast('Notes saved to the consultation record.');
    } catch (_) {
      _toast('Could not save notes. Check your connection.');
    } finally {
      if (mounted) safeSetState(() => _model.saving = false);
    }
  }

  void _openNotesSheet(AppointmentRecord a) {
    if (!_model.seededFromRecord) {
      _model.notesController?.text = a.doctorNotes ?? '';
      _model.prescriptionController?.text = a.prescriptionText ?? '';
      _model.seededFromRecord = true;
    }
    final theme = FlutterFlowTheme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.secondaryBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consultation notes',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText)),
              const SizedBox(height: 4),
              Text('Visible to you and ${a.patientName}.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: theme.secondaryText)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _model.notesController,
                maxLines: 5,
                maxLength: 5000,
                decoration: InputDecoration(
                  labelText: 'Clinical notes',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _model.prescriptionController,
                maxLines: 4,
                maxLength: 2000,
                decoration: InputDecoration(
                  labelText: 'Prescription / plan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _model.saving ? null : () => _saveClinicalNotes(a),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _model.saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Save notes',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final id = widget.appointmentId;

    if (id == null || id.isEmpty) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(title: const Text('Patient')),
        body: const Center(child: Text('No consultation selected.')),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: StreamBuilder<AppointmentRecord>(
          stream: streamAppointment(id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _centered(
                  context, "Couldn't load this consultation.");
            }
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: theme.primary));
            }
            final a = snapshot.data!;
            if (a.patientUid.isEmpty) {
              return _centered(context, 'This consultation no longer exists.');
            }

            return Column(
              children: [
                _TopBar(
                  title: a.patientName.isEmpty ? 'Patient' : a.patientName,
                  subtitle: [
                    if (a.patientAge > 0) '${a.patientAge} yrs',
                    if (a.patientCondition.isNotEmpty)
                      a.patientCondition.toUpperCase(),
                    if (a.patientSeverity.isNotEmpty) a.patientSeverity,
                  ].join('  \u{00B7}  '),
                  onBack: () => context.safePop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _ConsultationCard(appointment: a),
                      const SizedBox(height: 14),
                      _SectionTitle('Clinical snapshot'),
                      _AssessmentSection(patientUid: a.patientUid),
                      const SizedBox(height: 14),
                      _SectionTitle('Cycle'),
                      _CycleSection(patientUid: a.patientUid),
                      const SizedBox(height: 14),
                      _SectionTitle('Recent symptoms'),
                      _SymptomsSection(patientUid: a.patientUid),
                      const SizedBox(height: 14),
                      _SectionTitle('Habit adherence (last 14 days)'),
                      _AdherenceSection(patientUid: a.patientUid),
                      if ((a.doctorNotes ?? '').isNotEmpty ||
                          (a.prescriptionText ?? '').isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SectionTitle('Your notes'),
                        _NotesCard(appointment: a),
                      ],
                      const SizedBox(height: 20),
                      _ActionBar(
                        appointment: a,
                        onStart: () => _setStatus(a, 'ongoing'),
                        onComplete: () => _setStatus(a, 'completed'),
                        onNotes: () => _openNotesSheet(a),
                        onVideo: () => _openVideo(a),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _centered(BuildContext context, String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FlutterFlowTheme.of(context).secondaryText)),
        ),
      );
}

// ---------------------------------------------------------------------------
// Chrome
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 0, 8),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
      ),
      child: child,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: FlutterFlowTheme.of(context).secondaryText)),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value, {this.emphasise = false});

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, color: theme.secondaryText)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        emphasise ? FontWeight.w600 : FontWeight.w500,
                    color: theme.primaryText)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.appointment});

  final AppointmentRecord appointment;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KeyValue('Type', a.isVideo ? 'Video consultation' : 'Chat consultation'),
          _KeyValue(
              'Scheduled',
              a.scheduledAt != null
                  ? DateFormat('EEE d MMM y, h:mm a').format(a.scheduledAt!)
                  : 'Not scheduled'),
          _KeyValue('Status', a.status, emphasise: true),
          _KeyValue('Fee',
              a.priceRs == 0 ? 'Free consultation' : '\u{20B9}${a.priceRs} (${a.paymentStatus})'),
          if ((a.reasonForVisit ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Reason for visit',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).secondaryText)),
            const SizedBox(height: 2),
            Text(a.reasonForVisit!,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: FlutterFlowTheme.of(context).primaryText)),
          ],
        ],
      ),
    );
  }
}

class _AssessmentSection extends StatelessWidget {
  const _AssessmentSection({required this.patientUid});

  final String patientUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OnboardingAssessmentRecord?>(
      stream: streamLatestAssessment(patientUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _Empty('Assessment not shared.');
        }
        if (!snapshot.hasData) {
          return const _Empty('Loading assessment\u{2026}');
        }
        final a = snapshot.data;
        if (a == null) {
          return const _Empty('This patient has not completed an assessment.');
        }
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KeyValue('Condition', a.diagnosisLabel.isEmpty
                  ? a.conditionType.toUpperCase()
                  : a.diagnosisLabel, emphasise: true),
              _KeyValue('Severity', a.severityLevel),
              _KeyValue('Assessment score', '${a.totalScore}'),
              _KeyValue('Care plan', a.carePlanType),
              if (a.createdAt != null)
                _KeyValue('Taken',
                    DateFormat('d MMM y').format(a.createdAt!)),
            ],
          ),
        );
      },
    );
  }
}

class _CycleSection extends StatelessWidget {
  const _CycleSection({required this.patientUid});

  final String patientUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CyclesRecord>>(
      stream: streamCycles(patientUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _Empty('Cycle data not shared.');
        }
        if (!snapshot.hasData) {
          return const _Empty('Loading cycle data\u{2026}');
        }
        final status = CycleEngine.compute(snapshot.data!);
        if (!status.hasData) {
          return const _Empty('No cycle logs yet.');
        }
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KeyValue('Current phase', status.phase.label, emphasise: true),
              _KeyValue('Cycle day', 'Day ${status.cycleDay}'),
              _KeyValue('Average length', '${status.cycleLength} days'),
              _KeyValue('Period length', '${status.periodLength} days'),
              _KeyValue('Next period',
                  DateFormat('d MMM').format(status.nextPeriodDate)),
              _KeyValue('Logs recorded', '${snapshot.data!.length}'),
            ],
          ),
        );
      },
    );
  }
}

class _SymptomsSection extends StatelessWidget {
  const _SymptomsSection({required this.patientUid});

  final String patientUid;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return StreamBuilder<List<SymptomsRecord>>(
      stream: streamSymptoms(patientUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _Empty('Symptom logs not shared.');
        }
        if (!snapshot.hasData) {
          return const _Empty('Loading symptoms\u{2026}');
        }
        final logs = snapshot.data!.take(6).toList();
        if (logs.isEmpty) {
          return const _Empty('No symptoms logged yet.');
        }
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in logs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 62,
                        child: Text(
                            s.date != null
                                ? DateFormat('d MMM').format(s.date!)
                                : '\u{2014}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: theme.secondaryText)),
                      ),
                      Expanded(
                        child: Text(
                            s.symptoms.isEmpty
                                ? (s.notes.isEmpty ? 'No detail' : s.notes)
                                : s.symptoms.join(', '),
                            style: GoogleFonts.inter(
                                fontSize: 13, color: theme.primaryText)),
                      ),
                      if (s.severity != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${s.severity}/5',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primary)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AdherenceSection extends StatelessWidget {
  const _AdherenceSection({required this.patientUid});

  final String patientUid;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return StreamBuilder<List<HabitLogRecord>>(
      stream: streamRecentHabitLogs(patientUid, 14),
      builder: (context, logSnap) {
        if (logSnap.hasError) {
          return const _Empty('Habit data not shared.');
        }
        if (!logSnap.hasData) {
          return const _Empty('Loading adherence\u{2026}');
        }
        return StreamBuilder<List<HealthHabitRecord>>(
          stream: streamHabits(patientUid),
          builder: (context, habitSnap) {
            if (!habitSnap.hasData) {
              return const _Empty('Loading adherence\u{2026}');
            }
            final habits = habitSnap.data!;
            final logs = logSnap.data!;
            if (habits.isEmpty) {
              return const _Empty('No habit plan assigned yet.');
            }

            // Adherence = completed ticks / (active habits x days logged).
            var completed = 0;
            for (final log in logs) {
              completed +=
                  log.completedHabits.values.where((v) => v).length;
            }
            final possible = habits.length * 14;
            final pct = possible == 0
                ? 0
                : ((completed / possible) * 100).clamp(0, 100).round();

            return _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$pct%',
                          style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryText)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            '$completed of $possible planned actions completed',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: theme.secondaryText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      backgroundColor: theme.alternate,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Active plan',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: theme.secondaryText)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final h in habits)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.primaryBackground,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: theme.alternate),
                          ),
                          child: Text(h.title,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: theme.primaryText)),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.appointment});

  final AppointmentRecord appointment;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((appointment.doctorNotes ?? '').isNotEmpty) ...[
            Text('Clinical notes',
                style: GoogleFonts.inter(
                    fontSize: 12, color: theme.secondaryText)),
            const SizedBox(height: 2),
            Text(appointment.doctorNotes!,
                style: GoogleFonts.inter(
                    fontSize: 13, color: theme.primaryText)),
          ],
          if ((appointment.prescriptionText ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Prescription / plan',
                style: GoogleFonts.inter(
                    fontSize: 12, color: theme.secondaryText)),
            const SizedBox(height: 2),
            Text(appointment.prescriptionText!,
                style: GoogleFonts.inter(
                    fontSize: 13, color: theme.primaryText)),
          ],
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.appointment,
    required this.onStart,
    required this.onComplete,
    required this.onNotes,
    required this.onVideo,
  });

  final AppointmentRecord appointment;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onNotes;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final a = appointment;
    final done = a.status == 'completed' || a.status == 'cancelled';

    return Column(
      children: [
        if (!done)
          Row(
            children: [
              if (a.status == 'booked')
                Expanded(
                  child: _ActionButton(
                    label: 'Start consultation',
                    icon: Icons.play_arrow_rounded,
                    filled: true,
                    onTap: onStart,
                  ),
                ),
              if (a.status == 'ongoing') ...[
                if (a.isVideo)
                  Expanded(
                    child: _ActionButton(
                      label: 'Join video',
                      icon: Icons.videocam_rounded,
                      filled: true,
                      onTap: onVideo,
                    ),
                  ),
                if (a.isVideo) const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Mark complete',
                    icon: Icons.check_rounded,
                    filled: !a.isVideo,
                    onTap: onComplete,
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _ActionButton(
            label: (a.doctorNotes ?? '').isEmpty
                ? 'Write consultation notes'
                : 'Edit consultation notes',
            icon: Icons.edit_note_rounded,
            filled: false,
            onTap: onNotes,
          ),
        ),
        if (done) ...[
          const SizedBox(height: 10),
          Text('This consultation is ${a.status}.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: theme.secondaryText)),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon,
            size: 18, color: filled ? Colors.white : theme.primaryText),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : theme.primaryText)),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              filled ? theme.primary : theme.secondaryBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
                color: filled ? theme.primary : theme.alternate),
          ),
        ),
      ),
    );
  }
}
