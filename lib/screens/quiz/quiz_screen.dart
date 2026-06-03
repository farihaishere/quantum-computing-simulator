import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/quiz_model.dart';
import 'quiz_detail.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, QuizResult> _results = {};

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final ids = QuizData.topics.map((t) => t.id).toList();
    final results = await QuizProgress.loadAll(ids);
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final total = QuizData.topics.fold(0, (s, t) => s + t.questions.length);
    final completedTopics = _results.length;
    final totalTopics = QuizData.topics.length;
    final overallScore = _results.isEmpty
        ? 0.0
        : _results.values.map((r) => r.percentage).reduce((a, b) => a + b) /
            _results.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quiz & Practice',
                          style: Theme.of(context).textTheme.displaySmall)
                      .animate()
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text('Test your knowledge across $totalTopics topics ($total questions)',
                          style: Theme.of(context).textTheme.bodyMedium)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 24),
                  // Overall progress card
                  _OverallProgressCard(
                    completedTopics: completedTopics,
                    totalTopics: totalTopics,
                    overallScore: overallScore,
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  const SizedBox(height: 32),
                  Text('Topics',
                          style: Theme.of(context).textTheme.headlineMedium)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final topic = QuizData.topics[i];
                  final result = _results[topic.id];
                  return _TopicCard(
                    topic: topic,
                    result: result,
                    index: i,
                    onComplete: _loadResults,
                  );
                },
                childCount: QuizData.topics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  final int completedTopics;
  final int totalTopics;
  final double overallScore;

  const _OverallProgressCard({
    required this.completedTopics,
    required this.totalTopics,
    required this.overallScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Progress',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '$completedTopics / $totalTopics topics completed',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalTopics == 0
                        ? 0
                        : completedTopics / totalTopics,
                    minHeight: 8,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: overallScore,
                      strokeWidth: 6,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation(
                        overallScore >= 0.8
                            ? AppTheme.accentGreen
                            : overallScore >= 0.6
                                ? AppTheme.accentYellow
                                : AppTheme.accent,
                      ),
                    ),
                  ),
                  Text(
                    '${(overallScore * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Avg Score',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatefulWidget {
  final QuizTopic topic;
  final QuizResult? result;
  final int index;
  final VoidCallback onComplete;

  const _TopicCard({
    required this.topic,
    required this.result,
    required this.index,
    required this.onComplete,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final result = widget.result;
    final isCompleted = result != null;
    final scoreColor = result == null
        ? AppTheme.textMuted
        : result.percentage >= 0.8
            ? AppTheme.accentGreen
            : result.percentage >= 0.6
                ? AppTheme.accentYellow
                : AppTheme.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizDetailScreen(
                  topic: topic,
                  onComplete: widget.onComplete,
                ),
              ),
            );
            widget.onComplete();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glowCard(
                glowColor:
                    _hovered ? AppTheme.primary : AppTheme.border),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppTheme.primary.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Text(topic.icon,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.title,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${topic.questions.length} questions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Score badge
                if (isCompleted) ...[
                  Column(
                    children: [
                      Text(
                        '${result.score}/${result.total}',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${(result.percentage * 100).toInt()}%',
                        style: TextStyle(color: scoreColor, fontSize: 12),
                      ),
                      if (result.passed)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.accentGreen, size: 18),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
                // Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                      Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
                  child: Icon(
                    isCompleted
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 150 * widget.index), duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }
}
