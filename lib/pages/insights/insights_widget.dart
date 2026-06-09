import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'insights_model.dart';
export 'insights_model.dart';

/// One labelled distribution row (mood or symptom).
class _DistRow {
  const _DistRow(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

class InsightsWidget extends StatefulWidget {
  const InsightsWidget({super.key});

  static String routeName = 'Insights';
  static String routePath = '/insights';

  @override
  State<InsightsWidget> createState() => _InsightsWidgetState();
}

class _InsightsWidgetState extends State<InsightsWidget> {
  late InsightsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<List<CyclesRecord>>? _cyclesSub;
  StreamSubscription<List<MoodsRecord>>? _moodsSub;
  StreamSubscription<List<SymptomsRecord>>? _symptomsSub;

  List<CyclesRecord> _cycles = const [];
  List<MoodsRecord> _moods = const [];
  List<SymptomsRecord> _symptoms = const [];
  CycleStatus _status = CycleEngine.compute(const []);

  static const _moodMeta = <String, String>{
    'great': 'Joyful',
    'good': 'Content',
    'okay': 'Peaceful',
    'low': 'Tender',
    'terrible': 'Drained',
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InsightsModel());

    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      _cyclesSub = streamCycles(uid).listen((c) {
        if (mounted) {
          safeSetState(() {
            _cycles = c;
            _status = CycleEngine.compute(c);
          });
        }
      });
      _moodsSub = streamMoods(uid).listen((m) {
        if (mounted) safeSetState(() => _moods = m);
      });
      _symptomsSub = streamSymptoms(uid).listen((s) {
        if (mounted) safeSetState(() => _symptoms = s);
      });
    }
  }

  @override
  void dispose() {
    _cyclesSub?.cancel();
    _moodsSub?.cancel();
    _symptomsSub?.cancel();
    _model.dispose();
    super.dispose();
  }

  // ---- analytics --------------------------------------------------------

  /// Sorted (ascending) period start dates that were actually logged.
  List<DateTime> get _starts => _cycles
      .map((c) => c.startDate)
      .whereType<DateTime>()
      .toList()
    ..sort();

  /// Gaps in days between consecutive logged period starts.
  List<int> get _gaps {
    final s = _starts;
    final out = <int>[];
    for (var i = 1; i < s.length; i++) {
      out.add(s[i].difference(s[i - 1]).inDays);
    }
    return out;
  }

  /// 0-100 regularity score from how consistent the gaps are.
  int get _regularityPct {
    final gaps = _gaps;
    if (gaps.length < 2) return 0;
    final mean = gaps.reduce((a, b) => a + b) / gaps.length;
    final variance =
        gaps.map((g) => (g - mean) * (g - mean)).reduce((a, b) => a + b) /
            gaps.length;
    var x = variance <= 0 ? 0.0 : variance;
    // Newton sqrt.
    if (x > 0) {
      var prev = 0.0;
      while ((x - prev).abs() > 1e-6) {
        prev = x;
        x = (x + variance / x) / 2;
      }
    }
    final stdDev = variance <= 0 ? 0.0 : x;
    return ((1 - (stdDev / 7)).clamp(0.0, 1.0) * 100).round();
  }

  int get _avgPeriodLength {
    final lengths = _cycles
        .map((c) => c.periodLength)
        .whereType<int>()
        .where((v) => v > 0)
        .toList();
    if (lengths.isEmpty) return _status.periodLength;
    return (lengths.reduce((a, b) => a + b) / lengths.length).round();
  }

  /// Last up-to-6 cycle-length gaps with short labels (C1, C2, …).
  ({List<double> values, List<String> labels}) get _cycleTrend {
    final gaps = _gaps;
    final take = gaps.length > 6 ? gaps.sublist(gaps.length - 6) : gaps;
    final values = take.map((g) => g.toDouble()).toList();
    final labels =
        List.generate(take.length, (i) => 'C${gaps.length - take.length + i + 1}');
    return (values: values, labels: labels);
  }

  List<_DistRow> _moodDistribution(FlutterFlowTheme theme) {
    final counts = <String, int>{};
    for (final m in _moods) {
      if (m.mood.isEmpty) continue;
      counts[m.mood] = (counts[m.mood] ?? 0) + 1;
    }
    final colors = <String, Color>{
      'great': theme.success,
      'good': theme.secondary,
      'okay': theme.primary,
      'low': theme.warning,
      'terrible': theme.error,
    };
    final rows = <_DistRow>[];
    for (final key in _moodMeta.keys) {
      final count = counts[key] ?? 0;
      if (count == 0) continue;
      rows.add(_DistRow(_moodMeta[key]!, count, colors[key] ?? theme.primary));
    }
    rows.sort((a, b) => b.count.compareTo(a.count));
    return rows;
  }

