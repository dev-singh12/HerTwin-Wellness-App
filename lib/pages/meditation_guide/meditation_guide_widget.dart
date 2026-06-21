import 'dart:async';

import '/business/wellness_content_catalog.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'meditation_guide_model.dart';
export 'meditation_guide_model.dart';

class MeditationGuideWidget extends StatefulWidget {
  const MeditationGuideWidget({super.key, this.contentId});

  final String? contentId;

  static String routeName = 'MeditationGuide';
  static String routePath = '/meditation-guide';

  @override
  State<MeditationGuideWidget> createState() => _MeditationGuideWidgetState();
}

class _MeditationGuideWidgetState extends State<MeditationGuideWidget>
    with SingleTickerProviderStateMixin {
  late MeditationGuideModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  WellnessContent? _content;
  int _currentStep = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _sessionComplete = false;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MeditationGuideModel());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulseController);

    _loadContent();
  }

  void _loadContent() {
    final id = widget.contentId;
    if (id != null && id.isNotEmpty) {
      _content = WellnessContentCatalog.meditationContents
          .cast<WellnessContent?>()
          .firstWhere((c) => c!.id == id, orElse: () => null);
    }
    _content ??= WellnessContentCatalog.meditationContents.isNotEmpty
        ? WellnessContentCatalog.meditationContents.first
        : null;

    if (_content != null && _content!.poses.isNotEmpty) {
      safeSetState(() => _secondsRemaining = _content!.poses.first.durationSecs);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _start() {
    if (_content == null || _content!.poses.isEmpty) return;
    safeSetState(() => _isRunning = true);
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 1) {
        safeSetState(() => _secondsRemaining--);
      } else {
        _advanceStep();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    _pulseController.stop();
    safeSetState(() => _isRunning = false);
  }

  void _advanceStep() {
    if (_content == null) return;
    if (_currentStep < _content!.poses.length - 1) {
      safeSetState(() {
        _currentStep++;
        _secondsRemaining = _content!.poses[_currentStep].durationSecs;
      });
    } else {
      _timer?.cancel();
      _pulseController.stop();
      safeSetState(() {
        _isRunning = false;
        _sessionComplete = true;
      });
    }
  }

  void _restart() {
    safeSetState(() {
      _currentStep = 0;
      _secondsRemaining = _content!.poses.first.durationSecs;
      _isRunning = false;
      _sessionComplete = false;
    });
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_content == null || _content!.poses.isEmpty) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.primaryText),
            onPressed: () => context.safePop(),
          ),
        ),
        body: Center(child: Text('Meditation not found.', style: GoogleFonts.inter(color: theme.secondaryText))),
      );
    }

    final step = _content!.poses[_currentStep];
    final progress = _content!.poses.isEmpty
        ? 0.0
        : (_currentStep + 1) / _content!.poses.length;

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white70),
                      onPressed: () => context.safePop(),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentStep + 1} / ${_content!.poses.length}',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                    ),
                  ],
                ),
              ),

              // ── Progress bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Title ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _content!.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_content!.durationMins} min',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
              ),

              const Spacer(flex: 1),

              // ── Animated Circle + Step ──
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = _isRunning ? _pulseAnimation.value : 0.85;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.primary.withAlpha(80),
                            theme.primary.withAlpha(30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primary.withAlpha(40),
                          ),
                          child: Center(
                            child: _sessionComplete
                                ? Icon(Icons.check_rounded, size: 56, color: theme.success)
                                : Text(
                                    step.emoji,
                                    style: const TextStyle(fontSize: 48),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Step name ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _sessionComplete ? 'Session Complete' : step.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!_sessionComplete)
                Text(
                  _formatSeconds(_secondsRemaining),
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white70),
                ),

              if (_sessionComplete) ...[
                const SizedBox(height: 8),
                Text(
                  'Take a moment to notice how you feel.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                ),
              ],

              const Spacer(flex: 2),

              // ── Controls ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: _sessionComplete
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _restart,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Restart', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.safePop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Done', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          if (_isRunning)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _advanceStep,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text('Skip', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          if (_isRunning) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isRunning ? _pause : _start,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                _isRunning ? 'Pause' : (_currentStep == 0 ? 'Begin' : 'Resume'),
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
