/// نموذج السؤال المستخدم في كامل التطبيق.
class Question {
  final String id;

  /// 'mine' = أسئلة ملخصات الكتاب، 'user' = أسئلة ورقة المعلمة.
  final String set;

  /// 'mcq' أو 'tf'
  final String type;
  final String q;
  final List<String> options;
  final int answer;
  final String explain;

  /// المرجع من الكتاب (رقم الصفحة المطبوعة ورقم صفحة PDF).
  final String ref;

  const Question({
    required this.id,
    required this.set,
    required this.type,
    required this.q,
    required this.options,
    required this.answer,
    required this.explain,
    required this.ref,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    return Question(
      id: j['id'] as String,
      set: j['set'] as String,
      type: j['type'] as String,
      q: j['q'] as String,
      options: List<String>.from(j['options'] as List),
      answer: j['answer'] as int,
      explain: j['explain'] as String,
      ref: j['ref'] as String,
    );
  }
}
