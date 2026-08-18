import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/presentation/member/member_profile_view.dart';

void main() {
  const member = PublicMemberDto(
    id: '0192b6f7-4c50-73b1-8b71-11223344aabb',
    handle: 'quiztaker_01',
  );

  final history = [
    AnswerHistoryEntryDto(
      id: 2,
      quizId: 42,
      selectedIndex: 1,
      isCorrect: true,
      answeredAt: DateTime.utc(2026, 8, 18, 12),
    ),
    AnswerHistoryEntryDto(
      id: 1,
      quizId: 42,
      selectedIndex: 0,
      isCorrect: false,
      answeredAt: DateTime.utc(2026, 8, 18, 11),
    ),
  ];

  testWidgets('会員 ID と履歴を表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MemberProfileView(member: member, history: history),
      ),
    );

    expect(find.text('quiztaker_01 さん'), findsOneWidget);
    expect(find.byKey(const Key('member-profile-id')), findsOneWidget);
    expect(find.text('Quiz #42'), findsNWidgets(2));
    expect(find.text('正解'), findsOneWidget);
    expect(find.text('不正解'), findsOneWidget);
  });

  testWidgets('履歴が空のときはメッセージを出す', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MemberProfileView(member: member, history: const []),
      ),
    );

    expect(find.text('まだ回答がありません。'), findsOneWidget);
  });

  testWidgets('ログアウトと退会のコールバックが発火する', (tester) async {
    var loggedOut = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MemberProfileView(
          member: member,
          history: const [],
          onLogout: () => loggedOut = true,
          onDeleteAccount: () => deleted = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('member-profile-logout')));
    await tester.tap(find.byKey(const Key('member-profile-delete')));
    await tester.pump();

    expect(loggedOut, isTrue);
    expect(deleted, isTrue);
  });
}
