import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/store.dart';
import '../theme/app_theme.dart';
import 'mistakes_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<Question> exam;
  final List<Question> bank;
  final List<bool> results;
  final int score;
  final MistakeStore store;
  final String title;

  const ResultScreen({
    super.key,
    required this.exam,
    required this.bank,
    required this.results,
    required this.score,
    required this.store,
    required this.title,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  double get ratio =>
      widget.exam.isEmpty ? 0 : widget.score / widget.exam.length;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final good = ratio >= 0.5;
    final color = good ? AppTheme.mint : AppTheme.rose;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(26),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) {
                        final v = Curves.easeOutCubic.transform(_anim.value);
                        return SizedBox(
                          width: 190,
                          height: 190,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 190,
                                height: 190,
                                child: CircularProgressIndicator(
                                  value: ratio * v,
                                  strokeWidth: 13,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.07),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      color),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(ratio * 100 * v).round()}٪',
                                    style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: color),
                                  ),
                                  const Text(
                                    'النتيجة',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.inkDim),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      ratio >= 0.85
                          ? 'ممتاز! إتقان رائع 🌟'
                          : ratio >= 0.5
                              ? 'أحسنتِ! استمري بالتدريب 💪'
                              : 'لا بأس — راجعي الأخطاء وأعيدي المحاولة 🌱',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أجبتِ صحيحاً على ${widget.score} من ${widget.exam.length} في امتحان «${widget.title}»',
                      style: const TextStyle(
                          fontSize: 13.5, color: AppTheme.inkDim),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < widget.results.length; i++)
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (widget.results[i]
                                      ? AppTheme.mint
                                      : AppTheme.rose)
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: (widget.results[i]
                                          ? AppTheme.mint
                                          : AppTheme.rose)
                                      .withValues(alpha: 0.6)),
                            ),
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: widget.results[i]
                                        ? AppTheme.mint
                                        : AppTheme.rose)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('امتحان جديد عشوائي',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF241A05))),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.rose.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MistakesScreen(
                        questions: widget.bank,
                        store: widget.store,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history_edu_rounded,
                      color: AppTheme.rose),
                  label: const Text('مراجعة الأسئلة الخطأ مع الحلول والمراجع',
                      style: TextStyle(
                          color: AppTheme.rose,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
