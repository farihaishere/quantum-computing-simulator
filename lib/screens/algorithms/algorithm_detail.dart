import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../engine/quantum_engine.dart';
import '../../models/qubit.dart';
import '../../widgets/probability_bar_chart.dart';
import '../../widgets/bloch_sphere_painter.dart';
import '../../widgets/circuit_grid.dart';
import 'algorithms_screen.dart';

class AlgorithmDetailScreen extends StatefulWidget {
  final AlgorithmData algo;
  const AlgorithmDetailScreen({super.key, required this.algo});

  @override
  State<AlgorithmDetailScreen> createState() => _AlgorithmDetailScreenState();
}

class _AlgorithmDetailScreenState extends State<AlgorithmDetailScreen>
    with SingleTickerProviderStateMixin {
  List<Qubit> _stepStates = [];
  int _currentStep = 0;
  bool _simulated = false;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _runSimulation();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _runSimulation() {
    final steps = QuantumEngine.simulateStepByStep(widget.algo.circuit);
    setState(() {
      _stepStates = steps;
      _currentStep = 0;
      _simulated = true;
    });
  }

  Qubit get _currentState =>
      _stepStates.isNotEmpty ? _stepStates[_currentStep] : Qubit(2);

  @override
  Widget build(BuildContext context) {
    final algo = widget.algo;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(algo.title),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: algo.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: algo.color.withOpacity(0.4)),
            ),
            child: Text(
              algo.subtitle,
              style: TextStyle(
                color: algo.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: _buildLeftPanel()),
                const VerticalDivider(width: 1, color: AppTheme.border),
                Expanded(flex: 2, child: _buildRightPanel()),
              ],
            )
          : _buildMobile(),
    );
  }

  Widget _buildLeftPanel() {
    final algo = widget.algo;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Row(
            children: [
              Text(algo.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(algo.title,
                        style: Theme.of(context).textTheme.displaySmall),
                    Text(algo.subtitle,
                        style: TextStyle(
                            color: algo.color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Overview',
            content: algo.description,
            color: algo.color,
            icon: Icons.info_outline_rounded,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Key Idea',
            content: algo.keyIdea,
            color: AppTheme.accentGreen,
            icon: Icons.lightbulb_outline_rounded,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Step guide
          Text('How It Works',
                  style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 12),
          ...algo.steps.asMap().entries.map((e) => _StepItem(
                index: e.key,
                text: e.value,
                color: algo.color,
                isActive: e.key == _currentStep,
                onTap: () => setState(() => _currentStep =
                    e.key < _stepStates.length ? e.key : _stepStates.length - 1),
              ).animate().fadeIn(
                  delay: Duration(milliseconds: 350 + e.key * 80),
                  duration: 400.ms)),
          const SizedBox(height: 24),
          // Complexity
          Row(
            children: [
              _ComplexityBox(
                  label: 'Quantum', value: algo.complexity, color: algo.color),
              const SizedBox(width: 12),
              _ComplexityBox(
                  label: 'Classical',
                  value: algo.classicalComplexity,
                  color: AppTheme.textMuted),
            ],
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          const SizedBox(height: 24),
          // Circuit
          Text('Circuit Diagram',
                  style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 700.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.surfaceCard(),
            child: CircuitGrid(
              circuit: algo.circuit,
              onCircuitChanged: (_) {},
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Probabilities'),
            Tab(text: 'Statevector'),
            Tab(text: 'Bloch Sphere'),
          ],
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          dividerColor: AppTheme.border,
        ),
        // Step slider
        if (_simulated && _stepStates.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Simulation Step',
                        style: Theme.of(context).textTheme.labelMedium),
                    Text(
                      _currentStep == 0
                          ? 'Initial State'
                          : 'After Gate $_currentStep',
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 12),
                    ),
                  ],
                ),
                Slider(
                  value: _currentStep.toDouble(),
                  min: 0,
                  max: (_stepStates.length - 1).toDouble(),
                  divisions: _stepStates.length - 1,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.border,
                  onChanged: (v) =>
                      setState(() => _currentStep = v.round()),
                ),
              ],
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildProbOutput(),
              _buildStatevectorOutput(),
              _buildBlochOutput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProbOutput() {
    if (!_simulated) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Measurement Probabilities',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ProbabilityBarChart(state: _currentState),
          const SizedBox(height: 16),
          ..._currentState.basisLabels.asMap().entries.map((e) {
            final i = e.key;
            final prob = _currentState.probabilities[i];
            if (prob < 0.0001) return const SizedBox();
            return StateProbabilityRow(
              label: e.value,
              probability: prob,
              amplitude: _currentState.amplitudes[i].toString(),
              barColor: widget.algo.color,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatevectorOutput() {
    if (!_simulated) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('State Vector',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ..._currentState.amplitudes.asMap().entries.map((e) {
            final prob = e.value.magnitudeSquared;
            if (prob < 0.0001) return const SizedBox();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glowCard(
                  glowColor: widget.algo.color.withOpacity(prob)),
              child: Row(
                children: [
                  Text(
                    _currentState.basisLabels[e.key],
                    style: TextStyle(
                      color: widget.algo.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value.toString(),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Text(
                    '${(prob * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: widget.algo.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBlochOutput() {
    if (!_simulated) return const Center(child: CircularProgressIndicator());
    final n = _currentState.numQubits;
    final colors = [AppTheme.primary, AppTheme.secondary, AppTheme.accentGreen];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Bloch Sphere', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(n, (q) {
              final (x, y, z) = QuantumEngine.blochVector(_currentState, q);
              return Column(
                children: [
                  Text('q$q',
                      style: TextStyle(
                          color: colors[q % colors.length],
                          fontWeight: FontWeight.w700)),
                  BlochSphereWidget(
                      bx: x, by: y, bz: z, size: 180,
                      color: colors[q % colors.length]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(tabs: [Tab(text: 'About'), Tab(text: 'Output')]),
                Expanded(
                  child: TabBarView(children: [
                    SingleChildScrollView(child: _buildLeftPanel()),
                    _buildRightPanel(),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final IconData icon;

  const _InfoCard(
      {required this.title,
      required this.content,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowCard(glowColor: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String text;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StepItem({
    required this.index,
    required this.text,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive ? color : AppTheme.border,
              width: isActive ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? color : AppTheme.border.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isActive ? AppTheme.background : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplexityBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ComplexityBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