  List<_DistRow> _topSymptoms(FlutterFlowTheme theme) {
    final counts = <String, int>{};
    void add(Iterable<String> list) {
      for (final s in list) {
        final key = s.trim();
        if (key.isEmpty) continue;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    for (final s in _symptoms) {
      add(s.symptoms);
    }
    for (final c in _cycles) {
      add(c.symptoms);
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final palette = [
      theme.primary,
      theme.secondary,
      theme.warning,
      theme.success,
      theme.error,
    ];
    return entries.take(5).toList().asMap().entries.map((e) {
      final label = e.value.key;
      final pretty = label.isEmpty
          ? label
          : label[0].toUpperCase() + label.substring(1);
      return _DistRow(pretty, e.value.value, palette[e.key % palette.length]);
    }).toList();
  }

  // ---- UI ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final trend = _cycleTrend;
    final moods = _moodDistribution(theme);
    final symptoms = _topSymptoms(theme);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () => context.safePop(),
                      child: Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            color: theme.primaryText, size: 22.0),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Insights',
                            style: theme.headlineSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold),
                              letterSpacing: 0.0,
                            )),
                        Text('Your patterns over time',
                            style: theme.bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Metric cards
                Row(
                  children: [
                    _metricCard(theme, '${_status.cycleLength}',
                        'Avg cycle (days)', theme.primary),
                    const SizedBox(width: 12.0),
                    _metricCard(theme, '$_avgPeriodLength',
                        'Avg period (days)', theme.secondary),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    _metricCard(
                        theme,
                        _gaps.length < 2 ? '—' : '$_regularityPct%',
                        'Regularity',
                        theme.success),
                    const SizedBox(width: 12.0),
                    _metricCard(theme, '${_cycles.length}', 'Cycles logged',
                        theme.warning),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Cycle length trend
                _sectionCard(
                  theme,
                  title: 'Cycle Length Trend',
                  subtitle: 'Days between your recent periods',
                  child: trend.values.length < 2
                      ? _emptyState(theme,
                          'Log at least 3 periods to see your cycle-length trend.')
                      : SizedBox(
                          height: 200.0,
                          child: FlutterFlowBarChart(
                            barData: [
                              FFBarChartData(
                                yData: trend.values,
                                color: theme.primary,
                              )
                            ],
                            xLabels: trend.labels,
                            barWidth: 18.0,
                            barBorderRadius: BorderRadius.circular(6.0),
                            axisBounds: AxisBounds(
                              minY: 0.0,
                              maxY: (trend.values.reduce((a, b) => a > b ? a : b) +
                                      6)
                                  .toDouble(),
                            ),
                            xAxisLabelInfo: AxisLabelInfo(
                              showLabels: true,
                              labelTextStyle: theme.labelSmall.override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: theme.secondaryText,
                                letterSpacing: 0.0,
                              ),
                            ),
                            yAxisLabelInfo: AxisLabelInfo(
                              showLabels: true,
                              labelInterval: 7.0,
                              reservedSize: 28.0,
                              labelTextStyle: theme.labelSmall.override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: theme.secondaryText,
                                letterSpacing: 0.0,
                              ),
                            ),
                            chartStylingInfo: ChartStylingInfo(
                              backgroundColor: theme.secondaryBackground,
                              showGrid: true,
                              gridColor: theme.alternate,
                              showBorder: false,
                              enableTooltip: true,
                              tooltipBackgroundColor: theme.primaryText,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16.0),

                // Mood distribution
                _sectionCard(
                  theme,
                  title: 'Mood Distribution',
                  subtitle: 'How you have been feeling',
                  child: moods.isEmpty
                      ? _emptyState(theme,
                          'Log your mood from the dashboard to see patterns here.')
                      : Column(
                          children: _distRows(theme, moods),
                        ),
                ),
                const SizedBox(height: 16.0),

                // Top symptoms
                _sectionCard(
                  theme,
                  title: 'Most Common Symptoms',
                  subtitle: 'Your most frequently logged symptoms',
                  child: symptoms.isEmpty
                      ? _emptyState(theme,
                          'Log symptoms to discover your most common patterns.')
                      : Column(
                          children: _distRows(theme, symptoms),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(
          FlutterFlowTheme theme, String value, String label, Color accent) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: theme.alternate, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(value,
                  style: theme.displaySmall.override(
                    font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                    fontSize: 28.0,
                    letterSpacing: 0.0,
                  )),
              const SizedBox(height: 2.0),
              Text(label,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  )),
            ],
          ),
        ),
      );

  Widget _sectionCard(
    FlutterFlowTheme theme, {
    required String title,
    required String subtitle,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.alternate, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  letterSpacing: 0.0,
                )),
            const SizedBox(height: 2.0),
            Text(subtitle,
                style: theme.bodySmall.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                )),
            const SizedBox(height: 16.0),
            child,
          ],
        ),
      );

  List<Widget> _distRows(FlutterFlowTheme theme, List<_DistRow> rows) {
    final maxCount =
        rows.map((r) => r.count).fold<int>(0, (a, b) => a > b ? a : b);
    return rows
        .map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.label,
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w500),
                            letterSpacing: 0.0,
                          )),
                      Text('${r.count}',
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold),
                            color: r.color,
                            letterSpacing: 0.0,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: LinearProgressIndicator(
                      value: maxCount == 0 ? 0.0 : r.count / maxCount,
                      minHeight: 8.0,
                      backgroundColor: theme.alternate,
                      valueColor: AlwaysStoppedAnimation(r.color),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _emptyState(FlutterFlowTheme theme, String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          children: [
            Icon(Icons.insights_outlined,
                color: theme.secondaryText, size: 22.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(message,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  )),
            ),
          ],
        ),
      );
}
