import '/auth/auth_manager.dart';
import '/auth/role_manager.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_dashboard_model.dart';
export 'doctor_dashboard_model.dart';

/// The clinician's home screen.
///
/// Everything here is live: appointments booked against this doctor's uid. The
/// screen is deliberately patient-first — a doctor thinks in patients, not
/// calendar slots — with a Schedule view behind it.
///
/// Bucketing matters. An earlier version filtered to Today/Upcoming/Completed,
/// which meant a booking that was made, whose time passed, and which was never
/// marked complete fell through every filter and became invisible. Here such
/// bookings surface under "Needs review", so a patient can never silently
/// disappear from their own doctor's queue.
class DoctorDashboardWidget extends StatefulWidget {
  const DoctorDashboardWidget({super.key});

  static String routeName = 'DoctorDashboard';
  static String routePath = '/clinician/dashboard';

  @override
  State<DoctorDashboardWidget> createState() => _DoctorDashboardWidgetState();
}

class _DoctorDashboardWidgetState extends State<DoctorDashboardWidget> {
  late DoctorDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DoctorDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// One representative appointment per patient — the soonest active one, or
  /// failing that the most recent — so the Patients list shows each person
  /// once with their most relevant visit.
  List<AppointmentRecord> _latestPerPatient(List<AppointmentRecord> all) {
    final byPatient = <String, AppointmentRecord>{};
    for (final a in all) {
      final existing = byPatient[a.patientUid];
      if (existing == null) {
        byPatient[a.patientUid] = a;
        continue;
      }
      // Prefer an active appointment; among same activeness, prefer the one
      // scheduled soonest to now.
      final aScore = _relevance(a);
      final eScore = _relevance(existing);
      if (aScore > eScore) byPatient[a.patientUid] = a;
    }
    final list = byPatient.values.toList()
      ..sort((a, b) => _relevance(b).compareTo(_relevance(a)));
    return list;
  }

  double _relevance(AppointmentRecord a) {
    // Active outranks closed; nearer-to-now outranks distant.
    final base = a.isActive ? 1e12 : 0.0;
    final t = a.scheduledAt?.millisecondsSinceEpoch.toDouble() ?? 0;
    return base - (DateTime.now().millisecondsSinceEpoch - t).abs();
  }

