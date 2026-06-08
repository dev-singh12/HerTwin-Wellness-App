import '/backend/schema/cycles_record.dart';
import '/utils/app_date_utils.dart';

/// The four menstrual-cycle phases.
enum CyclePhase { menstrual, follicular, ovulation, luteal }

extension CyclePhaseLabel on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  /// Short energy descriptor shown on the dashboard.
  String get energyLevel {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Low';
      case CyclePhase.follicular:
        return 'Rising';
      case CyclePhase.ovulation:
        return 'High';
      case CyclePhase.luteal:
        return 'Moderate';
    }
  }

  /// A coaching line tailored to the current phase.
  String get vitalityMessage {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Rest and replenish. Iron-rich foods and gentle movement help you recover.';
      case CyclePhase.follicular:
        return 'Energy is building. A great time for new workouts and creative work.';
      case CyclePhase.ovulation:
        return 'You are at peak energy. Stay hydrated and enjoy higher-intensity activity.';
      case CyclePhase.luteal:
        return 'Your hormonal balance is improving. Keep up the high-protein meals today.';
    }
  }
}

/// Immutable snapshot of where the user is in their cycle, plus predictions.
class CycleStatus {
  const CycleStatus({
    required this.phase,
    required this.cycleDay,
    required this.cycleLength,
    required this.periodLength,
    required this.cycleStart,
    required this.nextPeriodDate,
    required this.ovulationDate,
    required this.vitalityScore,
    required this.hasData,
  });

  final CyclePhase phase;

  /// 1-based day within the current cycle.
  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final DateTime cycleStart;
  final DateTime nextPeriodDate;
  final DateTime ovulationDate;

  /// 0-100 wellness score derived from phase position and cycle regularity.
  final int vitalityScore;

  /// False when the user has not logged any cycle yet (values are estimates).
  final bool hasData;

  int get daysUntilNextPeriod => AppDateUtils.daysUntil(nextPeriodDate);

  /// True when [date] falls on a predicted/actual period day of the current cycle.
  bool isPeriodDay(DateTime date) {
    final start = AppDateUtils.startOfDay(cycleStart);
    final d = AppDateUtils.startOfDay(date);
    final offset = d.difference(start).inDays;
    return offset >= 0 && offset < periodLength;
  }

  /// Phase for an arbitrary date relative to this cycle (used for calendars).
  CyclePhase phaseForDate(DateTime date) {
    final start = AppDateUtils.startOfDay(cycleStart);
    final d = AppDateUtils.startOfDay(date);
    var offset = d.difference(start).inDays % cycleLength;
    if (offset < 0) offset += cycleLength;
    return CycleEngine._phaseForDay(offset + 1, periodLength, cycleLength);
  }
}

/// Pure functions that turn logged cycles into a [CycleStatus].
///
/// Defaults follow the textbook 28-day model so the dashboard renders sensible
/// estimates before the user has logged enough history to personalise them.
class CycleEngine {
  const CycleEngine._();

  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int _minCycleLength = 21;
  static const int _maxCycleLength = 35;

  static CyclePhase _phaseForDay(int day, int periodLength, int cycleLength) {
    if (day <= periodLength) return CyclePhase.menstrual;
    // Ovulation happens ~14 days BEFORE the next period; window is +/-1 day.
    final ovulationDay = cycleLength - 14;
    if (day >= ovulationDay - 1 && day <= ovulationDay + 1) {
      return CyclePhase.ovulation;
    }
    if (day < ovulationDay - 1) return CyclePhase.follicular;
    return CyclePhase.luteal;
  }

  /// Average gap between consecutive logged period starts, clamped to a sane
  /// range. Falls back to [defaultCycleLength] without enough history.
  static int estimateCycleLength(List<CyclesRecord> cycles) {
    final starts = cycles
        .map((c) => c.startDate)
        .whereType<DateTime>()
        .map(AppDateUtils.startOfDay)
        .toList()
      ..sort();
    if (starts.length < 2) return defaultCycleLength;
    var total = 0;
    var count = 0;
    for (var i = 1; i < starts.length; i++) {
      final gap = starts[i].difference(starts[i - 1]).inDays;
      if (gap >= _minCycleLength && gap <= _maxCycleLength) {
        total += gap;
        count++;
      }
    }
    if (count == 0) return defaultCycleLength;
    return (total / count).round().clamp(_minCycleLength, _maxCycleLength);
  }

