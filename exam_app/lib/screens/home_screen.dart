import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/engine.dart';
import '../services/store.dart';
import '../theme/app_theme.dart';
import 'exam_screen.dart';
import 'mistakes_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Question> questions;
  final MistakeStore store;

  const HomeScreen({super.key, required this.questions, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String source = 'all';
  int count = 10;

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.96,
      value: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  List<Question> get pool {
    switch (source) {
      case 'mine':
        return widget.questions.where((q) => q.set == 'mine').toList();
      case 'user':
        return widget.questions.where((q) => q.set == 'user').toList();
      case 'mistakes':
        return widget.questions
            .where((q) => widget.store.ids.contains(q.id))
            .toList();
      default:
        return widget.questions;
    }
  }

  String get sourceLabel {
    switch (source) {
      case 'mine':
        return 'ملخصات الكتاب';
      case 'user':
        return 'أسئلة المعلمة';
      case 'mistakes':
        return 'بنك الأخطاء';
      default:
        return 'كل الأسئلة';
    }
  }

  void startExam() {
    final exam = ExamEngine.buildExam(pool, count);
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, a, __) => ExamScreen(
          exam: exam,
          bank: widget.questions,
          store: widget.store,
          title: sourceLabel,
        ),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              // الترويسة
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withOpacity(0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Color(0xFF241A05), size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('امتحان الدروس الهجائية',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink)),
                        SizedBox(height: 4),
                        Text('أسئلة عشوائية بلا تكرار، مع المرجع والصفحة لكل إجابة',
                            style: TextStyle(
                                fontSize: 12.5, color: AppTheme.inkDim)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // إحصاءات سريعة
              Row(
                children: [
                  _stat('إجمالي الأسئلة', '${widget.questions.length}'),
                  const SizedBox(width: 12),
                  _stat('في بنك الأخطاء', '${widget.store.ids.length}'),
                ],
              ),
              const SizedBox(height: 22),

              // مصدر الأسئلة
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مصدر الأسئلة',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.gold)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _chip('all', 'الكل'),
                        _chip('mine', 'ملخصات الكتاب'),
                        _chip('user', 'أسئلة المعلمة'),
                        _chip('mistakes', 'الأخطاء فقط'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // عدد الأسئلة
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('عدد أسئلة الامتحان',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.gold)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final c in kCountChoices)
                          _countChip(c, countLabel(c)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'سيُختار ${count == 0 ? 'كل' : count} أسئلة عشوائياً من $sourceLabel (المتاح: ${pool.length}) دون تكرار داخل الامتحان.',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.inkDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // زر البدء
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Transform.scale(
                  scale: pool.isEmpty ? 1 : _pulse.value,
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.45),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: pool.isEmpty ? null : startExam,
                        child: const Text(
                          'ابدأ الامتحان',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF241A05)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // مراجعة الأخطاء
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.rose.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MistakesScreen(
                        questions: widget.questions,
                        store: widget.store,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history_edu_rounded,
                      color: AppTheme.rose),
                  label: const Text('مراجعة الأسئلة الخطأ',
                      style: TextStyle(
                          color: AppTheme.rose,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.inkDim)),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.mint)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String value, String label) {
    final selected = source == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => source = value),
      selectedColor: AppTheme.gold,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        color: selected ? const Color(0xFF241A05) : AppTheme.ink,
      ),
      side: BorderSide(color: AppTheme.gold.withOpacity(0.35)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _countChip(int value, String label) {
    final selected = count == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => count = value),
      selectedColor: AppTheme.mint,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        color: selected ? const Color(0xFF062B1D) : AppTheme.ink,
      ),
      side: BorderSide(color: AppTheme.mint.withOpacity(0.35)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
