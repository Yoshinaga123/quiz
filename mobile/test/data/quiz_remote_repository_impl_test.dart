import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/public_quiz_dto.dart';
import 'package:quiz_mobile/layers/data/dto/section_summary_dto.dart';
import 'package:quiz_mobile/layers/data/quiz_remote_repository_impl.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_remote_data_source.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

class _FakeRemoteDataSource implements QuizRemoteDataSource {
  _FakeRemoteDataSource({
    this.list,
    this.details,
    this.sections,
    this.errorOnList,
    this.errorOnDetails,
    this.errorOnSections,
  });

  final List<PublicQuizDto>? list;
  final PublicQuizDto? details;
  final List<SectionSummaryDto>? sections;
  final Object? errorOnList;
  final Object? errorOnDetails;
  final Object? errorOnSections;

  int callsToList = 0;
  int callsToDetails = 0;
  int callsToSections = 0;

  @override
  Future<List<PublicQuizDto>> fetchQuizList({String? section, int? limit}) async {
    callsToList++;
    if (errorOnList != null) throw errorOnList!;
    return list ?? const [];
  }

  @override
  Future<PublicQuizDto> fetchQuizDetails({required int id}) async {
    callsToDetails++;
    if (errorOnDetails != null) throw errorOnDetails!;
    return details!;
  }

  @override
  Future<List<SectionSummaryDto>> fetchSectionSummaries() async {
    callsToSections++;
    if (errorOnSections != null) throw errorOnSections!;
    return sections ?? const [];
  }
}

const _sampleDto = PublicQuizDto(
  id: 1,
  section: 'React',
  title: 't',
  question: 'q',
  options: ['a', 'b'],
  correctAnswerIndex: 1,
  explanation: 'e',
  source: 's',
);

void main() {
  group('QuizRemoteRepositoryImpl', () {
    test('getQuizList は DTO を Quiz エンティティ列に変換する', () async {
      final fake = _FakeRemoteDataSource(list: const [_sampleDto, _sampleDto]);
      final repo = QuizRemoteRepositoryImpl(remoteDataSource: fake);

      final result = await repo.getQuizList();

      expect(fake.callsToList, 1);
      expect(result, hasLength(2));
      expect(result.first.id, 1);
      expect(result.first.section, 'React');
    });

    test('getQuizDetails は DTO を Quiz エンティティに変換する', () async {
      final fake = _FakeRemoteDataSource(details: _sampleDto);
      final repo = QuizRemoteRepositoryImpl(remoteDataSource: fake);

      final result = await repo.getQuizDetails(id: 1);

      expect(fake.callsToDetails, 1);
      expect(result.id, 1);
      expect(result.correctAnswer, 'b');
    });

    test('getSectionSummaries は DTO を SectionSummary 列に変換する', () async {
      final fake = _FakeRemoteDataSource(
        sections: const [
          SectionSummaryDto(section: 'React', count: 5),
          SectionSummaryDto(section: 'CSS', count: 2),
        ],
      );
      final repo = QuizRemoteRepositoryImpl(remoteDataSource: fake);

      final result = await repo.getSectionSummaries();

      expect(fake.callsToSections, 1);
      expect(result, hasLength(2));
      expect(result.first.section, 'React');
      expect(result.first.count, 5);
    });

    test('データソースの QuizFailure はそのまま透過する', () async {
      final fake = _FakeRemoteDataSource(
        errorOnDetails: const QuizNotFoundFailure(message: 'no quiz 99'),
      );
      final repo = QuizRemoteRepositoryImpl(remoteDataSource: fake);

      await expectLater(
        () => repo.getQuizDetails(id: 99),
        throwsA(isA<QuizNotFoundFailure>()),
      );
    });
  });
}
