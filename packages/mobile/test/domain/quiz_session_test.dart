import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';

const _sample = [
  Quiz(
    id: 1,
    section: 'React',
    title: 'A',
    question: 'q',
    options: ['x', 'y'],
    correctAnswerIndex: 0,
    explanation: 'e',
    source: 's',
  ),
  Quiz(
    id: 2,
    section: 'Go',
    title: 'B',
    question: 'q',
    options: ['x', 'y'],
    correctAnswerIndex: 1,
    explanation: 'e',
    source: 's',
  ),
  Quiz(
    id: 3,
    section: 'React',
    title: 'C',
    question: 'q',
    options: ['x', 'y'],
    correctAnswerIndex: 0,
    explanation: 'e',
    source: 's',
  ),
];

void main() {
  group('quiz_session', () {
    test('filterBySection keeps only that section', () {
      expect(filterBySection(_sample, 'React').map((quiz) => quiz.id), [1, 3]);
      expect(filterBySection(_sample, null), hasLength(3));
    });

    test('pickQuizIds respects section and limit', () {
      final ids = pickQuizIds(_sample, 'React', 1, Random(1));
      expect(ids, hasLength(1));
      expect(ids.first, isIn([1, 3]));
    });

    test('isAnswerCorrect compares the index', () {
      expect(isAnswerCorrect(_sample[0], 0), isTrue);
      expect(isAnswerCorrect(_sample[0], 1), isFalse);
    });

    test('calculateAccuracy rounds percent', () {
      expect(calculateAccuracy(1, 2), 50);
      expect(calculateAccuracy(0, 0), 0);
    });
  });
}
