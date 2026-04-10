import 'package:flutter/material.dart';
import 'package:quiz_mobile/layers/presentation/theme.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/view/quiz_list_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = QuizTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Mobile',
      theme: theme.toThemeData(),
      home: const QuizListPage(),
    );
  }
}
