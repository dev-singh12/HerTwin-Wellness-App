import 'package:flutter/material.dart';

/// A curated, real YouTube video in the wellness library.
///
/// Every [youtubeId] here was checked against YouTube's oEmbed endpoint and
/// confirmed public and embeddable at the time of writing. Do not add an id
/// without verifying it the same way — a dead embed is worse than no card.
///
/// Attribution matters: [channel] is shown on every card and on the player
/// screen, and the player offers a "watch on YouTube" link so creators get
/// the traffic.
class WellnessVideo {
  const WellnessVideo({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.channel,
    required this.durationMins,
    required this.category,
    required this.description,
    this.conditions = const ['all'],
    this.accent = const Color(0xFFEFA6B3),
  });

  final String id;
  final String title;
  final String youtubeId;
  final String channel;
  final int durationMins;

  /// 'yoga' | 'meditation' | 'breathwork'
  final String category;

  final String description;

  /// Condition tags this video is most relevant to: pcos, pcod, pms, pmdd,
  /// irregular, or 'all'.
  final List<String> conditions;

  final Color accent;

  /// YouTube's own thumbnail CDN. hqdefault exists for every public video.
  String get thumbnailUrl =>
      'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg';

  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeId';
}

class VideoLibrary {
  VideoLibrary._();

  static const _pink = Color(0xFFEFA6B3);
  static const _indigo = Color(0xFF9FA8DA);
  static const _mint = Color(0xFF7BC47F);

