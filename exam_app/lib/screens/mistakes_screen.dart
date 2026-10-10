import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/engine.dart';
import '../services/store.dart';
import '../theme/app_theme.dart';
import 'exam_screen.dart';

/// شاشة بنك الأخطاء: كل سؤال أُجيب عنه خطأ يبقى هنا مع
/// الإجابة الصحيحة والشرح والمرجع من الكتاب، حتى تُتقنه.
class MistakesScreen extends StatelessWidget {
  final List<Question> questions;
  final MistakeStore store;

  const MistakesScreen({
    super.key,
    required this.questions,
    required this.store,
  });

  List<Question> get mistakeQuestions =>
      questions.where((q) => store.ids.contains(q.id)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final list = mistakeQuestions;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_forward_rounded,
                              color: AppTheme.ink),
                        ),
                        const Expanded(
                          child: Text(
                            'بنك الأسئلة الخطأ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  if (list.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.rose,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            final exam =
                                ExamEngine.buildExam(list, list.length);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExamScreen(
                                  exam: exam,
                                  bank: questions,
                                  store: store,
                                  title: 'امتحان من الأخطاء',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(
                              'امتحان جديد من أخطائك (${list.length})',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.party_mode_rounded,
                                    size: 70, color: AppTheme.mint),
                                SizedBox(height: 12),
                                Text('لا توجد أخطاء محفوظة — رائع!',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.ink)),
                                SizedBox(height: 6),
                                Text(
                                    'كل سؤال تخطئين به سيُحفظ هنا تلقائياً مع حله ومرجعه.',
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppTheme.inkDim)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 20),
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final q = list[i];
                              return _mistakeCard(context, q);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _mistakeCard(BuildContext context, Question q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.q,
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    height: 1.8)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppTheme.mint.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.mint, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الإجابة الصحيحة: ${q.options[q.answer]}',
                      style: const TextStyle(
                          color: AppTheme.mint,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(q.explain,
                style: const TextStyle(
                    color: AppTheme.inkDim, fontSize: 13, height: 1.8)),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined,
                      color: AppTheme.gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('الدليل من الكتاب: ${q.ref}',
                        style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            height: 1.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => store.remove(q.id),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('أتقنتُه — احذفه من البنك'),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.mint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
