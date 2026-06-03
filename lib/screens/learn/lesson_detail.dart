import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'learn_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonData lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < widget.lesson.pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final total = lesson.pages.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / total,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(lesson.color),
          ),
        ),
      ),
      body: Column(
        children: [
          // Page indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${_currentPage + 1} of $total',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Row(
                  children: List.generate(total, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? lesson.color
                          : AppTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                Text(
                  lesson.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Page content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: total,
              itemBuilder: (context, i) {
                final page = lesson.pages[i];
                return _LessonPageView(
                  page: page,
                  color: lesson.color,
                );
              },
            ),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  OutlinedButton.icon(
                    onPressed: _prev,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Previous'),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _next,
                  icon: Icon(
                    _currentPage < total - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _currentPage < total - 1 ? 'Next' : 'Complete Lesson',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lesson.color,
                    foregroundColor: AppTheme.background,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonPageView extends StatelessWidget {
  final LessonPage page;
  final Color color;

  const _LessonPageView({required this.page, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          if (page.formula != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.08),
                    color.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                page.formula!,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.surfaceCard(),
            child: Text(
              page.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    color: AppTheme.textPrimary,
                  ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
