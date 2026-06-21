/// Pure scoring logic for onboarding assessments.
/// No Flutter or Firebase imports — pure Dart only.

class FocusArea {
  const FocusArea({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final String icon;
  final String title;
  final String subtitle;
}

class ScoringResult {
  const ScoringResult({
    required this.totalScore,
    required this.maxScore,
    required this.healthScore,
    required this.diagnosisLabel,
    required this.severityLevel,
    required this.carePlanType,
    required this.explanation,
    required this.cycleRegularity,
    required this.metabolicRate,
    required this.emotionalImpact,
    required this.functionalImpact,
    required this.focusAreas,
  });

  final int totalScore;
  final int maxScore;
  final int healthScore;
  final String diagnosisLabel;
  final String severityLevel;
  final String carePlanType;
  final String explanation;
  final String cycleRegularity;
  final String metabolicRate;
  final String emotionalImpact;
  final String functionalImpact;
  final List<FocusArea> focusAreas;
}

class ScoringEngine {
  const ScoringEngine._();

  static ScoringResult compute({
    required String conditionType,
    required Map<String, int> answers,
    required int age,
  }) {
    switch (conditionType) {
      case 'pcos':
      case 'pcod':
        return _scorePcosPcod(answers, age);
      case 'pms':
      case 'pmdd':
        return _scorePmsPmdd(answers, conditionType);
      case 'irregular':
        return _scoreIrregular(answers);
      case 'unknown':
      default:
        return _scoreUnknown(answers, age);
    }
  }

  // -----------------------------------------------------------------------
  // PCOS / PCOD
  // -----------------------------------------------------------------------

  static ScoringResult _scorePcosPcod(Map<String, int> answers, int age) {
    final total = answers.values.fold<int>(0, (s, v) => s + v);
    // Q9 optional (only if age >= 22), so max is 16 or 18
    final maxScore = answers.containsKey('pcos_q9') ? 18 : 16;

    String label;
    String severity;
    String carePlan;
    int healthScore;
    String explanation;
    List<FocusArea> focusAreas;

    if (total <= 5) {
      label = 'Likely PCOD Pattern';
      severity = 'mild';
      carePlan = 'lifestyle';
      healthScore = (80 - (total * 2)).clamp(70, 80);
      explanation =
          'Mild hormonal imbalance. Lifestyle changes will help you feel significantly better.';
      focusAreas = _pcodMildFocusAreas;
    } else if (total <= 10) {
      label = 'Mixed Pattern (Needs Attention)';
      severity = 'moderate';
      carePlan = 'care_plan';
      healthScore = (60 - ((total - 6) * 2)).clamp(50, 60);
      explanation =
          'Early PCOS risk detected. A structured care plan and monitoring will keep this in check.';
      focusAreas = _pcosModerateFocusAreas;
    } else {
      label = 'Likely PCOS Pattern';
      severity = 'severe';
      carePlan = 'consult_doctor';
      healthScore = (45 - ((total - 11) * 2)).clamp(35, 45);
      explanation =
          'Hormonal and metabolic patterns indicate PCOS. Medical evaluation is strongly recommended.';
      focusAreas = _pcosSevereFocusAreas;
    }

    final q1 = answers['pcos_q1'] ?? 0;
    final q7 = answers['pcos_q7'] ?? 0;

    return ScoringResult(
      totalScore: total,
      maxScore: maxScore,
      healthScore: healthScore,
      diagnosisLabel: label,
      severityLevel: severity,
      carePlanType: carePlan,
      explanation: explanation,
      cycleRegularity: q1 == 0
          ? 'Regular'
          : q1 == 1
              ? 'Moderate'
              : 'Irregular',
      metabolicRate: q7 == 0
          ? 'Stable'
          : q7 == 1
              ? 'Moderate'
              : 'Elevated',
      emotionalImpact: '',
      functionalImpact: '',
      focusAreas: focusAreas,
    );
  }

  // -----------------------------------------------------------------------
  // PMS / PMDD
  // -----------------------------------------------------------------------

  static ScoringResult _scorePmsPmdd(
      Map<String, int> answers, String conditionType) {
    final total = answers.values.fold<int>(0, (s, v) => s + v);
    const maxScore = 36;

    String label;
    String severity;
    String carePlan;
    int healthScore;
    String explanation;

    final q2 = answers['pms_q2'] ?? 0;
    final q3 = answers['pms_q3'] ?? 0;
    final q4 = answers['pms_q4'] ?? 0;
    final q12 = answers['pms_q12'] ?? 0;

    // PMDD override
    final pmddFlag =
        total >= 26 && (q3 == 3 || q2 == 3 || q4 == 3) && q12 >= 2;

    if (pmddFlag || total >= 26) {
      label = 'PMDD Likely';
      severity = 'pmdd';
      carePlan = 'consult_doctor';
      healthScore = 35;
      explanation =
          'Your symptoms suggest PMDD, a medical condition. A doctor can provide effective treatment options.';
    } else if (total >= 19) {
      label = 'Severe PMS / Borderline PMDD';
      severity = 'severe_pms';
      carePlan = 'care_plan';
      healthScore = 50;
      explanation =
          'Your symptoms are significantly impacting your life. We strongly recommend speaking with a specialist.';
    } else if (total >= 11) {
      label = 'PMS (Mild to Moderate)';
      severity = 'mild_pms';
      carePlan = 'care_plan';
      healthScore = 65;
      explanation =
          "You're experiencing PMS. A personalized care plan can significantly reduce your symptoms.";
    } else {
      label = 'Normal / Minimal PMS';
      severity = 'minimal';
      carePlan = 'lifestyle';
      healthScore = 85;
      explanation =
          'Your symptoms are within the normal range. A few lifestyle tweaks can make your cycle smoother.';
    }

    final emotionalAvg =
        ((answers['pms_q1'] ?? 0) + q2 + q3 + q4) / 4.0;
    final emotionalLabel = emotionalAvg < 1
        ? 'Low'
        : emotionalAvg < 2
            ? 'Moderate'
            : 'High';
    final functionalLabel = q12 == 0
        ? 'None'
        : q12 == 1
            ? 'Mild'
            : q12 == 2
                ? 'Moderate'
                : 'Severe';

    return ScoringResult(
      totalScore: total,
      maxScore: maxScore,
      healthScore: healthScore,
      diagnosisLabel: label,
      severityLevel: severity,
      carePlanType: carePlan,
      explanation: explanation,
      cycleRegularity: '',
      metabolicRate: '',
      emotionalImpact: emotionalLabel,
      functionalImpact: functionalLabel,
      focusAreas: _pmsFocusAreas,
    );
  }

  // -----------------------------------------------------------------------
  // Irregular Periods
  // -----------------------------------------------------------------------

  static ScoringResult _scoreIrregular(Map<String, int> answers) {
    final total = answers.values.fold<int>(0, (s, v) => s + v);
    const maxScore = 12;

    String label;
    String severity;
    String carePlan;
    int healthScore;
    String explanation;

    if (total <= 4) {
      label = 'Likely Hormonal / Stress-Related';
      severity = 'mild';
      carePlan = 'lifestyle';
      healthScore = 75;
      explanation =
          'Your irregular periods are likely stress or lifestyle related. Simple changes can help.';
    } else if (total <= 8) {
      label = 'Needs Monitoring';
      severity = 'moderate';
      carePlan = 'care_plan';
      healthScore = 55;
      explanation =
          'Your irregularity needs monitoring. A structured plan will help identify the cause.';
    } else {
      label = 'Medical Evaluation Recommended';
      severity = 'severe';
      carePlan = 'consult_doctor';
      healthScore = 40;
      explanation =
          'Your symptoms suggest an underlying issue. Medical evaluation is recommended.';
    }

    return ScoringResult(
      totalScore: total,
      maxScore: maxScore,
      healthScore: healthScore,
      diagnosisLabel: label,
      severityLevel: severity,
      carePlanType: carePlan,
      explanation: explanation,
      cycleRegularity: total <= 4 ? 'Mildly Irregular' : 'Irregular',
      metabolicRate: '',
      emotionalImpact: '',
      functionalImpact: '',
      focusAreas: _irregularFocusAreas,
    );
  }

  // -----------------------------------------------------------------------
  // Unknown / Not Sure — route to sub-scoring based on final Q
  // -----------------------------------------------------------------------

  static ScoringResult _scoreUnknown(Map<String, int> answers, int age) {
    final finalQ = answers['unknown_final'] ?? 3;
    if (finalQ == 0) {
      // Physical → PCOS/PCOD scoring
      return _scorePcosPcod(answers, age);
    } else if (finalQ == 1) {
      // Emotional → PMS/PMDD scoring
      return _scorePmsPmdd(answers, 'pms');
    }
    // Both or unknown — combined interpretation
    final total = answers.values.fold<int>(0, (s, v) => s + v);
    final healthScore = (70 - total).clamp(30, 85);
    return ScoringResult(
      totalScore: total,
      maxScore: 24,
      healthScore: healthScore,
      diagnosisLabel: 'Mixed Symptoms Pattern',
      severityLevel: total > 12 ? 'moderate' : 'mild',
      carePlanType: total > 16 ? 'consult_doctor' : 'care_plan',
      explanation:
          'Your symptoms span both physical and emotional areas. A specialist can help pinpoint the best path forward.',
      cycleRegularity: '',
      metabolicRate: '',
      emotionalImpact: '',
      functionalImpact: '',
      focusAreas: [..._pcodMildFocusAreas, ..._pmsFocusAreas.take(2)],
    );
  }

  // -----------------------------------------------------------------------
  // Focus area catalogs
  // -----------------------------------------------------------------------

  static const _pcosSevereFocusAreas = [
    FocusArea(icon: '\u{1F37D}\uFE0F', title: 'Low Glycemic Diet', subtitle: 'Focus on whole grains to stabilize hormone levels.'),
    FocusArea(icon: '\u{1F9D8}', title: 'Stress Management', subtitle: 'Daily 10-min meditation reduces cortisol significantly.'),
    FocusArea(icon: '\u{1F4AA}', title: 'Resistance Training', subtitle: 'Low-impact strength 3x/week helps insulin sensitivity.'),
    FocusArea(icon: '\u{1F48A}', title: 'Supplement Check', subtitle: 'Ask your doctor about Inositol and Vitamin D.'),
    FocusArea(icon: '\u{1F634}', title: 'Sleep Hygiene', subtitle: '7-9 hours of quality sleep is crucial for hormone regulation.'),
  ];

  static const _pcosModerateFocusAreas = [
    FocusArea(icon: '\u{1F957}', title: 'Balanced Nutrition', subtitle: 'Regular balanced meals stabilize insulin and hormones.'),
    FocusArea(icon: '\u{1F3C3}', title: 'Regular Exercise', subtitle: '30 min moderate activity 5x/week improves cycle regularity.'),
    FocusArea(icon: '\u{1F4A7}', title: 'Hydration', subtitle: '8 glasses of water daily supports hormonal clearance.'),
    FocusArea(icon: '\u{1F634}', title: 'Sleep Routine', subtitle: 'Consistent sleep schedule helps regulate your hormones.'),
  ];

  static const _pcodMildFocusAreas = [
    FocusArea(icon: '\u{1F957}', title: 'Balanced Nutrition', subtitle: 'Regular meals stabilize hormones effectively.'),
    FocusArea(icon: '\u{1F6B6}', title: 'Daily Movement', subtitle: '30 minutes of walking reduces cycle irregularity.'),
    FocusArea(icon: '\u{1F4A7}', title: 'Hydration', subtitle: '8 glasses of water daily supports hormonal clearance.'),
  ];

  static const _pmsFocusAreas = [
    FocusArea(icon: '\u{1F33F}', title: 'Magnesium & B6', subtitle: 'These nutrients are clinically proven to reduce PMS.'),
    FocusArea(icon: '\u{1F9D8}', title: 'Evening Mindfulness', subtitle: '10 min of breathwork before sleep reduces anxiety.'),
    FocusArea(icon: '\u{1F6AB}', title: 'Reduce Caffeine & Salt', subtitle: 'Especially in the week before your period.'),
    FocusArea(icon: '\u{1F3C3}', title: 'Gentle Exercise', subtitle: 'Even a 20-min walk releases mood-lifting endorphins.'),
    FocusArea(icon: '\u{1F4D4}', title: 'Mood Journal', subtitle: 'Track triggers to understand and predict your patterns.'),
  ];

  static const _irregularFocusAreas = [
    FocusArea(icon: '\u{1F957}', title: 'Balanced Diet', subtitle: 'Consistent nutrition helps regularize your cycle.'),
    FocusArea(icon: '\u{1F9D8}', title: 'Stress Reduction', subtitle: 'High stress is a top cause of irregular periods.'),
    FocusArea(icon: '\u{1F6B6}', title: 'Regular Exercise', subtitle: 'Moderate daily activity supports cycle regularity.'),
    FocusArea(icon: '\u{1F634}', title: 'Sleep Hygiene', subtitle: 'Consistent sleep schedule regulates your hormones.'),
  ];
}
