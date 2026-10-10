import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/question.dart';
import 'screens/home_screen.dart';
import 'services/store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // تحميل بنك الأسئلة من الأصول.
  final raw = await rootBundle.loadString('assets/questions.json');
  final questions = (jsonDecode(raw) as List)
      .map((e) => Question.fromJson(e as Map<String, dynamic>))
      .toList();

  final store = MistakeStore();
  await store.load();

  runApp(HijaiyaApp(questions: questions, store: store));
}

class HijaiyaApp extends StatelessWidget {
  final List<Question> questions;
  final MistakeStore store;

  const HijaiyaApp({super.key, required this.questions, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'امتحان الدروس الهجائية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: HomeScreen(questions: questions, store: store),
    );
  }
}
