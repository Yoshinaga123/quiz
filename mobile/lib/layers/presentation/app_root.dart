import 'package:flutter/material.dart';
import 'package:quiz_mobile/layers/presentation/auth/login_page.dart';
import 'package:quiz_mobile/layers/presentation/theme.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/view/quiz_list_page.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    const theme = QuizTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Mobile',
      theme: theme.toThemeData(),
      home: _loggedIn
          ? const QuizListPage()
          : LoginPage(
              onSuccess: () {
                setState(() {
                  _loggedIn = true;
                });
              },
            ),
    );
  }
}