  ({
    List<AppointmentRecord> review,
    List<AppointmentRecord> today,
    List<AppointmentRecord> upcoming,
    List<AppointmentRecord> completed,
  }) _buckets(List<AppointmentRecord> all) {
    final now = DateTime.now();
    final review = <AppointmentRecord>[];
    final today = <AppointmentRecord>[];
    final upcoming = <AppointmentRecord>[];
    final completed = <AppointmentRecord>[];

    for (final a in all) {
      if (a.status == 'completed' || a.status == 'cancelled') {
        completed.add(a);
      } else if (_isToday(a.scheduledAt)) {
        today.add(a);
      } else if (a.scheduledAt != null && a.scheduledAt!.isAfter(now)) {
        upcoming.add(a);
      } else {
        // Active but its slot is in the past (or unscheduled) — needs a
        // decision, and must never be hidden.
        review.add(a);
      }
    }

    int bySoonest(AppointmentRecord a, AppointmentRecord b) =>
        (a.scheduledAt ?? DateTime(2100))
            .compareTo(b.scheduledAt ?? DateTime(2100));
    review.sort(bySoonest);
    today.sort(bySoonest);
    upcoming.sort(bySoonest);
    completed.sort((a, b) => (b.scheduledAt ?? DateTime(1970))
        .compareTo(a.scheduledAt ?? DateTime(1970)));

    return (
      review: review,
      today: today,
      upcoming: upcoming,
      completed: completed
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign out?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('You will need to sign in again to see your patients.',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign out',
                  style: TextStyle(color: FlutterFlowTheme.of(context).error))),
        ],
      ),
    );
    if (confirmed != true) return;
    RoleManager.instance.clear();
    await AuthManager.instance.signOut();
  }

  void _openChart(AppointmentRecord a) => context.pushNamed(
        DoctorPatientDetailWidget.routeName,
        extra: {'appointmentId': a.id},
      );

  void _openChat(AppointmentRecord a) => context.pushNamed(
        DoctorChatWidget.routeName,
        extra: {'appointmentId': a.id},
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final uid = AuthManager.instance.currentUid;
    final profile = RoleManager.instance.profile;

    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: StreamBuilder<List<AppointmentRecord>>(
          stream: streamDoctorAppointments(uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorState(onRetry: () => safeSetState(() {}));
            }
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: theme.primary));
            }

            final all = snapshot.data!;
            final buckets = _buckets(all);
            final patients = _latestPerPatient(all);
            final patientCount = patients.length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    doctorName: profile?.name ?? 'Doctor',
                    photoUrl: profile?.photoUrl ?? '',
                    specialty: profile?.specialty ?? '',
                    onSignOut: _signOut,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                            child: _StatCard(
                                label: 'Patients',
                                value: '$patientCount',
                                icon: Icons.people_outline_rounded,
                                tint: const Color(0xFFB39DDB))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                label: 'Today',
                                value: '${buckets.today.length}',
                                icon: Icons.today_rounded,
                                tint: theme.primary)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                label: 'Upcoming',
                                value: '${buckets.upcoming.length}',
                                icon: Icons.schedule_rounded,
                                tint: theme.secondary)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                label: 'To review',
                                value: '${buckets.review.length}',
                                icon: Icons.error_outline_rounded,
                                tint: const Color(0xFFE8A13A))),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    child: _Segmented(
                      value: _model.segment,
                      onChanged: (s) =>
                          safeSetState(() => _model.segment = s),
                    ),
                  ),
                ),
                if (all.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      icon: Icons.people_outline_rounded,
                      message:
                          'No patients yet.\nBookings made with you appear here.',
                    ),
                  )
                else if (_model.segment == 'patients')
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverList.separated(
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _PatientCard(
                        appointment: patients[i],
                        onChart: () => _openChart(patients[i]),
                        onChat: () => _openChat(patients[i]),
                      ),
                    ),
                  )
                else
                  ..._scheduleSlivers(buckets),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _scheduleSlivers(
    ({
      List<AppointmentRecord> review,
      List<AppointmentRecord> today,
      List<AppointmentRecord> upcoming,
      List<AppointmentRecord> completed,
    }) b,
  ) {
    final sections = <Widget>[];

    void addSection(String title, Color tint, List<AppointmentRecord> items) {
      if (items.isEmpty) return;
      sections.add(SliverToBoxAdapter(
        child: _BucketHeader(title: title, count: items.length, tint: tint),
      ));
      sections.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _AppointmentRow(
            appointment: items[i],
            onChart: () => _openChart(items[i]),
            onChat: () => _openChat(items[i]),
          ),
        ),
      ));
    }

    addSection('Needs review', const Color(0xFFE8A13A), b.review);
    addSection('Today', FlutterFlowTheme.of(context).primary, b.today);
    addSection('Upcoming', FlutterFlowTheme.of(context).secondary, b.upcoming);
    addSection('Past & completed', const Color(0xFF9E9E9E), b.completed);

    sections.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
    return sections;
  }
}

// ---------------------------------------------------------------------------
// Header + stats
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.doctorName,
    required this.photoUrl,
    required this.specialty,
    required this.onSignOut,
  });

  final String doctorName;
  final String photoUrl;
  final String specialty;
  final VoidCallback onSignOut;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _initials {
    final parts = doctorName
        .replaceAll('Dr.', '')
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return 'D';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary.withValues(alpha: 0.18),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _initialsBadge(theme),
                  )
                : _initialsBadge(theme),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: theme.secondaryText)),
                Text(doctorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText)),
                if (specialty.isNotEmpty)
                  Text(specialty,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: theme.secondaryText)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: Icon(Icons.logout_rounded,
                size: 20, color: theme.secondaryText),
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }

  Widget _initialsBadge(FlutterFlowTheme theme) => Center(
        child: Text(_initials,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.primaryText)),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: tint),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 10.5, color: theme.secondaryText)),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget seg(String key, String label, IconData icon) {
      final active = value == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? theme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: active ? Colors.white : theme.secondaryText),
                const SizedBox(width: 6),
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : theme.secondaryText)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          seg('patients', 'Patients', Icons.people_alt_rounded),
          seg('schedule', 'Schedule', Icons.event_note_rounded),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Patients tab
