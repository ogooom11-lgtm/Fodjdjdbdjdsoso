import 'dart:math';

import '../models/question.dart';

/// محرك الامتحان: اختيار عشوائي بدون تكرار داخل الامتحان الواحد.
class ExamEngine {
  static final Random _rnd = Random();

  /// يبني امتحاناً من [count] أسئلة مختارة عشوائياً من [pool]
  /// دون أي تكرار داخل الامتحان الواحد. إذا كانت [count] أكبر أو
  /// تساوي حجم المجموعة تُعاد كل الأسئلة بترتيب عشوائي.
  static List<Question> buildExam(List<Question> pool, int count) {
    if (pool.isEmpty) return const [];
    final list = List<Question>.of(pool)..shuffle(_rnd);
    if (count <= 0 || count >= list.length) return list;
    return list.sublist(0, count);
  }
}

/// خيارات عدد الأسئلة المتاحة في الواجهة (0 = كل الأسئلة).
const List<int> kCountChoices = [5, 10, 15, 20, 25, 0];

String countLabel(int c) => c == 0 ? 'كل الأسئلة' : '$c أسئلة';
