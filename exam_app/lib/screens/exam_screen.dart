import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/store.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  final List<Question> exam;

  /// كامل بنك الأسئلة (لتمريره لشاشة مراجعة الأخطاء).
  final List<Question> bank;
  final MistakeStore store;
  final String title;

  const ExamScreen({
    super.key,
    required this.exam,
    required this.bank,
    required this.store,
    required this.title,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen>
    with SingleTickerProviderStateMixin {
  int idx = 0;
  int? picked;
  bool locked = false;
  int score = 0;
  final List<bool> results = [];

  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1,
    );
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Question get q => widget.exam[idx];

  Future<void> pick(int i) async {
    if (locked) return;
    setState(() {
      picked = i;
      locked = true;
    });
    final correct = i == q.answer;
    results.add(correct);
    if (correct) {
      setState(() => score++);
      await widget.store.remove(q.id);
    } else {
      // يحفظ السؤال الخطأ في البنك مع إجابته وشرحه ومرجعه.
      await widget.store.add(q.id);
    }
    await _flip.reverse();
    if (mounted) await _flip.forward();
  }

  void next() {
    if (idx + 1 >= widget.exam.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            exam: widget.exam,
            bank: widget.bank,
            results: results,
            score: score,
            store: widget.store,
            title: widget.title,
          ),
        ),
      );
      return;
    }
    _flip.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        idx++;
        picked = null;
        locked = false;
      });
      _flip.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.exam.length;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              // الشريط العلوي
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded,
                              color: AppTheme.inkDim),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.mint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('العلامة: $score',
                              style: const TextStyle(
                                  color: AppTheme.mint,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedBuilder(
                        animation: _flip,
                        builder: (_, __) => LinearProgressIndicator(
                          value: (idx + (locked ? 1 : 0)) / total,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('السؤال ${idx + 1} من $total',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.inkDim)),
                  ],
                ),
              ),

              // جسم السؤال
              Expanded(
                child: AnimatedBuilder(
                  animation: _flip,
                  builder: (_, __) => Opacity(
                    opacity: _flip.value,
                    child: Transform.scale(
                      scale: 0.96 + 0.04 * _flip.value,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: [
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.gold.withValues(alpha: 0.16),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        q.type == 'tf'
                                            ? Icons.rule_rounded
                                            : Icons.quiz_rounded,
                                        color: AppTheme.gold,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      q.type == 'tf' ? 'صح أم خطأ' : 'اختيار',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  q.q,
                                  style: const TextStyle(
                                      fontSize: 17.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink,
                                      height: 1.8),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (int i = 0; i < q.options.length; i++)
                            _option(i),
                          if (locked) ...[
                            const SizedBox(height: 14),
                            _feedback(),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.gold,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18)),
                                ),
                                onPressed: next,
                                child: Text(
                                  idx + 1 >= total
                                      ? 'عرض النتيجة'
                                      : 'السؤال التالي',
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF241A05)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(int i) {
    final isCorrect = i == q.answer;
    final isPicked = i == picked;
    Color border = Colors.white.withValues(alpha: 0.12);
    Color? fill = AppTheme.cardSoft.withValues(alpha: 0.55);
    IconData? trail;
    if (locked) {
      if (isCorrect) {
        border = AppTheme.mint;
        fill = AppTheme.mint.withValues(alpha: 0.14);
        trail = Icons.check_circle_rounded;
      } else if (isPicked) {
        border = AppTheme.rose;
        fill = AppTheme.rose.withValues(alpha: 0.14);
        trail = Icons.cancel_rounded;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => pick(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 1.4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    q.options[i],
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                      height: 1.7,
                    ),
                  ),
                ),
                if (trail != null)
                  Icon(trail,
                      color: isCorrect ? AppTheme.mint : AppTheme.rose),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedback() {
    final correct = picked == q.answer;
    return GlassCard(
      color: correct
          ? const Color(0xFF123B2C)
          : const Color(0xFF47182A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct
                    ? Icons.celebration_rounded
                    : Icons.lightbulb_outline_rounded,
                color: correct ? AppTheme.mint : AppTheme.rose,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'إجابة صحيحة' : 'إجابة خاطئة — الإجابة الصحيحة:',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: correct ? AppTheme.mint : AppTheme.rose,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 8),
            Text(q.options[q.answer],
                style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    height: 1.7)),
          ],
          const SizedBox(height: 10),
          Text(q.explain,
              style: const TextStyle(
                  color: AppTheme.inkDim, fontSize: 13.5, height: 1.8)),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined,
                    color: AppTheme.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('المرجع من الكتاب: ${q.ref}',
                      style: const TextStyle(
                          color: AppTheme.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          height: 1.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