// ---------------------------------------------------------------------------

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.appointment,
    required this.onChart,
    required this.onChat,
  });

  final AppointmentRecord appointment;
  final VoidCallback onChart;
  final VoidCallback onChat;

  Color _scoreColor(int score) {
    if (score >= 70) return const Color(0xFF7BC47F);
    if (score >= 45) return const Color(0xFFE8A13A);
    return const Color(0xFFE0736F);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final a = appointment;
    final when = a.scheduledAt != null
        ? DateFormat('d MMM, h:mm a').format(a.scheduledAt!)
        : 'Not scheduled';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vitality score ring — the single most useful at-a-glance
              // health signal, so it leads.
              _ScoreRing(
                score: a.patientScore,
                color: _scoreColor(a.patientScore),
                initials: a.patientInitials,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.patientName.isEmpty ? 'Patient' : a.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (a.patientCondition.isNotEmpty)
                          _Tag(
                              text: a.patientCondition.toUpperCase(),
                              color: theme.primary),
                        if (a.patientSeverity.isNotEmpty)
                          _Tag(
                              text: a.patientSeverity,
                              color: theme.secondary),
                        if (a.hasAge)
                          _Tag(text: a.ageLabel, color: theme.secondaryText),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusPill(status: a.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(a.isVideo ? Icons.videocam_outlined : Icons.chat_bubble_outline,
                  size: 14, color: theme.secondaryText),
              const SizedBox(width: 5),
              Expanded(
                child: Text(when,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: theme.secondaryText)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: 'View chart',
                  icon: Icons.assignment_outlined,
                  filled: false,
                  onTap: onChart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardButton(
                  label: 'Message',
                  icon: Icons.forum_outlined,
                  filled: true,
                  onTap: onChat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.color,
    required this.initials,
  });

  final int score;
  final Color color;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: (score.clamp(0, 100)) / 100,
              strokeWidth: 4,
              backgroundColor: theme.alternate,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (score > 0)
            Text('$score',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText))
          else
            Text(initials,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule tab
// ---------------------------------------------------------------------------

class _BucketHeader extends StatelessWidget {
  const _BucketHeader({
    required this.title,
    required this.count,
    required this.tint,
  });

  final String title;
  final int count;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText)),
          const SizedBox(width: 6),
          Text('$count',
              style: GoogleFonts.inter(
                  fontSize: 12, color: theme.secondaryText)),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.appointment,
    required this.onChart,
    required this.onChat,
  });

  final AppointmentRecord appointment;
  final VoidCallback onChart;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final a = appointment;
    final when = a.scheduledAt != null
        ? DateFormat('EEE d MMM, h:mm a').format(a.scheduledAt!)
        : 'Not scheduled';

    return InkWell(
      onTap: onChart,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.secondary.withValues(alpha: 0.18),
              ),
              alignment: Alignment.center,
              child: Text(a.patientInitials,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.patientName.isEmpty ? 'Patient' : a.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                          a.isVideo
                              ? Icons.videocam_outlined
                              : Icons.chat_bubble_outline,
                          size: 12,
                          color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(when,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 11.5, color: theme.secondaryText)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Message',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.forum_outlined, size: 20, color: theme.primary),
              onPressed: onChat,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small shared widgets
// ---------------------------------------------------------------------------

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  static const _colors = <String, Color>{
    'booked': Color(0xFF9FA8DA),
    'ongoing': Color(0xFFE8A13A),
    'completed': Color(0xFF7BC47F),
    'cancelled': Color(0xFFBDBDBD),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? FlutterFlowTheme.of(context).secondaryText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(status,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
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
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon,
            size: 16, color: filled ? Colors.white : theme.primaryText),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : theme.primaryText)),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? theme.primary : theme.secondaryBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: filled ? theme.primary : theme.alternate),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: theme.secondaryText.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: theme.secondaryText)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 44, color: theme.secondaryText.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text("Couldn't load your patients.",
                style: GoogleFonts.inter(
                    fontSize: 14, color: theme.secondaryText)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