  /// Regularity 0-1: how consistent the gaps between periods are.
  static double _regularity(List<CyclesRecord> cycles) {
    final starts = cycles
        .map((c) => c.startDate)
        .whereType<DateTime>()
        .map(AppDateUtils.startOfDay)
        .toList()
      ..sort();
    if (starts.length < 3) return 0.7; // neutral-ish default
    final gaps = <int>[];
    for (var i = 1; i < starts.length; i++) {
      gaps.add(starts[i].difference(starts[i - 1]).inDays);
    }
    final mean = gaps.reduce((a, b) => a + b) / gaps.length;
    final variance =
        gaps.map((g) => (g - mean) * (g - mean)).reduce((a, b) => a + b) /
            gaps.length;
    final stdDev = variance <= 0 ? 0.0 : _sqrt(variance);
    // 0 days deviation -> 1.0, 7+ days deviation -> 0.0.
    return (1 - (stdDev / 7)).clamp(0.0, 1.0);
  }

  static double _sqrt(double v) {
    var x = v;
    var prev = 0.0;
    while ((x - prev).abs() > 1e-6) {
      prev = x;
      x = (x + v / x) / 2;
    }
    return x;
  }

  static int _vitalityScore(CyclePhase phase, double regularity) {
    // Base score by phase energy, lifted by how regular the cycle is.
    final base = switch (phase) {
      CyclePhase.menstrual => 60,
      CyclePhase.follicular => 78,
      CyclePhase.ovulation => 85,
      CyclePhase.luteal => 72,
    };
    final bonus = (regularity * 15).round();
    return (base + bonus - 7).clamp(0, 100);
  }

  /// Compute the user's current cycle status. [cycles] may be empty (estimates
  /// are returned with [CycleStatus.hasData] == false). [now] is injectable for
  /// tests; defaults to the current time.
  static CycleStatus compute(List<CyclesRecord> cycles, {DateTime? now}) {
    final today = AppDateUtils.startOfDay(now ?? DateTime.now());

    final logged = cycles
        .where((c) => c.startDate != null)
        .toList()
      ..sort((a, b) => b.startDate!.compareTo(a.startDate!));

    if (logged.isEmpty) {
      // No history: assume a period starting today so the UI has a baseline.
      final phase = _phaseForDay(1, defaultPeriodLength, defaultCycleLength);
      return CycleStatus(
        phase: phase,
        cycleDay: 1,
        cycleLength: defaultCycleLength,
        periodLength: defaultPeriodLength,
        cycleStart: today,
        nextPeriodDate: today.add(Duration(days: defaultCycleLength)),
        ovulationDate: today.add(Duration(days: defaultCycleLength - 14)),
        vitalityScore: _vitalityScore(phase, 0.7),
        hasData: false,
      );
    }

    final cycleLength = estimateCycleLength(cycles);
    final latest = logged.first;
    final periodLength =
        (latest.periodLength ?? defaultPeriodLength).clamp(1, 10);

    // Roll the latest start forward by whole cycles until it covers today,
    // so a stale last-logged period still yields the correct current day.
    var start = AppDateUtils.startOfDay(latest.startDate!);
    while (today.difference(start).inDays >= cycleLength) {
      start = start.add(Duration(days: cycleLength));
    }
    // If the latest logged start is in the future, treat it as the cycle start.
    if (start.isAfter(today)) {
      start = AppDateUtils.startOfDay(latest.startDate!);
    }

    final cycleDay = today.difference(start).inDays + 1;
    final phase = _phaseForDay(cycleDay, periodLength, cycleLength);
    final regularity = _regularity(cycles);

    return CycleStatus(
      phase: phase,
      cycleDay: cycleDay,
      cycleLength: cycleLength,
      periodLength: periodLength,
      cycleStart: start,
      nextPeriodDate: start.add(Duration(days: cycleLength)),
      ovulationDate: start.add(Duration(days: cycleLength - 14)),
      vitalityScore: _vitalityScore(phase, regularity),
      hasData: true,
    );
  }
}
