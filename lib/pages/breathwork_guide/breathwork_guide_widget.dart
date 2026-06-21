import 'dart:async';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'breathwork_guide_model.dart';
export 'breathwork_guide_model.dart';

class BreathworkGuideWidget extends StatefulWidget {
  const BreathworkGuideWidget({super.key});

  static String routeName = 'BreathworkGuide';
  static String routePath = '/breathwork';

  @override
  State<BreathworkGuideWidget> createState() => _BreathworkGuideWidgetState();
}

class _BreathworkGuideWidgetState extends State<BreathworkGuideWidget>
    with SingleTickerProviderStateMixin {
  late BreathworkGuideModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s = 19s per cycle
  static const int _inhaleSecs = 4;
  static const int _holdSecs = 7;
  static const int _exhaleSecs = 8;
  static const int _cycleSecs = _inhaleSecs + _holdSecs + _exhaleSecs;

  int _sessionMinutes = 3;
  bool _isRunning = false;
  bool _sessionComplete = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Animation
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BreathworkGuideModel());

    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _cycleSecs),
    );

    _buildAnimation();
  }

  void _buildAnimation() {
    // Inhale: 0 → 4/19 (expand 0.5 → 1.0)
    // Hold:   4/19 → 11/19 (stay 1.0)
    // Exhale: 11/19 → 1.0 (contract 1.0 → 0.5)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: _inhaleSecs.toDouble()),
      TweenSequenceItem(
          tween: ConstantTween(1.0), weight: _holdSecs.toDouble()),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.5)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: _exhaleSecs.toDouble()),
    ]).animate(_animController);
  }

  _BreathPhase get _currentPhase {
    if (!_isRunning && !_sessionComplete) return _BreathPhase.ready;
    if (_sessionComplete) return _BreathPhase.ready;
    final pos = _animController.value;
    final inhaleEnd = _inhaleSecs / _cycleSecs;
    final holdEnd = (_inhaleSecs + _holdSecs) / _cycleSecs;
    if (pos < inhaleEnd) return _BreathPhase.inhale;
    if (pos < holdEnd) return _BreathPhase.hold;
    return _BreathPhase.exhale;
  }

  void _start() {
    safeSetState(() {
      _isRunning = true;
      _sessionComplete = false;
      _elapsedSeconds = 0;
    });
    _animController.repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      if (_elapsedSeconds >= _sessionMinutes * 60) {
        _finish();
      } else {
        safeSetState(() {});
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    _animController.stop();
    safeSetState(() => _isRunning = false);
  }

  void _resume() {
    safeSetState(() => _isRunning = true);
    _animController.repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      if (_elapsedSeconds >= _sessionMinutes * 60) {
        _finish();
      } else {
        safeSetState(() {});
      }
    });
  }

  void _finish() {
    _timer?.cancel();
    _animController.stop();
    _animController.reset();
    safeSetState(() {
      _isRunning = false;
      _sessionComplete = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _model.dispose();
    super.dispose();
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final remaining = (_sessionMinutes * 60) - _elapsedSeconds;

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
                  Text(
                    'Breathwork',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Technique label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '4-7-8 Breathing Technique',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds. This calms the nervous system.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: theme.secondaryText, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Session length chips
            if (!_isRunning && !_sessionComplete)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [3, 5, 10].map((mins) {
                  final selected = _sessionMinutes == mins;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: InkWell(
                      onTap: () => safeSetState(() => _sessionMinutes = mins),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.primary
                              : theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$mins min',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : theme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            if (_isRunning || _sessionComplete) ...[
              Text(_formatTime(remaining.clamp(0, 99999)),
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: theme.secondaryText)),
            ],

            const Spacer(),

            // Breathing circle
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = _isRunning ? _scaleAnimation.value : 0.5;
                final phase = _currentPhase;
                final circleColor = switch (phase) {
                  _BreathPhase.inhale => const Color(0xFFEFA6B3), // pink
                  _BreathPhase.hold => const Color(0xFF9FA8DA), // lavender
                  _BreathPhase.exhale => const Color(0xFF80CBC4), // teal
                  _BreathPhase.ready => theme.primary,
                };
                final phaseLabel = switch (phase) {
                  _BreathPhase.inhale => 'Inhale',
                  _BreathPhase.hold => 'Hold',
                  _BreathPhase.exhale => 'Exhale',
                  _BreathPhase.ready =>
                    _sessionComplete ? 'Complete' : 'Ready',
                };

                return Column(
                  children: [
                    Container(
                      width: 200 * scale,
                      height: 200 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor.withValues(alpha: 0.25),
                        border: Border.all(color: circleColor, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        phaseLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: circleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Phase step indicators
                    if (_isRunning)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _phaseIndicator('Inhale', '4s',
                              phase == _BreathPhase.inhale, theme),
                          const SizedBox(width: 16),
                          _phaseIndicator('Hold', '7s',
                              phase == _BreathPhase.hold, theme),
                          const SizedBox(width: 16),
                          _phaseIndicator('Exhale', '8s',
                              phase == _BreathPhase.exhale, theme),
                        ],
                      ),
                  ],
                );
              },
            ),

            const Spacer(),

            // Start / Pause button
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: InkWell(
                onTap: () {
                  if (_sessionComplete) {
                    safeSetState(() => _sessionComplete = false);
                    _start();
                  } else if (_isRunning) {
                    _pause();
                  } else if (_elapsedSeconds > 0) {
                    _resume();
                  } else {
                    _start();
                  }
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFEFA6B3), Color(0xFF9FA8DA)]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    _sessionComplete
                        ? 'Restart'
                        : _isRunning
                            ? 'Pause'
                            : _elapsedSeconds > 0
                                ? 'Resume'
                                : 'Start',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phaseIndicator(
      String label, String time, bool active, FlutterFlowTheme theme) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? theme.primaryText : theme.secondaryText)),
        Text(time,
            style: GoogleFonts.inter(
                fontSize: 11, color: theme.secondaryText)),
      ],
    );
  }
}

enum _BreathPhase { ready, inhale, hold, exhale }

class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) => builder(context, null);
}
