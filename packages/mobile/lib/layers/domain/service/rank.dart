/// 段位 (rank) 計算。
///
/// packages/web/src/lib/rank.ts のロジックを Dart に移植したもの。
/// server (`GET /api/me/mastery`) の streak を入力に、
/// 4級 → … → 名人 の 14 段階を返す。
///
/// 純関数のみ。副作用なし。テスト容易性のために state は持たない。
library;

const int streakCap = 2;

/// 段位ラベル (低い順)。
const List<String> rankLabels = [
  '4級',
  '3級',
  '2級',
  '1級',
  '初段',
  '二段',
  '三段',
  '四段',
  '五段',
  '六段',
  '七段',
  '八段',
  '九段',
  '名人',
];

class RankResult {
  const RankResult({
    required this.rank,
    required this.index,
    required this.mastery,
    required this.totalPossible,
    required this.progress,
    required this.nextRank,
    required this.toNextRank,
  });

  final String rank;
  final int index;
  final int mastery;
  final int totalPossible;
  final double progress;
  final String? nextRank;
  final int toNextRank;
}

/// [streaks] に含まれない quizId は連続正解 0、[quizIds] に含まれない
/// streak は集計対象外 (非公開/削除された問題は自動で外す)。
RankResult computeRank(Map<int, int> streaks, List<int> quizIds) {
  final totalPossible = quizIds.length * streakCap;
  if (totalPossible == 0) {
    return RankResult(
      rank: '4級',
      index: 0,
      mastery: 0,
      totalPossible: 0,
      progress: 0,
      nextRank: rankLabels.length > 1 ? rankLabels[1] : null,
      toNextRank: 0,
    );
  }

  var mastery = 0;
  for (final id in quizIds) {
    final raw = streaks[id];
    if (raw == null) continue;
    final clamped = raw.clamp(0, streakCap);
    mastery += clamped;
  }

  final progress = mastery / totalPossible;
  final index = _resolveRankIndex(mastery, totalPossible);
  final rank = index < rankLabels.length ? rankLabels[index] : '4級';
  final nextIndex = index + 1;
  final nextRank = nextIndex < rankLabels.length ? rankLabels[nextIndex] : null;
  final toNextRank =
      nextRank == null ? 0 : _masteryToReachIndex(nextIndex, totalPossible) - mastery;

  return RankResult(
    rank: rank,
    index: index,
    mastery: mastery,
    totalPossible: totalPossible,
    progress: progress,
    nextRank: nextRank,
    toNextRank: toNextRank < 0 ? 0 : toNextRank,
  );
}

int _resolveRankIndex(int mastery, int totalPossible) {
  if (mastery >= totalPossible) return rankLabels.length - 1;
  const subMasterLevels = 13; // rankLabels.length - 1
  final step = totalPossible / subMasterLevels;
  if (step <= 0) return 0;
  final raw = (mastery / step).floor();
  return raw.clamp(0, subMasterLevels - 1);
}

int _masteryToReachIndex(int index, int totalPossible) {
  if (index >= rankLabels.length - 1) return totalPossible;
  const subMasterLevels = 13;
  final step = totalPossible / subMasterLevels;
  return (step * index).ceil();
}
