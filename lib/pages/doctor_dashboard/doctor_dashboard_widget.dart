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
/// Every number and row here comes from live Firestore: appointments booked
/// against this doctor's uid. There is no seeded or placeholder state — an
/// empty queue renders as an empty queue.
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

  List<AppointmentRecord> _filter(List<AppointmentRecord> all) {
    switch (_model.selectedFilter) {
      case 'today':
        return all.where((a) => _isToday(a.scheduledAt) && a.isActive).toList();
      case 'upcoming':
        return all
            .where((a) =>
                a.isActive &&
                a.scheduledAt != null &&
                a.scheduledAt!.isAfter(DateTime.now()) &&
                !_isToday(a.scheduledAt))
            .toList();
      case 'completed':
        return all.where((a) => a.status == 'completed').toList();
      default:
        return all;
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign out?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('You will need to sign in again to see your queue.',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign out',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).error))),
        ],
      ),
    );
    if (confirmed != true) return;
    RoleManager.instance.clear();
    await AuthManager.instance.signOut();
  }

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
            final todayCount =
                all.where((a) => _isToday(a.scheduledAt) && a.isActive).length;
            final upcomingCount = all
                .where((a) =>
                    a.isActive &&
                    a.scheduledAt != null &&
                    a.scheduledAt!.isAfter(DateTime.now()))
                .length;
            final completedCount =
                all.where((a) => a.status == 'completed').length;
            final patientCount =
                all.map((a) => a.patientUid).toSet().length;

            final visible = _filter(all);

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
                                label: 'Today',
                                value: '$todayCount',
                                icon: Icons.today_rounded,
                                tint: theme.primary)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                label: 'Upcoming',
                                value: '$upcomingCount',
                                icon: Icons.schedule_rounded,
                                tint: theme.secondary)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                label: 'Done',
                                value: '$completedCount',
                                icon: Icons.check_circle_outline_rounded,
                                tint: const Color(0xFF7BC47F))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                label: 'Patients',
                                value: '$patientCount',
                                icon: Icons.people_outline_rounded,
                                tint: const Color(0xFFB39DDB))),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      children: [
                        _FilterChip(
                            label: 'Today',
                            active: _model.selectedFilter == 'today',
                            onTap: () => safeSetState(
                                () => _model.selectedFilter = 'today')),
                        const SizedBox(width: 8),
                        _FilterChip(
                            label: 'Upcoming',
                            active: _model.selectedFilter == 'upcoming',
                            onTap: () => safeSetState(
                                () => _model.selectedFilter = 'upcoming')),
                        const SizedBox(width: 8),
                        _FilterChip(
                            label: 'Completed',
                            active: _model.selectedFilter == 'completed',
                            onTap: () => safeSetState(
                                () => _model.selectedFilter = 'completed')),
                      ],
                    ),
                  ),
                ),
                if (visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyQueue(filter: _model.selectedFilter),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverList.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _AppointmentCard(
                        appointment: visible[i],
                        onTap: () => context.pushNamed(
                          DoctorPatientDetailWidget.routeName,
                          extra: {'appointmentId': visible[i].id},
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
                    errorWidget: (_, __, ___) => Center(
                      child: Text(_initials,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText)),
                    ),
                  )
                : Center(
                    child: Text(_initials,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText)),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
              style: GoogleFonts.inter(
                  fontSize: 11, color: theme.secondaryText)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.primary : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(50),
          border:
              Border.all(color: active ? theme.primary : theme.alternate),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : theme.secondaryText)),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.onTap});

  final AppointmentRecord appointment;
  final VoidCallback onTap;

  static const _statusColors = <String, Color>{
    'booked': Color(0xFF9FA8DA),
    'ongoing': Color(0xFFF9CF58),
    'completed': Color(0xFF7BC47F),
    'cancelled': Color(0xFFBDBDBD),
  };

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final a = appointment;
    final statusColor = _statusColors[a.status] ?? theme.secondaryText;
    final time = a.scheduledAt != null
        ? DateFormat('d MMM, h:mm a').format(a.scheduledAt!)
        : 'Not scheduled';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.secondary.withValues(alpha: 0.20),
                  ),
                  alignment: Alignment.center,
                  child: Text(a.patientInitials,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          a.patientName.isEmpty
                              ? 'Patient'
                              : a.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                              a.isVideo
                                  ? Icons.videocam_outlined
                                  : Icons.chat_bubble_outline,
                              size: 13,
                              color: theme.secondaryText),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(time,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: theme.secondaryText)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(a.status,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ],
            ),
            if (a.patientCondition.isNotEmpty ||
                a.patientSeverity.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (a.patientCondition.isNotEmpty)
                    _Tag(
                        text: a.patientCondition.toUpperCase(),
                        color: theme.primary),
                  if (a.patientSeverity.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _Tag(text: a.patientSeverity, color: theme.secondary),
                  ],
                  const Spacer(),
                  if (a.patientAge > 0)
                    Text('${a.patientAge} yrs',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: theme.secondaryText)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final message = switch (filter) {
      'today' => 'No consultations scheduled for today.',
      'upcoming' => 'Nothing booked ahead yet.',
      'completed' => 'No completed consultations yet.',
      _ => 'Nothing here yet.',
    };
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_outlined,
              size: 48, color: theme.secondaryText.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: theme.secondaryText)),
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
            Text("Couldn't load your queue.",
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
