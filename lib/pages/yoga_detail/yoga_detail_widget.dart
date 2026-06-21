import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/wellness_content_catalog.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'yoga_detail_model.dart';
export 'yoga_detail_model.dart';

class YogaDetailWidget extends StatefulWidget {
  const YogaDetailWidget({super.key, this.contentId});

  final String? contentId;

  static String routeName = 'YogaDetail';
  static String routePath = '/yoga-detail';

  @override
  State<YogaDetailWidget> createState() => _YogaDetailWidgetState();
}

class _YogaDetailWidgetState extends State<YogaDetailWidget> {
  late YogaDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  WellnessContent? _content;
  int _currentPoseIndex = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _sessionComplete = false;
  Timer? _timer;
  String _userCondition = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => YogaDetailModel());
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Get user condition + phase for personalization
    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      final user = await getUser(uid);
      if (user != null) {
        _userCondition = user.conditionType;
      }
    }

    // Find content by ID or pick best for user's condition/phase
    if (widget.contentId != null && widget.contentId!.isNotEmpty) {
      _content = WellnessContentCatalog.yogaContents
          .cast<WellnessContent?>()
          .firstWhere((c) => c!.id == widget.contentId, orElse: () => null);
    }

    // Fallback: pick based on condition
    _content ??= _bestYogaForCondition(_userCondition);

    if (_content != null && _content!.poses.isNotEmpty) {
      safeSetState(() {
        _secondsRemaining = _content!.poses.first.durationSecs;
      });
    }
  }

  WellnessContent _bestYogaForCondition(String condition) {
    final yogas = WellnessContentCatalog.yogaContents;
    // Find one matching the condition
    for (final y in yogas) {
      if (y.conditions.contains(condition)) return y;
    }
    // Fallback to first
    return yogas.first;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_content == null || _content!.poses.isEmpty) return;
    safeSetState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 1) {
        safeSetState(() => _secondsRemaining--);
      } else {
        _advancePose();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    safeSetState(() => _isRunning = false);
  }

  void _advancePose() {
    _timer?.cancel();
    final poses = _content!.poses;
    if (_currentPoseIndex < poses.length - 1) {
      safeSetState(() {
        _currentPoseIndex++;
        _secondsRemaining = poses[_currentPoseIndex].durationSecs;
        _isRunning = true;
      });
      _startTimer();
    } else {
      safeSetState(() {
        _isRunning = false;
        _sessionComplete = true;
      });
    }
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_content == null) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Center(
            child: Text('Content not found',
                style: GoogleFonts.poppins(color: theme.primaryText)),
          ),
        ),
      );
    }

    final content = _content!;
    final poses = content.poses;
    final currentPose = poses.isNotEmpty ? poses[_currentPoseIndex] : null;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.safePop(),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: theme.primaryText, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _chip(theme, Icons.timer_outlined, '${content.durationMins} min'),
                  const SizedBox(width: 8),
                  _chip(theme, Icons.fitness_center, content.difficulty),
                  const SizedBox(width: 8),
                  _chip(theme, Icons.format_list_numbered,
                      '${poses.length} poses'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                content.description,
                style: GoogleFonts.inter(
                    fontSize: 14, color: theme.secondaryText, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Timer circle
            if (currentPose != null) ...[
              TweenAnimationBuilder<double>(
                key: ValueKey('$_currentPoseIndex-$_secondsRemaining'),
                tween: Tween(begin: 1.0, end: 1.0),
                duration: Duration.zero,
                builder: (context, _, child) {
                  final progress = poses.isNotEmpty
                      ? _secondsRemaining / currentPose.durationSecs
                      : 1.0;
                  return Column(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                backgroundColor: theme.alternate,
                                valueColor: AlwaysStoppedAnimation(theme.primary),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currentPose.emoji,
                                    style: const TextStyle(fontSize: 40)),
                                const SizedBox(height: 4),
                                Text(_formatTime(_secondsRemaining),
                                    style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primaryText)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(currentPose.name,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText)),
                      Text(
                          'Pose ${_currentPoseIndex + 1} of ${poses.length}',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: theme.secondaryText)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Start / Pause / Complete
              if (_sessionComplete)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.success,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text('Session Complete  \u2714',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                )
              else
                InkWell(
                  onTap: _isRunning ? _pauseTimer : _startTimer,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: content.gradientColors),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      _isRunning ? 'Pause' : 'Start Practice',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 24),

            // Pose list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: poses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final pose = poses[i];
                  final isCurrent = i == _currentPoseIndex;
                  final isDone = i < _currentPoseIndex || _sessionComplete;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.primary.withValues(alpha: 0.1)
                          : theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(color: theme.primary, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(pose.emoji,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(pose.name,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: theme.primaryText)),
                        ),
                        if (isDone)
                          Icon(Icons.check_circle, color: theme.success, size: 20)
                        else
                          Text('${pose.durationSecs}s',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: theme.secondaryText)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(FlutterFlowTheme theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primary),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.primary)),
        ],
      ),
    );
  }
}
