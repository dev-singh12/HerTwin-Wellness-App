// Unit tests for HerTwin's pure business logic and content catalogues.
//
// These deliberately avoid Firebase: everything here runs without network,
// emulators or credentials, so CI can gate every push on them. Security rules
// are tested separately against Google's real Rules API — see
// `node tool/test_rules.js`.

import 'package:flutter_test/flutter_test.dart';

import 'package:her_twin_wellness/business/cycle_engine.dart';
import 'package:her_twin_wellness/business/scoring_engine.dart';
import 'package:her_twin_wellness/business/video_library.dart';
import 'package:her_twin_wellness/business/wellness_content_catalog.dart';

void main() {
  group('ScoringEngine', () {
    test('PCOS: a low total scores as PCOD, not full PCOS', () {
      final result = ScoringEngine.compute(
        conditionType: 'pcos',
        answers: {'pcos_q1': 1, 'pcos_q2': 1, 'pcos_q3': 1},
        age: 24,
      );
      expect(result.totalScore, 3);
      expect(result.diagnosisLabel.toLowerCase(), contains('pcod'));
    });

    test('worse symptoms never produce a better health score', () {
      final low = ScoringEngine.compute(
        conditionType: 'pcos',
        answers: {'pcos_q1': 1, 'pcos_q2': 1},
        age: 24,
      );
      final high = ScoringEngine.compute(
        conditionType: 'pcos',
        answers: {
          'pcos_q1': 2, 'pcos_q2': 2, 'pcos_q3': 2, 'pcos_q4': 2,
          'pcos_q5': 2, 'pcos_q6': 2, 'pcos_q7': 2, 'pcos_q8': 2,
        },
        age: 24,
      );
      expect(high.totalScore, greaterThan(low.totalScore));
      expect(high.healthScore, lessThanOrEqualTo(low.healthScore));
    });

    // Real question ids and counts, mirroring assessment_questions.dart.
    // Using the actual keys matters: the PCOS scorer keys its maximum off the
    // presence of `pcos_q9`, so synthetic ids would not exercise it.
    const questionSets = <String, ({String prefix, int count})>{
      'pcos': (prefix: 'pcos_q', count: 9),
      'pcod': (prefix: 'pcos_q', count: 8),
      'pms': (prefix: 'pms_q', count: 12),
      'pmdd': (prefix: 'pms_q', count: 12),
      'irregular': (prefix: 'irr_q', count: 5),
      'unknown': (prefix: 'unk_q', count: 8),
    };

    test('health score stays inside 0-100 for every condition and answer', () {
      questionSets.forEach((condition, set) {
        for (final value in [0, 1, 2, 3]) {
          final result = ScoringEngine.compute(
            conditionType: condition,
            answers: {
              for (var i = 1; i <= set.count; i++) '${set.prefix}$i': value
            },
            age: 27,
          );
          expect(result.healthScore, inInclusiveRange(0, 100),
              reason: '$condition with all-$value answers');
        }
      });
    });

    test('the reported total never exceeds the reported maximum', () {
      // A ratio like "24/16" would be nonsense on screen, so the invariant
      // must hold even if a question set grows past its hard-coded maximum.
      questionSets.forEach((condition, set) {
        for (final value in [0, 2, 3, 9]) {
          final result = ScoringEngine.compute(
            conditionType: condition,
            answers: {
              for (var i = 1; i <= set.count; i++) '${set.prefix}$i': value
            },
            age: 27,
          );
          expect(result.totalScore, lessThanOrEqualTo(result.maxScore),
              reason: '$condition total exceeded max at answer value $value');
        }
      });
    });

    test('empty answers do not crash and yield a usable result', () {
      final result = ScoringEngine.compute(
        conditionType: 'unknown',
        answers: const {},
        age: 30,
      );
      expect(result.totalScore, 0);
      expect(result.diagnosisLabel, isNotEmpty);
      expect(result.carePlanType, isNotEmpty);
    });
  });

  group('CycleEngine', () {
    test('with no logs it still returns a usable estimate', () {
      final status = CycleEngine.compute(const []);
      expect(status.hasData, isFalse);
      expect(status.cycleLength, CycleEngine.defaultCycleLength);
      expect(status.cycleDay, greaterThan(0));
      expect(status.vitalityScore, inInclusiveRange(0, 100));
    });

    test('next period falls after the cycle start', () {
      final status = CycleEngine.compute(const []);
      expect(status.nextPeriodDate.isAfter(status.cycleStart), isTrue);
    });

    test('every phase exposes display metadata', () {
      for (final phase in CyclePhase.values) {
        expect(phase.label, isNotEmpty);
        expect(phase.energyLevel, isNotEmpty);
        expect(phase.vitalityMessage, isNotEmpty);
      }
    });
  });

  group('VideoLibrary', () {
    test('ids are unique', () {
      final ids = VideoLibrary.videos.map((v) => v.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate video id');
    });

    test('every entry has a well-formed YouTube id and attribution', () {
      for (final v in VideoLibrary.videos) {
        // YouTube ids are 11 chars of [A-Za-z0-9_-]. This catches a truncated
        // or pasted-wrong id before it ships as a dead embed.
        expect(RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(v.youtubeId), isTrue,
            reason: '${v.id} has a malformed youtubeId: "${v.youtubeId}"');
        expect(v.channel, isNotEmpty, reason: '${v.id} is missing attribution');
        expect(v.title, isNotEmpty);
        expect(v.durationMins, greaterThan(0));
      }
    });

    test('thumbnail and watch URLs point at the same video', () {
      for (final v in VideoLibrary.videos) {
        expect(v.thumbnailUrl, contains(v.youtubeId));
        expect(v.watchUrl, contains(v.youtubeId));
      }
    });

    test('category filter only returns that category', () {
      for (final c in ['yoga', 'meditation', 'breathwork']) {
        final items = VideoLibrary.byCategory(c);
        expect(items, isNotEmpty, reason: 'no videos in $c');
        expect(items.every((v) => v.category == c), isTrue);
      }
    });

    test('condition ordering surfaces matches first without dropping any', () {
      final ordered = VideoLibrary.forCondition('pcos');
      expect(ordered.length, VideoLibrary.videos.length);
      final firstNonMatch =
          ordered.indexWhere((v) => !v.conditions.contains('pcos'));
      if (firstNonMatch != -1) {
        final tail = ordered.sublist(firstNonMatch);
        expect(tail.any((v) => v.conditions.contains('pcos')), isFalse,
            reason: 'a pcos video appeared after an untagged one');
      }
    });

    test('byId round-trips and returns null for unknown ids', () {
      final first = VideoLibrary.videos.first;
      expect(VideoLibrary.byId(first.id)?.youtubeId, first.youtubeId);
      expect(VideoLibrary.byId('does_not_exist'), isNull);
    });
  });

  group('WellnessContentCatalog', () {
    test('content ids are unique across all categories', () {
      final ids = [
        ...WellnessContentCatalog.yogaContents,
        ...WellnessContentCatalog.mindfulnessContents,
        ...WellnessContentCatalog.meditationContents,
      ].map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate content id');
    });

    test('article ids are unique and articles have body text', () {
      final ids = WellnessContentCatalog.articles.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final a in WellnessContentCatalog.articles) {
        expect(a.fullText.trim(), isNotEmpty, reason: '${a.id} has no body');
        expect(a.readMins, greaterThan(0));
      }
    });

    test('recommendations are returned for every cycle phase', () {
      for (final phase in CyclePhase.values) {
        final items = WellnessContentCatalog.forConditionAndPhase(
          condition: 'pcos',
          phase: phase,
        );
        expect(items, isNotEmpty, reason: 'no content for ${phase.name}');
      }
    });
  });
}
