import 'package:flutter/material.dart';

import '/business/cycle_engine.dart';

class WellnessContent {
  const WellnessContent({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMins,
    required this.description,
    this.phase,
    this.conditions = const ['all'],
    this.poses = const [],
    this.difficulty = 'Beginner',
    this.gradientColors = const [Color(0xFFEFA6B3), Color(0xFF9FA8DA)],
    this.icon = Icons.self_improvement,
  });

  final String id;
  final String title;
  final String category;
  final int durationMins;
  final String description;
  final String? phase;
  final List<String> conditions;
  final List<PoseEntry> poses;
  final String difficulty;
  final List<Color> gradientColors;
  final IconData icon;
}

class PoseEntry {
  const PoseEntry({required this.emoji, required this.name, this.durationSecs = 60});
  final String emoji;
  final String name;
  final int durationSecs;
}

class WellnessArticle {
  const WellnessArticle({
    required this.id,
    required this.title,
    required this.readMins,
    required this.category,
    this.conditions = const ['all'],
    required this.excerptText,
    required this.fullText,
    this.gradientColors = const [Color(0xFFEFA6B3), Color(0xFF9FA8DA)],
  });

  final String id;
  final String title;
  final int readMins;
  final String category;
  final List<String> conditions;
  final String excerptText;
  final String fullText;
  final List<Color> gradientColors;
}

class WellnessContentCatalog {
  WellnessContentCatalog._();

  /// A real, follow-along YouTube video (by [VideoLibrary] id) for each yoga
  /// flow, so a user can practise along instead of only reading pose names.
  /// Every id here points at an already-verified WellnessVideo — do not add one
  /// that is not in VideoLibrary. Multiple flows may share a video.
  static const yogaVideoByFlowId = <String, String>{
    'yoga_follicular_flow': 'vid_women_adriene',
    'yoga_luteal_restore': 'vid_pcos_agnes_relax',
    'yoga_period_ease': 'vid_cramps_adison',
    'yoga_pcos_strength': 'vid_pcos_bothra',
    'yoga_ovulation_power': 'vid_pcos_bharti',
    'yoga_pms_calm': 'vid_cramps_adriene',
    'yoga_morning_gentle': 'vid_period_kassandra',
    'yoga_sleep_wind_down': 'vid_pcos_agnes_meditation',
    'yoga_thyroid_balance': 'vid_hormone_shailendra',
    'yoga_hip_opener': 'vid_period_yogini',
    'yoga_desk_reset': 'vid_women_adriene',
    'yoga_cortisol_reset': 'vid_pcos_agnes_relax',
    'yoga_cycle_regularity_30': 'vid_pcos_satvic',
  };

  /// The follow-along video library id for a yoga flow, or null if none.
  static String? yogaVideoId(String flowId) => yogaVideoByFlowId[flowId];

  static List<WellnessContent> forConditionAndPhase({
    String? condition,
    CyclePhase? phase,
  }) {
    var items = [...yogaContents, ...mindfulnessContents, ...meditationContents];
    if (phase != null) {
      final phaseStr = phase.name;
      final matched = items.where((i) => i.phase == phaseStr).toList();
      final rest = items.where((i) => i.phase != phaseStr).toList();
      items = [...matched, ...rest];
    }
    if (condition != null && condition.isNotEmpty) {
      items.sort((a, b) {
        final aMatch = a.conditions.contains(condition) || a.conditions.contains('all');
        final bMatch = b.conditions.contains(condition) || b.conditions.contains('all');
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return 0;
      });
    }
    return items.take(6).toList();
  }

