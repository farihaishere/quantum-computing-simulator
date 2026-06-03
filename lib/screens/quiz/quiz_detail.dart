import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/quiz_model.dart';

class QuizDetailScreen extends StatefulWidget {
  final QuizTopic topic;
  final VoidCallback onComplete;

  const QuizDetailScreen({
    super.key,
    required this.topic,
    required this.onComplete,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedIndex;
  bool _finished = false;

  void _submitAnswer(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedIndex = index;
      if (index == widget.topic.questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < widget.topic.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedIndex = null;
      });
    } else {
      await QuizProgress.saveScore(
        widget.topic.id,
        _score,
        widget.topic.questions.length,
      );
      setState(() => _finished = true);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _buildResultsScreen();
    }

    final question = widget.topic.questions[_currentIndex];
    final total = widget.topic.questions.length;
    final progress = (_currentIndex + (_answered ? 1 : 0)) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of $total',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            Text(
              question.question,
              style: Theme.of(context).textTheme.displaySmall,
            )
                .animate(key: ValueKey(_currentIndex))
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1, end: 0),
            const SizedBox(height: 40),
            ...question.options.asMap().entries.map((e) => _OptionCard(
                  text: e.value,
                  index: e.key,
                  isSelected: _selectedIndex == e.key,
                  isCorrect: e.key == question.correctIndex,
                  isAnswered: _answered,
                  onTap: () => _submitAnswer(e.key),
                ).animate(key: ValueKey('$_currentIndex-${e.key}')).fadeIn(
                    delay: Duration(milliseconds: 100 + e.key * 100),
                    duration: 300.ms)),
            if (_answered) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _selectedIndex == question.correctIndex
                      ? AppTheme.accentGreen.withOpacity(0.1)
                      : AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedIndex == question.correctIndex
                        ? AppTheme.accentGreen.withOpacity(0.3)
                        : AppTheme.accent.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedIndex == question.correctIndex
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          color: _selectedIndex == question.correctIndex
                              ? AppTheme.accentGreen
                              : AppTheme.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedIndex == question.correctIndex
                              ? 'Correct!'
                              : 'Incorrect',
                          style: TextStyle(
                            color: _selectedIndex == question.correctIndex
                                ? AppTheme.accentGreen
                                : AppTheme.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.explanation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text(
                  _currentIndex < total - 1 ? 'Next Question' : 'View Results',
                  style: const TextStyle(fontSize: 16),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final total = widget.topic.questions.length;
    final percentage = _score / total;
    final passed = percentage >= 0.6;
    final color = passed ? AppTheme.accentGreen : AppTheme.accentYellow;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  passed ? Icons.emoji_events_rounded : Icons.star_half_rounded,
                  color: color,
                  size: 64,
                ),
              ).animate().scale(
                  duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text(
                passed ? 'Quiz Passed!' : 'Good Effort!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: color,
                    ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 16),
              Text(
                'You scored $_score out of $total',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                '${(percentage * 100).toInt()}% Correct',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
              const SizedBox(height: 64),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Topics'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppTheme.border;
    Color bgColor = AppTheme.cardColor;
    Color iconColor = Colors.transparent;
    IconData? icon;

    if (widget.isAnswered) {
      if (widget.isCorrect) {
        borderColor = AppTheme.accentGreen;
        bgColor = AppTheme.accentGreen.withOpacity(0.1);
        iconColor = AppTheme.accentGreen;
        icon = Icons.check_circle_rounded;
      } else if (widget.isSelected) {
        borderColor = AppTheme.accent;
        bgColor = AppTheme.accent.withOpacity(0.1);
        iconColor = AppTheme.accent;
        icon = Icons.cancel_rounded;
      } else {
        borderColor = AppTheme.border.withOpacity(0.3);
      }
    } else {
      if (_hovered) {
        borderColor = AppTheme.primary;
        bgColor = AppTheme.primary.withOpacity(0.05);
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: widget.isSelected || widget.isCorrect && widget.isAnswered ? 2 : 1),
            boxShadow: _hovered && !widget.isAnswered
                ? [BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 10)]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + widget.index),
                    style: TextStyle(
                      color: widget.isAnswered && (widget.isSelected || widget.isCorrect) ? borderColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.isAnswered && !widget.isCorrect && !widget.isSelected
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                      ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
