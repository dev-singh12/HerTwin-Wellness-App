/// Question definitions for onboarding assessment.
/// Pure data — no Flutter imports.

class QuestionOption {
  const QuestionOption({required this.label, required this.score});
  final String label;
  final int score;
}

class AssessmentQuestion {
  const AssessmentQuestion({required this.id, required this.text, required this.options});
  final String id;
  final String text;
  final List<QuestionOption> options;
}

const pcosQuestions = <AssessmentQuestion>[
  AssessmentQuestion(id: 'pcos_q1', text: 'How regular are your periods?', options: [
    QuestionOption(label: 'Regular \u{2014} every 28\u{2013}35 days', score: 0),
    QuestionOption(label: 'Slightly irregular \u{2014} every 35\u{2013}45 days', score: 1),
    QuestionOption(label: 'Very irregular / missed for 2+ months', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q2', text: 'Have you noticed weight changes recently?', options: [
    QuestionOption(label: 'My weight has stayed stable', score: 0),
    QuestionOption(label: 'Mild weight gain', score: 1),
    QuestionOption(label: 'Significant weight gain, especially around the belly', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q3', text: 'How would you describe your skin (acne)?', options: [
    QuestionOption(label: 'Clear skin or occasional pimples', score: 0),
    QuestionOption(label: 'Moderate acne', score: 1),
    QuestionOption(label: 'Severe or persistent acne', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q4', text: 'Do you notice unwanted facial or body hair?', options: [
    QuestionOption(label: 'No unusual hair growth', score: 0),
    QuestionOption(label: 'Occasional hair on upper lip or chin', score: 1),
    QuestionOption(label: 'Noticeable thick hair on chin, chest, or abdomen', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q5', text: 'How is your hair (scalp)?', options: [
    QuestionOption(label: 'Normal hair density', score: 0),
    QuestionOption(label: 'Mild hair fall', score: 1),
    QuestionOption(label: 'Severe thinning, especially at the front or top', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q6', text: 'How are your energy and mood levels generally?', options: [
    QuestionOption(label: 'Normal energy, stable mood', score: 0),
    QuestionOption(label: 'Sometimes feel low or fatigued', score: 1),
    QuestionOption(label: 'Frequently tired, mood swings, or brain fog', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q7', text: 'How does your body react to sugar or carbs?', options: [
    QuestionOption(label: 'I feel normal after eating \u{2014} no unusual cravings', score: 0),
    QuestionOption(label: 'I sometimes crave sweets or feel hungry again quickly', score: 1),
    QuestionOption(label: 'I often crave sweets, feel tired after meals, or gain weight easily', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q8', text: 'Skin darkening on neck or underarms?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Slight darkening', score: 1),
    QuestionOption(label: 'Dark patches clearly visible', score: 2),
  ]),
];

const pcosQ9 = AssessmentQuestion(id: 'pcos_q9', text: 'Are you currently trying to conceive?', options: [
  QuestionOption(label: 'Not trying / not applicable', score: 0),
  QuestionOption(label: 'Trying for a few months', score: 1),
  QuestionOption(label: 'Trying for over 1 year without success', score: 2),
]);

const pmsQuestions = <AssessmentQuestion>[
  AssessmentQuestion(id: 'pms_q1', text: 'Mood swings in the week before your period?', options: [
    QuestionOption(label: 'None at all', score: 0),
    QuestionOption(label: 'Occasionally irritable', score: 1),
    QuestionOption(label: 'Frequent mood changes', score: 2),
    QuestionOption(label: 'Sudden, uncontrollable mood shifts', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q2', text: 'Irritability or anger before your period?', options: [
    QuestionOption(label: 'No unusual irritability', score: 0),
    QuestionOption(label: 'Slight irritation', score: 1),
    QuestionOption(label: 'Easily angered', score: 2),
    QuestionOption(label: 'Severe anger, affecting my relationships', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q3', text: 'Feelings of sadness or depression?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Feeling a bit low', score: 1),
    QuestionOption(label: 'Persistent sadness', score: 2),
    QuestionOption(label: 'Severe depression or hopelessness', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q4', text: 'Anxiety or tension?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Mild worry', score: 1),
    QuestionOption(label: 'Restlessness or unease', score: 2),
    QuestionOption(label: 'Panic or severe anxiety', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q5', text: 'Loss of interest in things you normally enjoy?', options: [
    QuestionOption(label: 'No change', score: 0),
    QuestionOption(label: 'Slight decrease in interest', score: 1),
    QuestionOption(label: 'Noticeably less motivated', score: 2),
    QuestionOption(label: 'No interest in anything', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q6', text: 'Sleep quality during this phase?', options: [
    QuestionOption(label: 'Normal sleep', score: 0),
    QuestionOption(label: 'Mild disturbance', score: 1),
    QuestionOption(label: 'Insomnia or sleeping too much', score: 2),
    QuestionOption(label: 'Severe sleep disruption affecting daily life', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q7', text: 'Fatigue or low energy?', options: [
    QuestionOption(label: 'Normal energy', score: 0),
    QuestionOption(label: 'Slightly tired', score: 1),
    QuestionOption(label: 'Moderate fatigue', score: 2),
    QuestionOption(label: 'Exhausted, can\'t function normally', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q8', text: 'Appetite changes or food cravings?', options: [
    QuestionOption(label: 'Normal appetite', score: 0),
    QuestionOption(label: 'Mild sweet cravings', score: 1),
    QuestionOption(label: 'Notably increased or decreased appetite', score: 2),
    QuestionOption(label: 'Binge eating or complete loss of appetite', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q9', text: 'Breast tenderness, cramps, or body pain?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Mild discomfort', score: 1),
    QuestionOption(label: 'Moderate pain', score: 2),
    QuestionOption(label: 'Severe pain disrupting daily activities', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q10', text: 'Bloating or water retention?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Mild bloating', score: 1),
    QuestionOption(label: 'Noticeable swelling or puffiness', score: 2),
    QuestionOption(label: 'Severe bloating, clothes feel tight', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q11', text: 'Headaches or other physical symptoms?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Mild', score: 1),
    QuestionOption(label: 'Moderate', score: 2),
    QuestionOption(label: 'Severe, need medication', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q12', text: 'How much do these symptoms affect your daily life?', options: [
    QuestionOption(label: 'No effect on daily life', score: 0),
    QuestionOption(label: 'Slight difficulty but manageable', score: 1),
    QuestionOption(label: 'Reduced productivity at work or school', score: 2),
    QuestionOption(label: 'Unable to work, avoid social situations entirely', score: 3),
  ]),
];

const irregularQuestions = <AssessmentQuestion>[
  AssessmentQuestion(id: 'irreg_q1', text: 'How irregular are your periods?', options: [
    QuestionOption(label: 'Slightly delayed (1\u{2013}2 weeks late)', score: 0),
    QuestionOption(label: 'Often skip a month', score: 1),
    QuestionOption(label: 'Miss 3 or more months at a time', score: 2),
  ]),
  AssessmentQuestion(id: 'irreg_q2', text: 'Any associated pain or cramps?', options: [
    QuestionOption(label: 'No pain', score: 0),
    QuestionOption(label: 'Manageable pain', score: 1),
    QuestionOption(label: 'Severe pain disrupting daily life', score: 2),
  ]),
  AssessmentQuestion(id: 'irreg_q3', text: 'Flow when it comes?', options: [
    QuestionOption(label: 'Normal or light', score: 0),
    QuestionOption(label: 'Heavy or prolonged (>7 days)', score: 1),
    QuestionOption(label: 'Very heavy with clots', score: 2),
  ]),
  AssessmentQuestion(id: 'irreg_q4', text: 'Any recent significant stress, weight changes, or illness?', options: [
    QuestionOption(label: 'No, life is relatively stable', score: 0),
    QuestionOption(label: 'Some stress or moderate changes', score: 1),
    QuestionOption(label: 'Major stress, illness, or significant weight change', score: 2),
  ]),
  AssessmentQuestion(id: 'irreg_q6', text: 'Are you on any medication or birth control?', options: [
    QuestionOption(label: 'No', score: 0),
    QuestionOption(label: 'Currently on birth control', score: 1),
    QuestionOption(label: 'On other medication that may affect cycles', score: 2),
  ]),
];

const unknownQuestions = <AssessmentQuestion>[
  AssessmentQuestion(id: 'pcos_q1', text: 'How regular are your periods?', options: [
    QuestionOption(label: 'Regular \u{2014} every 28\u{2013}35 days', score: 0),
    QuestionOption(label: 'Slightly irregular \u{2014} every 35\u{2013}45 days', score: 1),
    QuestionOption(label: 'Very irregular / missed for 2+ months', score: 2),
  ]),
  AssessmentQuestion(id: 'pcos_q2', text: 'Have you noticed weight changes recently?', options: [
    QuestionOption(label: 'My weight has stayed stable', score: 0),
    QuestionOption(label: 'Mild weight gain', score: 1),
    QuestionOption(label: 'Significant weight gain', score: 2),
  ]),
  AssessmentQuestion(id: 'pms_q1', text: 'Mood swings before your period?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Occasionally irritable', score: 1),
    QuestionOption(label: 'Frequent mood changes', score: 2),
    QuestionOption(label: 'Uncontrollable mood shifts', score: 3),
  ]),
  AssessmentQuestion(id: 'pcos_q6', text: 'How are your energy levels?', options: [
    QuestionOption(label: 'Normal energy', score: 0),
    QuestionOption(label: 'Sometimes fatigued', score: 1),
    QuestionOption(label: 'Frequently tired or brain fog', score: 2),
  ]),
  AssessmentQuestion(id: 'pms_q6', text: 'Sleep quality?', options: [
    QuestionOption(label: 'Normal sleep', score: 0),
    QuestionOption(label: 'Mild disturbance', score: 1),
    QuestionOption(label: 'Insomnia or sleeping too much', score: 2),
    QuestionOption(label: 'Severe disruption', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q9', text: 'Breast tenderness, cramps, or body pain?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Mild', score: 1),
    QuestionOption(label: 'Moderate', score: 2),
    QuestionOption(label: 'Severe', score: 3),
  ]),
  AssessmentQuestion(id: 'pms_q10', text: 'Bloating or water retention?', options: [
    QuestionOption(label: 'None', score: 0),
    QuestionOption(label: 'Mild', score: 1),
    QuestionOption(label: 'Moderate', score: 2),
    QuestionOption(label: 'Severe', score: 3),
  ]),
  AssessmentQuestion(id: 'unknown_final', text: 'Which of these sounds most like you?', options: [
    QuestionOption(label: 'I mostly deal with physical symptoms (weight, skin, hair)', score: 0),
    QuestionOption(label: 'I mostly deal with emotional/mood symptoms before my period', score: 1),
    QuestionOption(label: 'Both equally', score: 2),
    QuestionOption(label: 'I really don\'t know yet', score: 3),
  ]),
];

List<AssessmentQuestion> questionsForCondition(String condition, {int? age}) {
  switch (condition) {
    case 'pcos':
    case 'pcod':
      final qs = [...pcosQuestions];
      if (age != null && age >= 22) qs.add(pcosQ9);
      return qs;
    case 'pms':
    case 'pmdd':
      return pmsQuestions;
    case 'irregular':
      return irregularQuestions;
    case 'unknown':
    default:
      return unknownQuestions;
  }
}
