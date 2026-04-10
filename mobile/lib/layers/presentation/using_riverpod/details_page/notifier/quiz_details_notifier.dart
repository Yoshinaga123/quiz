import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_details.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/notifier/quiz_details_state.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/providers.dart';

final quizDetailsStateProvider =
    StateNotifierProvider.autoDispose<QuizDetailsNotifier, QuizDetailsState>(
  (ref) => QuizDetailsNotifier(
    getQuizDetails: ref.read(getQuizDetailsProvider),
  ),
);

class QuizDetailsNotifier extends StateNotifier<QuizDetailsState> {
  QuizDetailsNotifier({
    required GetQuizDetails getQuizDetails,
  })  : _getQuizDetails = getQuizDetails,
        super(const QuizDetailsState());

  final GetQuizDetails _getQuizDetails;

  Future<void> load({required int id}) async {
    state = state.copyWith(
      status: QuizDetailsStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final quiz = await _getQuizDetails(id: id);
      state = state.copyWith(
        status: QuizDetailsStatus.success,
        quiz: quiz,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: QuizDetailsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}
