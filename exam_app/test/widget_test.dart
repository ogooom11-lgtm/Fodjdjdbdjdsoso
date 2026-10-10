import 'package:flutter_test/flutter_test.dart';
import 'package:hijaiya_exam/models/question.dart';
import 'package:hijaiya_exam/services/engine.dart';

void main() {
  List<Question> pool(int n) => List.generate(
        n,
        (i) => Question(
          id: 't$i',
          set: 'mine',
          type: 'mcq',
          q: 'سؤال $i',
          options: const ['أ', 'ب', 'ج', 'د'],
          answer: 0,
          explain: 'شرح',
          ref: 'مرجع',
        ),
      );

  test('buildExam يختار العدد المطلوب دون تكرار', () {
    final exam = ExamEngine.buildExam(pool(10), 5);
    expect(exam.length, 5);
    expect(exam.map((q) => q.id).toSet().length, 5);
  });

  test('buildExam بخيار كل الأسئلة يعيد الكل بترتيب عشوائي', () {
    final exam = ExamEngine.buildExam(pool(10), 0);
    expect(exam.length, 10);
    expect(exam.map((q) => q.id).toSet().length, 10);
  });

  test('buildExam على مجموعة فارغة يعيد قائمة فارغة', () {
    expect(ExamEngine.buildExam(const [], 5), isEmpty);
  });

  test('Question.fromJson يقرأ الحقول كاملة', () {
    final q = Question.fromJson(const {
      'id': 'x',
      'set': 'user',
      'type': 'tf',
      'q': 'عبارة',
      'options': ['صحيحة', 'خاطئة'],
      'answer': 1,
      'explain': 'شرح',
      'ref': 'المطبوعة 20 / PDF 16',
    });
    expect(q.id, 'x');
    expect(q.type, 'tf');
    expect(q.answer, 1);
    expect(q.options, ['صحيحة', 'خاطئة']);
  });
}
