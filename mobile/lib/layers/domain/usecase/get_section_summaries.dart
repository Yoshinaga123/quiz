import 'package:quiz_mobile/layers/domain/entity/section_summary.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_section_repository.dart';

class GetSectionSummaries {
  GetSectionSummaries({
    required QuizSectionRepository repository,
  }) : _repository = repository;

  final QuizSectionRepository _repository;

  Future<List<SectionSummary>> call() {
    return _repository.getSectionSummaries();
  }
}