  static const yogaContents = [
    WellnessContent(
      id: 'yoga_follicular_flow',
      title: 'Follicular Flow Yoga',
      category: 'yoga',
      durationMins: 15,
      description: 'Boost energy and flexibility during your follicular phase. This gentle flow builds strength while honoring your rising energy.',
      phase: 'follicular',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Child\'s Pose', durationSecs: 60),
        PoseEntry(emoji: '\u{1F98B}', name: 'Butterfly Pose', durationSecs: 60),
        PoseEntry(emoji: '\u{1F408}', name: 'Cat-Cow Stretch', durationSecs: 60),
        PoseEntry(emoji: '\u{1F30A}', name: 'Seated Forward Bend', durationSecs: 60),
      ],
    ),
    WellnessContent(
      id: 'yoga_luteal_restore',
      title: 'Luteal Restore Yoga',
      category: 'yoga',
      durationMins: 20,
      description: 'Calming restorative poses for the luteal phase when your body needs gentleness and grounding.',
      phase: 'luteal',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F6CC}', name: 'Legs-Up-The-Wall', durationSecs: 90),
        PoseEntry(emoji: '\u{1F938}', name: 'Reclined Twist', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Savasana', durationSecs: 120),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Child\'s Pose', durationSecs: 60),
      ],
    ),
    WellnessContent(
      id: 'yoga_period_ease',
      title: 'Period Pain Relief Yoga',
      category: 'yoga',
      durationMins: 10,
      description: 'Gentle poses specifically designed to ease cramps, bloating, and lower back pain during menstruation.',
      phase: 'menstruation',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Reclined Butterfly', durationSecs: 90),
        PoseEntry(emoji: '\u{1F408}', name: 'Cat-Cow Stretch', durationSecs: 60),
        PoseEntry(emoji: '\u{1F6CC}', name: 'Supine Twist', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Savasana', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'yoga_pcos_strength',
      title: 'PCOS Strength Flow',
      category: 'yoga',
      durationMins: 25,
      description: 'Low-impact strength yoga designed for PCOS. Improves insulin sensitivity and builds lean muscle.',
      conditions: ['pcos', 'pcod'],
      difficulty: 'Intermediate',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Warrior II', durationSecs: 60),
        PoseEntry(emoji: '\u{1F4AA}', name: 'Chair Pose', durationSecs: 45),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Bridge Pose', durationSecs: 60),
        PoseEntry(emoji: '\u{1F938}', name: 'Boat Pose', durationSecs: 45),
        PoseEntry(emoji: '\u{1F33F}', name: 'Savasana', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'yoga_ovulation_power',
      title: 'Ovulation Power Flow',
      category: 'yoga',
      durationMins: 20,
      description: 'Energizing flow for your peak energy days during ovulation. Build strength and confidence.',
      phase: 'ovulation',
      difficulty: 'Intermediate',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Sun Salutation A', durationSecs: 90),
        PoseEntry(emoji: '\u{1F4AA}', name: 'Warrior III', durationSecs: 45),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Tree Pose', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Cool Down', durationSecs: 60),
      ],
    ),
    WellnessContent(
      id: 'yoga_pms_calm',
      title: 'PMS Calming Sequence',
      category: 'yoga',
      durationMins: 15,
      description: 'Targeted sequence for PMS symptoms. Reduces anxiety, bloating, and irritability.',
      conditions: ['pms', 'pmdd'],
      phase: 'luteal',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Child\'s Pose', durationSecs: 90),
        PoseEntry(emoji: '\u{1F98B}', name: 'Happy Baby', durationSecs: 60),
        PoseEntry(emoji: '\u{1F6CC}', name: 'Legs-Up-The-Wall', durationSecs: 120),
        PoseEntry(emoji: '\u{1F33F}', name: 'Savasana', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'yoga_morning_gentle',
      title: 'Gentle Morning Stretch',
      category: 'yoga',
      durationMins: 10,
      description: 'A gentle wake-up flow suitable for any phase of your cycle. Start your day with intention.',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F408}', name: 'Cat-Cow', durationSecs: 60),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Forward Fold', durationSecs: 45),
        PoseEntry(emoji: '\u{1F4AA}', name: 'Low Lunge', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Standing Stretch', durationSecs: 45),
      ],
    ),
    WellnessContent(
      id: 'yoga_sleep_wind_down',
      title: 'Sleep Wind-Down Yoga',
      category: 'yoga',
      durationMins: 12,
      description: 'Bedtime yoga to calm your nervous system and prepare for restful sleep.',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Seated Forward Bend', durationSecs: 90),
        PoseEntry(emoji: '\u{1F938}', name: 'Supine Twist', durationSecs: 60),
        PoseEntry(emoji: '\u{1F6CC}', name: 'Legs-Up-The-Wall', durationSecs: 120),
        PoseEntry(emoji: '\u{1F33F}', name: 'Body Scan Savasana', durationSecs: 120),
      ],
    ),
    WellnessContent(
      id: 'yoga_thyroid_balance',
      title: 'Thyroid Balance Flow',
      category: 'yoga',
      durationMins: 18,
      description: 'Stimulate the thyroid gland with targeted neck stretches and gentle inversions. Supports hormonal regulation for irregular cycles.',
      conditions: ['irregular'],
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Neck Rolls', durationSecs: 60),
        PoseEntry(emoji: '\u{1F98B}', name: 'Fish Pose', durationSecs: 60),
        PoseEntry(emoji: '\u{1F408}', name: 'Cat-Cow', durationSecs: 60),
        PoseEntry(emoji: '\u{1F4AA}', name: 'Shoulder Stand Prep', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Savasana', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'yoga_hip_opener',
      title: 'Deep Hip Opener',
      category: 'yoga',
      durationMins: 20,
      description: 'Release stored tension and emotions through deep hip-opening poses. Perfect for any cycle phase.',
      difficulty: 'Intermediate',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Pigeon Pose (Right)', durationSecs: 90),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Pigeon Pose (Left)', durationSecs: 90),
        PoseEntry(emoji: '\u{1F98B}', name: 'Lizard Pose', durationSecs: 60),
        PoseEntry(emoji: '\u{1F30A}', name: 'Frog Pose', durationSecs: 90),
        PoseEntry(emoji: '\u{1F33F}', name: 'Savasana', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'yoga_desk_reset',
      title: 'Desk Break Reset',
      category: 'yoga',
      durationMins: 8,
      description: 'Quick standing and seated stretches you can do at your desk. Relieves neck, shoulder, and wrist tension.',
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F4AA}', name: 'Seated Neck Stretch', durationSecs: 45),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Eagle Arms', durationSecs: 45),
        PoseEntry(emoji: '\u{1F938}', name: 'Seated Twist', durationSecs: 45),
        PoseEntry(emoji: '\u{1F30A}', name: 'Wrist Circles', durationSecs: 30),
        PoseEntry(emoji: '\u{1F33F}', name: 'Standing Forward Fold', durationSecs: 45),
      ],
    ),
    WellnessContent(
      id: 'yoga_cortisol_reset',
      title: 'Cortisol Reset Flow',
      category: 'yoga',
      durationMins: 15,
      description: 'Calm your nervous system and lower cortisol with this grounding sequence. Ideal for stressful days.',
      conditions: ['pcos', 'pcod', 'pmdd'],
      difficulty: 'Beginner',
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Child\'s Pose', durationSecs: 90),
        PoseEntry(emoji: '\u{1F408}', name: 'Cat-Cow', durationSecs: 60),
        PoseEntry(emoji: '\u{1F6CC}', name: 'Supported Bridge', durationSecs: 90),
        PoseEntry(emoji: '\u{1F938}', name: 'Reclined Twist', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Legs-Up-The-Wall', durationSecs: 120),
      ],
    ),    WellnessContent(
      id: 'yoga_cycle_regularity_30',
      title: 'Cycle Regularity \u2014 30 Min Daily',
      category: 'yoga',
      durationMins: 30,
      description: 'Evidence-based 30-minute daily routine to regulate irregular periods. '
          '5 poses targeting pelvic blood flow, hormonal balance, and stress reduction. '
          'Each pose is held for 5 minutes with 1-minute rest between. '
          'Based on research from Journal of Alternative & Complementary Medicine.',
      conditions: ['irregular', 'pcos', 'pcod'],
      difficulty: 'Beginner',
      gradientColors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      icon: Icons.timer,
      poses: [
        PoseEntry(emoji: '\\u{1F9D8}', name: 'Baddha Konasana (Butterfly Pose) \u2014 Opens hips, stimulates ovaries & uterus. Sit tall, soles together, gently press knees down. Breathe deeply.', durationSecs: 300),
        PoseEntry(emoji: '\\u{23F8}', name: 'Rest \u2014 Lie flat, breathe normally', durationSecs: 60),
        PoseEntry(emoji: '\\u{1F9D8}', name: 'Supta Baddha Konasana (Reclined Butterfly) \u2014 Releases pelvic tension, calms nervous system. Lie back with soles together, arms relaxed.', durationSecs: 300),
        PoseEntry(emoji: '\\u{23F8}', name: 'Rest \u2014 Gentle side roll, breathe', durationSecs: 60),
        PoseEntry(emoji: '\\u{1F9D8}', name: 'Setu Bandhasana (Bridge Pose) \u2014 Stimulates thyroid & reproductive organs. Lift hips, press feet down, squeeze glutes gently. Hold steady.', durationSecs: 300),
        PoseEntry(emoji: '\\u{23F8}', name: 'Rest \u2014 Hug knees to chest gently', durationSecs: 60),
        PoseEntry(emoji: '\\u{1F9D8}', name: 'Viparita Karani (Legs-Up-The-Wall) \u2014 Improves blood flow to pelvis, regulates hormones, reduces cortisol. Lie with legs elevated against wall.', durationSecs: 300),
        PoseEntry(emoji: '\\u{23F8}', name: 'Rest \u2014 Lower legs slowly, breathe', durationSecs: 60),
        PoseEntry(emoji: '\\u{1F9D8}', name: 'Bhujangasana (Cobra Pose) \u2014 Massages reproductive organs, strengthens back, balances hormones. Lie prone, lift chest with arms, keep hips grounded.', durationSecs: 300),
        PoseEntry(emoji: '\\u{23F8}', name: 'Savasana \u2014 Final rest. Lie completely still for 1 minute. Observe your body.', durationSecs: 60),
      ],
    ),  ];

  static const mindfulnessContents = [
    WellnessContent(
      id: 'breathwork_478',
      title: '4-7-8 Breathing',
      category: 'mind',
      durationMins: 5,
      description: 'The 4-7-8 technique calms your nervous system. Inhale 4s, hold 7s, exhale 8s. Clinically proven to reduce anxiety.',
      icon: Icons.air,
    ),
    WellnessContent(
      id: 'meditation_body_scan',
      title: 'Body Scan Meditation',
      category: 'mind',
      durationMins: 10,
      description: 'A guided body scan to release tension and connect with your body. Perfect for any cycle phase.',
      icon: Icons.spa,
    ),
    WellnessContent(
      id: 'journal_mood',
      title: 'Mood Journal',
      category: 'mind',
      durationMins: 5,
      description: 'Write freely about your day. Tracking your mood patterns helps you understand your cycle better.',
      icon: Icons.edit_note,
    ),
  ];

  static const meditationContents = [
    WellnessContent(
      id: 'meditation_pmr',
      title: 'Progressive Muscle Relaxation',
      category: 'meditation',
      durationMins: 15,
      description: 'Systematically tense and release each muscle group to melt away physical and emotional tension.',
      icon: Icons.accessibility_new,
      poses: [
        PoseEntry(emoji: '\u{1F9E0}', name: 'Face & Jaw \u2014 Scrunch tight, then release', durationSecs: 60),
        PoseEntry(emoji: '\u{1F4AA}', name: 'Shoulders & Neck \u2014 Shrug up to ears, drop', durationSecs: 60),
        PoseEntry(emoji: '\u{270B}', name: 'Hands & Arms \u2014 Make fists, squeeze, relax', durationSecs: 60),
        PoseEntry(emoji: '\u{1F9D8}', name: 'Core & Back \u2014 Tighten abs, arch gently', durationSecs: 60),
        PoseEntry(emoji: '\u{1F9B6}', name: 'Legs & Feet \u2014 Point toes, curl, release', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Full Body \u2014 Notice the calm', durationSecs: 120),
      ],
    ),
    WellnessContent(
      id: 'meditation_loving_kindness',
      title: 'Loving-Kindness Meditation',
      category: 'meditation',
      durationMins: 10,
      description: 'Cultivate compassion for yourself and others. Especially helpful during the luteal phase when self-criticism peaks.',
      conditions: ['pms', 'pmdd'],
      phase: 'luteal',
      icon: Icons.favorite,
      poses: [
        PoseEntry(emoji: '\u{1F49C}', name: 'Send kindness to yourself', durationSecs: 90),
        PoseEntry(emoji: '\u{1F49B}', name: 'Send kindness to a loved one', durationSecs: 60),
        PoseEntry(emoji: '\u{1F49A}', name: 'Send kindness to a neutral person', durationSecs: 60),
        PoseEntry(emoji: '\u{1F90D}', name: 'Send kindness to all beings', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Rest in awareness', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'meditation_yoga_nidra',
      title: 'Sleep Yoga Nidra',
      category: 'meditation',
      durationMins: 20,
      description: 'Deep guided relaxation for restorative sleep. Lie down comfortably and follow each instruction.',
      icon: Icons.bedtime,
      poses: [
        PoseEntry(emoji: '\u{1F6CC}', name: 'Settle in \u2014 Find a comfortable position', durationSecs: 90),
        PoseEntry(emoji: '\u{1F4AD}', name: 'Set your intention (Sankalpa)', durationSecs: 60),
        PoseEntry(emoji: '\u{1F9E0}', name: 'Rotate awareness through the body', durationSecs: 180),
        PoseEntry(emoji: '\u{1F30A}', name: 'Feel the breath like gentle waves', durationSecs: 120),
        PoseEntry(emoji: '\u{2728}', name: 'Visualise a peaceful place', durationSecs: 120),
        PoseEntry(emoji: '\u{1F33F}', name: 'Slowly return to wakefulness', durationSecs: 90),
      ],
    ),
    WellnessContent(
      id: 'meditation_gratitude',
      title: 'Gratitude Meditation',
      category: 'meditation',
      durationMins: 8,
      description: 'Shift your mindset by focusing on what you appreciate. Boosts mood and reduces anxiety naturally.',
      icon: Icons.wb_sunny,
      poses: [
        PoseEntry(emoji: '\u{1F9D8}', name: 'Centre yourself with 3 deep breaths', durationSecs: 60),
        PoseEntry(emoji: '\u{1F49B}', name: 'Think of something your body does for you', durationSecs: 60),
        PoseEntry(emoji: '\u{1F49C}', name: 'Think of someone who supports you', durationSecs: 60),
        PoseEntry(emoji: '\u{1F31F}', name: 'Think of a small joy from today', durationSecs: 60),
        PoseEntry(emoji: '\u{1F33F}', name: 'Sit with the feeling of gratitude', durationSecs: 90),
      ],
    ),
  ];

  static const articles = [
    WellnessArticle(
      id: 'art_pcos_diet',
      title: 'The Low-Glycemic Diet Guide for PCOS',
      readMins: 8,
      category: 'nutrition',
      conditions: ['pcos', 'pcod'],
      excerptText: 'Managing PCOS through diet is one of the most powerful tools available...',
      fullText: '''Managing PCOS through diet is one of the most powerful tools available to you. A low-glycemic diet focuses on foods that don't spike your blood sugar rapidly.

Key Principles:
- Choose whole grains over refined carbs (brown rice, quinoa, oats)
- Include protein with every meal to slow sugar absorption
- Eat plenty of leafy greens and colorful vegetables
- Healthy fats from avocado, nuts, and olive oil support hormone production
- Limit sugary drinks, processed foods, and refined snacks

Sample Day:
Breakfast: Oatmeal with berries and nuts
Lunch: Grilled chicken salad with quinoa
Snack: Apple with almond butter
Dinner: Salmon with roasted vegetables

Studies show that women with PCOS who follow a low-GI diet for 12 weeks see significant improvements in insulin sensitivity and hormonal balance.''',
    ),
    WellnessArticle(
      id: 'art_pms_nutrition',
      title: 'Foods That Fight PMS Symptoms',
      readMins: 6,
      category: 'nutrition',
      conditions: ['pms', 'pmdd'],
      excerptText: 'Certain foods can significantly reduce PMS symptoms when eaten during the luteal phase...',
      fullText: '''Certain foods can significantly reduce PMS symptoms when eaten during the luteal phase of your cycle.

Top PMS-Fighting Nutrients:
- Magnesium: Dark chocolate, spinach, pumpkin seeds — reduces cramps and mood swings
- Calcium: Yogurt, kale, fortified milk — reduces bloating and fatigue
- Vitamin B6: Bananas, chickpeas, potatoes — helps with mood regulation
- Omega-3: Salmon, walnuts, flaxseed — reduces inflammation and pain
- Iron: Lean red meat, lentils, spinach — combats fatigue

Foods to Avoid Before Your Period:
- Excess salt (increases bloating)
- Caffeine (worsens anxiety and breast tenderness)
- Alcohol (disrupts sleep and mood)
- Processed sugar (causes energy crashes)''',
    ),
    WellnessArticle(
      id: 'art_exercise_hormones',
      title: 'Exercise & Your Hormones: A Cycle-Synced Guide',
      readMins: 7,
      category: 'exercise',
      excerptText: 'Your ideal workout changes with your cycle phase. Learn how to sync your exercise...',
      fullText: '''Your ideal workout changes with your cycle phase. Syncing exercise to your hormones maximizes results and minimizes stress.

Menstruation (Days 1-5): REST & GENTLE MOVEMENT
- Light walking, gentle yoga, stretching
- Your body is doing important work — honor it

Follicular Phase (Days 6-13): BUILD ENERGY
- Cardio, dance, running, cycling
- Rising estrogen boosts endurance and motivation

Ovulation (Days 14-16): PEAK PERFORMANCE
- HIIT, strength training, group sports
- You're at your strongest and most social

Luteal Phase (Days 17-28): MODERATE & MINDFUL
- Pilates, swimming, moderate strength training
- Progesterone rises — focus on form, not intensity

For PCOS: Prioritize strength training and walking. Avoid extreme cardio that spikes cortisol.
For PMS: Gentle movement during the last week helps more than rest alone.''',
    ),
    WellnessArticle(
      id: 'art_sleep_hormones',
      title: 'Sleep & Hormonal Health: What You Need to Know',
      readMins: 5,
      category: 'sleep',
      excerptText: 'Quality sleep is one of the most underrated tools for hormonal balance...',
      fullText: '''Quality sleep is one of the most underrated tools for hormonal balance. Your body repairs and regulates hormones primarily during deep sleep.

Why Sleep Matters for Your Hormones:
- Growth hormone peaks during deep sleep
- Cortisol resets overnight (poor sleep = high cortisol = hormonal chaos)
- Melatonin supports reproductive hormone regulation
- Insulin sensitivity improves with 7-9 hours of quality sleep

Sleep Hygiene Tips:
1. Keep a consistent bedtime (even on weekends)
2. Avoid screens 1 hour before bed
3. Keep your room cool (65-68°F / 18-20°C)
4. Magnesium before bed can improve sleep quality
5. Avoid caffeine after 2 PM
6. Use gentle stretching or breathwork before bed''',
    ),
    WellnessArticle(
      id: 'art_stress_cortisol',
      title: 'Stress, Cortisol & Your Cycle',
      readMins: 6,
      category: 'mindfulness',
      excerptText: 'Chronic stress disrupts your menstrual cycle through elevated cortisol levels...',
      fullText: '''Chronic stress disrupts your menstrual cycle through elevated cortisol levels. Understanding this connection is the first step to breaking the cycle.

How Stress Affects Your Period:
- High cortisol suppresses GnRH, disrupting ovulation
- Stress can delay or skip periods entirely
- Chronic stress worsens PMS/PMDD symptoms
- Cortisol competes with progesterone, creating imbalance

Evidence-Based Stress Management:
1. 4-7-8 Breathing (reduces cortisol in minutes)
2. Progressive muscle relaxation
3. Mindful walking in nature
4. Journaling for 10 minutes daily
5. Social connection (oxytocin counters cortisol)
6. Setting boundaries and saying "no"

For PCOS: Stress management is especially critical — cortisol worsens insulin resistance.
For PMDD: Stress amplifies emotional symptoms. Daily mindfulness practice is strongly recommended.''',
    ),
    WellnessArticle(
      id: 'art_supplements_pcos',
      title: 'Supplements for PCOS: Evidence-Based Guide',
      readMins: 7,
      category: 'nutrition',
      conditions: ['pcos', 'pcod'],
      excerptText: 'Several supplements have strong clinical evidence for managing PCOS symptoms...',
      fullText: '''Several supplements have strong clinical evidence for managing PCOS symptoms. Always consult your doctor before starting any supplement.

Top Evidence-Based Supplements:
1. Inositol (Myo + D-Chiro): Improves insulin sensitivity and ovulation. Take 4g Myo + 100mg D-Chiro daily.
2. Vitamin D: Most PCOS women are deficient. Supports insulin function and mood.
3. Omega-3: Reduces inflammation and improves lipid profiles.
4. NAC (N-Acetyl Cysteine): Antioxidant that improves insulin sensitivity.
5. Berberine: Natural alternative to metformin for blood sugar management.
6. Zinc: Supports skin health (acne) and hair growth.
7. Magnesium: Reduces insulin resistance and improves sleep.

Important: Supplements work best alongside diet and lifestyle changes, not as replacements.''',
    ),
    WellnessArticle(
      id: 'art_pmdd_understanding',
      title: 'Understanding PMDD: More Than "Bad PMS"',
      readMins: 8,
      category: 'mindfulness',
      conditions: ['pmdd', 'pms'],
      excerptText: 'PMDD is a real medical condition affecting 5-8% of menstruating women...',
      fullText: '''PMDD (Premenstrual Dysphoric Disorder) is a real medical condition affecting 5-8% of menstruating women. It is NOT just "bad PMS."

Key Differences from PMS:
- PMDD symptoms are severe enough to disrupt daily life
- Emotional symptoms dominate (severe depression, anxiety, rage)
- Symptoms appear in the luteal phase and resolve within days of period starting
- PMDD is linked to sensitivity to normal progesterone fluctuations

Getting Help:
1. Track your symptoms for 2+ cycles (this app helps!)
2. Share your symptom log with a doctor
3. Treatment options include SSRIs (effective in 60-70% of cases), hormonal therapy, and CBT
4. Lifestyle modifications (exercise, diet, sleep) provide meaningful relief
5. Peer support groups can reduce isolation

You are not "overreacting." Your brain is processing normal hormonal changes differently. This is biology, not a character flaw.''',
    ),
    WellnessArticle(
      id: 'art_cycle_syncing',
      title: 'Cycle Syncing: Living in Harmony With Your Hormones',
      readMins: 6,
      category: 'guides',
      excerptText: 'Cycle syncing means adapting your diet, exercise, work, and social life to your menstrual phases...',
      fullText: '''Cycle syncing means adapting your diet, exercise, work, and social life to your menstrual phases for optimal wellbeing.

Phase 1 - Menstruation (Inner Winter):
- Rest, reflect, plan
- Nourishing warm foods, iron-rich meals
- Gentle yoga, walks, journaling

Phase 2 - Follicular (Inner Spring):
- Start new projects, brainstorm
- Fresh salads, fermented foods, light proteins
- Try new workouts, increase intensity gradually

Phase 3 - Ovulation (Inner Summer):
- Social events, presentations, difficult conversations
- Raw foods, anti-inflammatory meals
- High-intensity workouts, group classes

Phase 4 - Luteal (Inner Autumn):
- Complete tasks, organize, nest
- Complex carbs, magnesium-rich foods
- Moderate exercise, pilates, swimming

The key insight: There is no "ideal" state. Each phase has unique strengths.''',
    ),
    WellnessArticle(
      id: 'art_irregular_causes',
      title: 'Why Your Period Is Irregular: Common Causes',
      readMins: 5,
      category: 'guides',
      conditions: ['irregular'],
      excerptText: 'Irregular periods can have many causes, from stress to underlying conditions...',
      fullText: '''Irregular periods can have many causes, from stress to underlying conditions. Understanding the cause helps you find the right solution.

Common Causes:
1. Stress: The #1 cause of temporary irregularity
2. Weight changes: Both gain and loss affect hormones
3. PCOS: The most common hormonal cause
4. Thyroid disorders: Both hypo and hyper affect cycles
5. Birth control: Starting or stopping can cause months of irregularity
6. Excessive exercise: Can suppress ovulation
7. Perimenopause: Cycles change in your 40s
8. Illness or travel: Temporary disruption is normal

When to See a Doctor:
- No period for 3+ months
- Sudden change in cycle pattern
- Extremely heavy bleeding
- Severe pain with periods
- Bleeding between periods''',
    ),
    WellnessArticle(
      id: 'art_mental_health_cycle',
      title: 'Your Mental Health Across the Menstrual Cycle',
      readMins: 7,
      category: 'mindfulness',
      excerptText: 'Your mental health naturally fluctuates with your hormonal cycle. Understanding this pattern...',
      fullText: '''Your mental health naturally fluctuates with your hormonal cycle. Understanding this pattern empowers you to prepare and cope.

Hormonal Mood Map:
- Menstruation: Low estrogen + progesterone. Tendency toward introspection, sometimes sadness. Self-care is key.
- Follicular: Rising estrogen. Mood brightens, optimism increases, creativity peaks.
- Ovulation: Peak estrogen. Social confidence, verbal fluency, and libido peak.
- Luteal: Progesterone rises then falls. Anxiety, irritability, or sadness may increase. This is where PMS/PMDD symptoms appear.

What You Can Do:
1. Track your mood daily (even a simple 1-5 rating helps)
2. Plan demanding tasks during follicular/ovulation phases
3. Reduce commitments during late luteal phase
4. Practice self-compassion during difficult days
5. Seek professional help if mood disruptions are severe

Remember: Feeling different across your cycle is NORMAL. You are not broken.''',
    ),
    WellnessArticle(
      id: 'art_endometriosis',
      title: 'Understanding Endometriosis',
      readMins: 8,
      category: 'guides',
      excerptText: 'Endometriosis affects 1 in 10 women. Understanding the condition is the first step to managing it...',
      fullText: '''Endometriosis affects 1 in 10 women of reproductive age. It occurs when tissue similar to the uterine lining grows outside the uterus.

Common Symptoms:
- Severe period pain that worsens over time
- Pain during or after sex
- Heavy periods or bleeding between periods
- Fatigue that doesn't improve with rest
- Digestive issues (bloating, nausea, constipation)
- Difficulty getting pregnant

Getting Diagnosed:
- Average diagnosis takes 7-10 years
- Track your symptoms in detail (this app helps!)
- Ultrasound can detect some forms
- Laparoscopy is the gold standard for diagnosis

Management Options:
1. Pain management (NSAIDs, heat therapy)
2. Hormonal treatments (birth control, GnRH agonists)
3. Surgery (laparoscopic excision)
4. Diet: Anti-inflammatory foods, reduce gluten and dairy
5. Exercise: Gentle movement reduces pain and inflammation
6. Stress management: Crucial, as stress worsens symptoms''',
    ),
    WellnessArticle(
      id: 'art_hormonal_acne',
      title: 'Hormonal Acne: A Cycle-Based Approach',
      readMins: 6,
      category: 'guides',
      conditions: ['pcos', 'pcod'],
      excerptText: 'Breakouts that follow your menstrual cycle are driven by hormones, not hygiene...',
      fullText: '''Breakouts that follow your menstrual cycle are driven by hormones, not hygiene. Understanding when and why they happen gives you power to prevent them.

The Hormonal Acne Pattern:
- Follicular phase: Skin clears as estrogen rises
- Ovulation: Estrogen peaks \u2014 your best skin days
- Luteal phase: Progesterone rises, increases oil production
- Pre-period: Testosterone ratio increases \u2014 breakout zone

Cycle-Synced Skincare:
- Follicular: Gentle exfoliation (AHA/BHA 2x/week)
- Ovulation: Minimal routine, skin is at its best
- Luteal: Oil-free moisturiser, niacinamide, salicylic acid
- Pre-period: Spot treat, avoid touching face, clean pillowcases

Diet for Clear Skin:
- Reduce dairy and refined sugar
- Zinc-rich foods (pumpkin seeds, chickpeas)
- Omega-3 fatty acids (salmon, walnuts)
- Green tea (anti-androgenic properties)

For PCOS: Elevated androgens are a root cause. Address insulin resistance to reduce hormonal acne at its source.''',
    ),
    WellnessArticle(
      id: 'art_fertility_awareness',
      title: 'Fertility Awareness Method Explained',
      readMins: 7,
      category: 'guides',
      excerptText: 'Understanding your fertility signs helps you plan or prevent pregnancy naturally...',
      fullText: '''Understanding your fertility signs helps you plan or prevent pregnancy naturally. The Fertility Awareness Method (FAM) uses observable body signs to identify your fertile window.

The Three Key Signs:
1. Basal Body Temperature (BBT): Temperature rises 0.2-0.5\u00b0C after ovulation and stays elevated until your period
2. Cervical Mucus: Changes from dry/sticky to wet/egg-white consistency near ovulation
3. Cervical Position: Shifts from low/firm to high/soft around ovulation

The Fertile Window:
- Sperm can survive up to 5 days in fertile mucus
- The egg lives 12-24 hours after ovulation
- Your fertile window is approximately 6 days per cycle

Getting Started:
1. Track your cycle for 3+ months before relying on FAM
2. Take BBT every morning before getting out of bed
3. Check cervical mucus daily
4. Use this app to log symptoms and identify patterns

Important: FAM requires consistency and education. Consider working with a certified instructor. It is NOT recommended as sole contraception without proper training.''',
    ),
  ];
}