  static const videos = <WellnessVideo>[
    // --- Yoga: PCOS / PCOD / hormonal ---------------------------------------
    WellnessVideo(
      id: 'vid_pcos_bothra',
      title: '25-Minute Yoga for PCOS and PCOD',
      youtubeId: '9K8SZpdMkOQ',
      channel: 'Saurabh Bothra',
      durationMins: 25,
      category: 'yoga',
      conditions: ['pcos', 'pcod'],
      description:
          'A guided asana sequence aimed at hormone balance and insulin '
          'sensitivity. Good starting point if you are new to yoga for PCOS.',
      accent: _pink,
    ),
    WellnessVideo(
      id: 'vid_pcos_satvic',
      title: 'Yoga for PCOD/PCOS with Diet & Lifestyle Tips',
      youtubeId: 'zRWUrWPWD2Y',
      channel: 'Satvic Yoga',
      durationMins: 30,
      category: 'yoga',
      conditions: ['pcos', 'pcod', 'irregular'],
      description:
          'Combines a movement practice with practical diet and daily-routine '
          'guidance for irregular cycles.',
      accent: _pink,
    ),
    WellnessVideo(
      id: 'vid_pcos_bharti',
      title: 'Yoga for PCOS & Hormonal Balance — Metabolism Reset',
      youtubeId: 'aNfZtHu4ckI',
      channel: 'Bharti Yoga',
      durationMins: 30,
      category: 'yoga',
      conditions: ['pcos', 'pcod'],
      description:
          'Full-body 30-minute flow targeting fatigue, sluggish metabolism '
          'and irregular periods.',
      accent: _pink,
    ),
    WellnessVideo(
      id: 'vid_pcos_agnes_1',
      title: 'Yoga for PCOS & Irregular Periods — Part 1',
      youtubeId: '5JvbjrLESPs',
      channel: 'Akshaya Agnes',
      durationMins: 20,
      category: 'yoga',
      conditions: ['pcos', 'pcod', 'irregular'],
      description:
          'The opening session of a well-followed series on asanas for '
          'hormonal imbalance.',
      accent: _pink,
    ),
    WellnessVideo(
      id: 'vid_pcos_agnes_relax',
      title: 'Relaxing Yoga for PCOS & Hormonal Imbalance',
      youtubeId: 'arnokQ2ZbO8',
      channel: 'Akshaya Agnes',
      durationMins: 22,
      category: 'yoga',
      conditions: ['pcos', 'pcod', 'irregular'],
      description:
          'A gentler, restorative session for low-energy days when a strong '
          'practice feels like too much.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_pcos_agnes_meditation',
      title: 'Yoga for PCOS with Healing Meditation',
      youtubeId: '4dFljTd6Hho',
      channel: 'Akshaya Agnes',
      durationMins: 28,
      category: 'yoga',
      conditions: ['pcos', 'pcod'],
      description:
          'Movement followed by a guided meditation to close the practice.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_hormone_shailendra',
      title: 'Hormonal Imbalance Exercise — PCOS Yoga',
      youtubeId: '73lagEa7lGo',
      channel: 'Yogaguru Shailendra',
      durationMins: 18,
      category: 'yoga',
      conditions: ['pcos', 'pcod', 'irregular'],
      description:
          'Targeted exercises for hormonal imbalance, taught step by step.',
      accent: _pink,
    ),
    WellnessVideo(
      id: 'vid_pcos_agnes_11',
      title: 'Yoga for PCOS, Irregular Periods & Hormone Balance',
      youtubeId: 'xRgNrqajWvo',
      channel: 'Akshaya Agnes',
      durationMins: 25,
      category: 'yoga',
      conditions: ['pcos', 'irregular'],
      description:
          'Later session in the series, with asanas focused on cycle '
          'regularity.',
      accent: _pink,
    ),

    // --- Yoga: periods, cramps, PMS ----------------------------------------
    WellnessVideo(
      id: 'vid_cramps_adriene',
      title: 'Yoga for Cramps and PMS',
      youtubeId: '4JaCcp39iVI',
      channel: 'Yoga With Adriene',
      durationMins: 20,
      category: 'yoga',
      conditions: ['pms', 'pmdd', 'all'],
      description:
          'A gentle, kind practice for the days when you are cramping or '
          'simply need looking after.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_women_adriene',
      title: 'Yoga For Women — Gentle Cycle Practice',
      youtubeId: 'iglbdN1tmF0',
      channel: 'Yoga With Adriene',
      durationMins: 25,
      category: 'yoga',
      conditions: ['all'],
      description:
          'Restorative sequence to practise before or during your period.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_period_kassandra',
      title: 'Yoga for Menstrual Cramps — Gentle Period Yoga',
      youtubeId: 'eZdwBl1yu14',
      channel: 'Yoga with Kassandra',
      durationMins: 20,
      category: 'yoga',
      conditions: ['pms', 'all'],
      description:
          'Slow, floor-based poses that ease cramping without demanding '
          'energy you may not have.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_period_yogini',
      title: 'Gentle Yoga During Your Period',
      youtubeId: 'TUUDDQq4Z44',
      channel: 'yoginimelbourne',
      durationMins: 25,
      category: 'yoga',
      conditions: ['pms', 'all'],
      description:
          '25 minutes of soft movement designed specifically for menstruation.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_cramps_adison',
      title: 'Yoga for Period Cramps',
      youtubeId: 'PYbhN9KBDwE',
      channel: 'Adison Briana',
      durationMins: 15,
      category: 'yoga',
      conditions: ['pms', 'all'],
      description: 'A short, targeted routine for cramp relief.',
      accent: _pink,
    ),

    // --- Meditation ---------------------------------------------------------
    WellnessVideo(
      id: 'vid_med_headspace_stress',
      title: 'Managing Stress in Uncertain Times',
      youtubeId: 'GsE0NHdLn5I',
      channel: 'Headspace',
      durationMins: 10,
      category: 'meditation',
      conditions: ['pms', 'pmdd', 'all'],
      description:
          'Guided ten minutes for spiralling thoughts, overthinking and '
          'worry.',
      accent: _mint,
    ),
    WellnessVideo(
      id: 'vid_med_headspace_10',
      title: 'A 10-Minute Meditation for Stress',
      youtubeId: 'lS0kcSNlULw',
      channel: 'Headspace',
      durationMins: 10,
      category: 'meditation',
      conditions: ['all'],
      description: 'A straightforward stress meditation from Headspace.',
      accent: _mint,
    ),
    WellnessVideo(
      id: 'vid_med_headspace_reset',
      title: 'Reset Your Mind in 10 Minutes',
      youtubeId: 'SHC1ZiUu-9E',
      channel: 'Headspace',
      durationMins: 10,
      category: 'meditation',
      conditions: ['all'],
      description: 'A soothing guided meditation for instant calm.',
      accent: _mint,
    ),
    WellnessVideo(
      id: 'vid_med_anxiety_mountain',
      title: 'Meditation for Anxiety and Overthinking',
      youtubeId: 'QnHgPgB45MQ',
      channel: 'Meditation Mountain',
      durationMins: 10,
      category: 'meditation',
      conditions: ['pmdd', 'pms'],
      description:
          'Brings gentle awareness to anxiety rather than fighting it — '
          'useful in the luteal phase.',
      accent: _mint,
    ),
    WellnessVideo(
      id: 'vid_med_goodful',
      title: '10-Minute Meditation For Anxiety',
      youtubeId: 'O-6f5wQXSu8',
      channel: 'Goodful',
      durationMins: 10,
      category: 'meditation',
      conditions: ['pmdd', 'pms', 'all'],
      description: 'A calm, clearly narrated anxiety meditation.',
      accent: _mint,
    ),
    WellnessVideo(
      id: 'vid_med_lavendaire',
      title: 'Release Stress & Anxiety — Total Body Relaxation',
      youtubeId: 'H_uc-uQ3Nkc',
      channel: 'Lavendaire',
      durationMins: 10,
      category: 'meditation',
      conditions: ['all'],
      description: 'Progressive relaxation through the whole body.',
      accent: _mint,
    ),

    // --- Breathwork ---------------------------------------------------------
    WellnessVideo(
      id: 'vid_breath_sandy',
      title: '4-7-8 Calm Breathing — 5 Minute Guided',
      youtubeId: 'IumIKwyx8pg',
      channel: 'Breathe With Sandy',
      durationMins: 5,
      category: 'breathwork',
      conditions: ['all'],
      description:
          'The 4-7-8 pattern guided in real time. Pairs with the in-app '
          'breathwork timer.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_breath_ohio',
      title: '4-7-8 Breathing for Anxiety',
      youtubeId: 'H6O0xX8jj1E',
      channel: 'Ohio State Wexner Medical Center',
      durationMins: 5,
      category: 'breathwork',
      conditions: ['pmdd', 'pms', 'all'],
      description:
          'A clinician-led explanation and practice from an academic medical '
          'centre.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_breath_handson_10',
      title: '4-7-8 Breathing — 10 Minutes of Deep Relaxation',
      youtubeId: 'LiUnFJ8P4gM',
      channel: 'Hands-On Meditation',
      durationMins: 10,
      category: 'breathwork',
      conditions: ['all'],
      description: 'A longer session for when five minutes is not enough.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_breath_handson_5',
      title: '4-7-8 Relaxing Breath Technique',
      youtubeId: '1Dv-ldGLnIY',
      channel: 'Hands-On Meditation',
      durationMins: 6,
      category: 'breathwork',
      conditions: ['all'],
      description: 'Extended-exhale pranayama, guided throughout.',
      accent: _indigo,
    ),
    WellnessVideo(
      id: 'vid_breath_tadb',
      title: 'Breathing Exercises to Relax or Fall Asleep Fast',
      youtubeId: 'j-1n3KJR1I8',
      channel: 'TAKE A DEEP BREATH',
      durationMins: 8,
      category: 'breathwork',
      conditions: ['all'],
      description: '4-7-8 mindfulness breathing aimed at getting to sleep.',
      accent: _indigo,
    ),
  ];

  static WellnessVideo? byId(String id) {
    for (final v in videos) {
      if (v.id == id) return v;
    }
    return null;
  }

  static List<WellnessVideo> byCategory(String category) =>
      videos.where((v) => v.category == category).toList();

  /// Videos ordered so the ones tagged for [condition] come first.
  static List<WellnessVideo> forCondition(String? condition) {
    if (condition == null || condition.isEmpty) return videos;
    final matched = <WellnessVideo>[];
    final rest = <WellnessVideo>[];
    for (final v in videos) {
      if (v.conditions.contains(condition)) {
        matched.add(v);
      } else {
        rest.add(v);
      }
    }
    return [...matched, ...rest];
  }
}
