import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_list.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/notifier/quiz_list_state.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/providers.dart';

final quizListStateProvider =
    StateNotifierProvider<QuizListNotifier, QuizListState>(
  (ref) => QuizListNotifier(
    getQuizList: ref.read(getQuizListProvider),
  ),
);

class QuizListNotifier extends StateNotifier<QuizListState> {
  QuizListNotifier({
    required GetQuizList getQuizList,
  })  : _getQuizList = getQuizList,
        super(const QuizListState());

  final GetQuizList _getQuizList;

  Future<void> load() async {
    state = state.copyWith(
      status: QuizListStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final quizzes = await _getQuizList();
      state = state.copyWith(
        status: QuizListStatus.success,
        quizzes: quizzes,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: QuizListStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}
