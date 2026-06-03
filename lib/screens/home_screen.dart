import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_qubit.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Star-field background
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _StarFieldPainter(_starController.value),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _HeroSection(onNavigate: widget.onNavigate),
                _FeaturesSection(onNavigate: widget.onNavigate),
                _StatsSection(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _HeroSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 60),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _HeroText(onNavigate: onNavigate)),
                const SizedBox(width: 60),
                _HeroVisual(),
              ],
            )
          : Column(
              children: [
                _HeroVisual(),
                const SizedBox(height: 40),
                _HeroText(onNavigate: onNavigate),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _HeroText({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'QUANTUM COMPUTING SIMULATOR',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: -0.3, end: 0),
        const SizedBox(height: 24),
        Text(
          'Explore the\nQuantum World',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                height: 1.1,
                foreground: Paint()
                  ..shader = AppTheme.primaryGradient.createShader(
                    const Rect.fromLTWH(0, 0, 400, 120),
                  ),
              ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 20),
        Text(
          'Build quantum circuits, visualize qubit states,\nexplore famous algorithms, and test your knowledge\nthrough interactive lessons and quizzes.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.7,
              ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 700.ms),
        const SizedBox(height: 36),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton.icon(
              onPressed: () => onNavigate(2),
              icon: const Icon(Icons.science_rounded, size: 18),
              label: const Text('Open Simulator'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => onNavigate(1),
              icon: const Icon(Icons.school_rounded, size: 18),
              label: const Text('Start Learning'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.1), width: 1),
            ),
          ),
          // Middle ring
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.15), width: 1),
            ),
          ),
          // Center qubit
          const AnimatedQubit(size: 160, color: AppTheme.primary),
          // Orbiting qubits
          _OrbitingQubit(
            radius: 130,
            color: AppTheme.secondary,
            size: 50,
            speed: 6,
            startAngle: 0,
          ),
          _OrbitingQubit(
            radius: 130,
            color: AppTheme.accentGreen,
            size: 40,
            speed: 8,
            startAngle: math.pi,
          ),
          _OrbitingQubit(
            radius: 110,
            color: AppTheme.accent,
            size: 35,
            speed: 12,
            startAngle: math.pi / 2,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 800.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}

class _OrbitingQubit extends StatefulWidget {
  final double radius;
  final Color color;
  final double size;
  final double speed;
  final double startAngle;

  const _OrbitingQubit({
    required this.radius,
    required this.color,
    required this.size,
    required this.speed,
    required this.startAngle,
  });

  @override
  State<_OrbitingQubit> createState() => _OrbitingQubitState();
}

class _OrbitingQubitState extends State<_OrbitingQubit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.speed.toInt()),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angle = _ctrl.value * 2 * math.pi + widget.startAngle;
        return Transform.translate(
          offset: Offset(
            math.cos(angle) * widget.radius,
            math.sin(angle) * widget.radius * 0.4, // flatten for 3D look
          ),
          child: AnimatedQubit(
            size: widget.size,
            color: widget.color,
            animate: false,
          ),
        );
      },
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _FeaturesSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData(
        icon: Icons.school_rounded,
        color: AppTheme.primary,
        title: 'Learn',
        subtitle: '8 interactive lessons\nfrom qubits to entanglement',
        navIndex: 1,
      ),
      _FeatureData(
        icon: Icons.science_rounded,
        color: AppTheme.secondary,
        title: 'Simulator',
        subtitle: 'Drag-and-drop circuit builder\nwith live visualization',
        navIndex: 2,
      ),
      _FeatureData(
        icon: Icons.auto_fix_high_rounded,
        color: AppTheme.accentGreen,
        title: 'Algorithms',
        subtitle: 'Grover, Deutsch-Jozsa,\nTeleportation & Bell States',
        navIndex: 3,
      ),
      _FeatureData(
        icon: Icons.quiz_rounded,
        color: AppTheme.accentYellow,
        title: 'Quiz',
        subtitle: '25 questions across 5 topics\nwith progress tracking',
        navIndex: 4,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore Features',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text('Everything you need to master quantum computing',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final isMed = constraints.maxWidth > 500;
            final crossCount = isWide ? 4 : (isMed ? 2 : 1);
            final aspectRatio = isWide ? 1.2 : (isMed ? 0.85 : 1.4);
            return GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: features
                  .asMap()
                  .entries
                  .map((e) => _FeatureCard(
                        data: e.value,
                        onNavigate: onNavigate,
                        delay: e.key * 100,
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int navIndex;
  const _FeatureData(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.navIndex});
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  final ValueChanged<int> onNavigate;
  final int delay;

  const _FeatureCard(
      {required this.data, required this.onNavigate, required this.delay});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onNavigate(d.navIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: AppTheme.glowCard(
            glowColor: _hovered ? d.color : AppTheme.border,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: d.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: d.color.withOpacity(0.3)),
                ),
                child: Icon(d.icon, color: d.color, size: 24),
              ),
              const Spacer(),
              Text(d.title,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(d.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(height: 1.5)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Explore',
                      style: TextStyle(
                          color: d.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                        _hovered ? 4 : 0, 0, 0),
                    child: Icon(Icons.arrow_forward, color: d.color, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 600 + widget.delay), duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.08),
            AppTheme.secondary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final stats = [
          ('12+', 'Quantum Gates'),
          ('8', 'Lessons'),
          ('4', 'Algorithm Demos'),
          ('25', 'Quiz Questions'),
        ];
        return isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats
                    .map((s) => _StatItem(value: s.$1, label: s.$2))
                    .toList(),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(value: stats[0].$1, label: stats[0].$2),
                      ),
                      Expanded(
                        child: _StatItem(value: stats[1].$1, label: stats[1].$2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(value: stats[2].$1, label: stats[2].$2),
                      ),
                      Expanded(
                        child: _StatItem(value: stats[3].$1, label: stats[3].$2),
                      ),
                    ],
                  ),
                ],
              );
      }),
    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.primary,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final double t;
  static final _rng = math.Random(42);
  static final _stars = List.generate(120, (_) => [
        _rng.nextDouble(),
        _rng.nextDouble(),
        _rng.nextDouble() * 2 + 0.5,
        _rng.nextDouble(),
      ]);

  const _StarFieldPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      final x = star[0] * size.width;
      final y = star[1] * size.height;
      final r = star[2];
      final phase = star[3];
      final opacity = 0.2 + 0.5 * (0.5 + 0.5 * math.sin(t * 2 * math.pi + phase * 10));
      paint.color = AppTheme.textPrimary.withOpacity(opacity * 0.6);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.t != t;
}
