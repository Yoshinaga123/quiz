import 'dart:math';

import 'package:quiz_mobile/layers/domain/entity/quiz.dart';

const defaultPlayLimit = 5;
const maxPlayLimit = 20;

List<Quiz> filterBySection(List<Quiz> quizzes, String? section) {
  if (section == null || section.isEmpty) {
    return List<Quiz>.from(quizzes);
  }
  return quizzes.where((quiz) => quiz.section == section).toList();
}

List<Quiz> shuffleQuizzes(List<Quiz> quizzes, [Random? random]) {
  final next = List<Quiz>.from(quizzes);
  final rng = random ?? Random();
  for (var i = next.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = next[i];
    next[i] = next[j];
    next[j] = tmp;
  }
  return next;
}

List<int> pickQuizIds(
  List<Quiz> quizzes,
  String? section,
  int limit, [
  Random? random,
]) {
  final pool = shuffleQuizzes(filterBySection(quizzes, section), random);
  final take = limit.clamp(0, maxPlayLimit);
  return pool.take(take).map((quiz) => quiz.id).toList();
}

Quiz? findQuiz(List<Quiz> quizzes, int id) {
  for (final quiz in quizzes) {
    if (quiz.id == id) return quiz;
  }
  return null;
}

bool isAnswerCorrect(Quiz quiz, int selectedIndex) {
  return quiz.correctAnswerIndex == selectedIndex;
}

int calculateAccuracy(int correct, int total) {
  if (total <= 0) return 0;
  return ((correct / total) * 100).round();
}

String generateSessionId([DateTime? now]) {
  final stamp = (now ?? DateTime.now()).microsecondsSinceEpoch.toRadixString(36);
  final noise = Random().nextInt(1 << 32).toRadixString(36);
  return '$stamp-$noise';
}

String nowIso([DateTime? now]) {
  return (now ?? DateTime.now()).toUtc().toIso8601String();
}
