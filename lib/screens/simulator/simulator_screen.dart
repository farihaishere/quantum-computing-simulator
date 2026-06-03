import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/quantum_circuit.dart';
import '../../engine/quantum_engine.dart';
import '../../models/qubit.dart';
import '../../widgets/circuit_grid.dart';
import '../../widgets/gate_palette.dart';
import '../../widgets/probability_bar_chart.dart';
import '../../widgets/bloch_sphere_painter.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen>
    with SingleTickerProviderStateMixin {
  QuantumCircuit _circuit = const QuantumCircuit(numQubits: 2);
  Qubit? _result;
  List<Qubit> _steps = [];
  int _selectedStepIndex = -1;
  bool _isRunning = false;
  late TabController _outputTab;

  @override
  void initState() {
    super.initState();
    _outputTab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _outputTab.dispose();
    super.dispose();
  }

  Future<void> _runSimulation() async {
    if (_circuit.isEmpty) {
      _showSnackbar('Add some gates first!', AppTheme.accentYellow);
      return;
    }
    setState(() => _isRunning = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final result = QuantumEngine.simulate(_circuit);
    final steps = QuantumEngine.simulateStepByStep(_circuit);
    setState(() {
      _result = result;
      _steps = steps;
      _selectedStepIndex = steps.length - 1;
      _isRunning = false;
    });
  }

  void _reset() {
    setState(() {
      _circuit = QuantumCircuit(numQubits: _circuit.numQubits);
      _result = null;
      _steps = [];
      _selectedStepIndex = -1;
    });
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(isWide),
          Expanded(
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 200, child: GatePalette()),
                      const VerticalDivider(width: 1, color: AppTheme.border),
                      Expanded(child: _buildMain()),
                      const VerticalDivider(width: 1, color: AppTheme.border),
                      SizedBox(width: 340, child: _buildOutputPanel()),
                    ],
                  )
                : _buildMobileLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isWide ? 'Quantum Circuit Simulator' : 'Simulator',
              style: Theme.of(context).textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Qubit selector
          Text('Qubits:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          ...List.generate(4, (i) {
            final n = i + 1;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _QubitButton(
                count: n,
                selected: _circuit.numQubits == n,
                onTap: () => setState(() {
                  _circuit = QuantumCircuit(numQubits: n);
                  _result = null;
                  _steps = [];
                }),
              ),
            );
          }),
          if (isWide) ...[
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runSimulation,
              icon: _isRunning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.background))
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(_isRunning ? 'Running...' : 'Run'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circuit area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Circuit', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_circuit.operations.length} gates',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Right-click gate to remove',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: AppTheme.surfaceCard(),
                    padding: const EdgeInsets.all(16),
                    child: CircuitGrid(
                      circuit: _circuit,
                      onCircuitChanged: (c) => setState(() {
                        _circuit = c;
                        _result = null;
                        _steps = [];
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Step timeline (shown after simulation)
        if (_steps.isNotEmpty) _buildStepTimeline(),
      ],
    );
  }

  Widget _buildStepTimeline() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _steps.length,
        itemBuilder: (context, i) {
          final isSelected = i == _selectedStepIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedStepIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    i == 0 ? 'Initial' : 'Step $i',
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _steps[i].amplitudes[0].magnitude < 0.99
                        ? 'Mixed'
                        : '|${_steps[i].mostProbableState.toRadixString(2).padLeft(_circuit.numQubits, '0')}⟩',
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutputPanel() {
    final displayState = _selectedStepIndex >= 0 && _selectedStepIndex < _steps.length
        ? _steps[_selectedStepIndex]
        : _result;

    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          TabBar(
            controller: _outputTab,
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
          Expanded(
            child: displayState == null
                ? _buildEmptyOutput()
                : TabBarView(
                    controller: _outputTab,
                    children: [
                      _buildProbOutput(displayState),
                      _buildStatevectorOutput(displayState),
                      _buildBlochOutput(displayState),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOutput() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline_rounded,
              color: AppTheme.textMuted, size: 56),
          const SizedBox(height: 16),
          Text('Run the circuit to see results',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildProbOutput(Qubit state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Measurement Probabilities',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ProbabilityBarChart(state: state)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          ...state.basisLabels.asMap().entries.map((e) {
            final i = e.key;
            final label = e.value;
            final prob = state.probabilities[i];
            final amp = state.amplitudes[i];
            if (prob < 0.0001) return const SizedBox();
            return StateProbabilityRow(
              label: label,
              probability: prob,
              amplitude: amp.toString(),
              barColor: AppTheme.primary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatevectorOutput(Qubit state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('State Vector |ψ⟩',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Complex amplitudes for each basis state',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          ...state.amplitudes.asMap().entries.map((e) {
            final i = e.key;
            final amp = e.value;
            final prob = amp.magnitudeSquared;
            if (prob < 0.0001) return const SizedBox();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glowCard(
                  glowColor: AppTheme.primary.withOpacity(prob)),
              child: Row(
                children: [
                  Text(
                    state.basisLabels[i],
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      amp.toString(),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Text(
                    '${(prob * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppTheme.accentGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                delay: Duration(milliseconds: i * 60), duration: 300.ms);
          }),
        ],
      ),
    );
  }

  Widget _buildBlochOutput(Qubit state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Bloch Sphere Visualization',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            state.numQubits > 1
                ? 'Showing reduced state for each qubit'
                : 'Single qubit state on Bloch sphere',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(state.numQubits, (q) {
              final (x, y, z) = QuantumEngine.blochVector(state, q);
              final colors = [
                AppTheme.primary,
                AppTheme.secondary,
                AppTheme.accentGreen,
                AppTheme.accent,
              ];
              return Column(
                children: [
                  Text(
                    'q$q',
                    style: TextStyle(
                      color: colors[q % colors.length],
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlochSphereWidget(
                    bx: x,
                    by: y,
                    bz: z,
                    size: 180,
                    color: colors[q % colors.length],
                  ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.85, 0.85)),
                  const SizedBox(height: 8),
                  Text(
                    '(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Gates'),
              Tab(text: 'Circuit'),
              Tab(text: 'Output'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const GatePalette(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircuitGrid(
                    circuit: _circuit,
                    onCircuitChanged: (c) => setState(() {
                      _circuit = c;
                      _result = null;
                    }),
                  ),
                ),
                _buildOutputPanel(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: _reset, child: const Text('Reset')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                      onPressed: _runSimulation, child: const Text('Run')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QubitButton extends StatelessWidget {
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _QubitButton(
      {required this.count, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              selected ? AppTheme.primary.withOpacity(0.2) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Center(
          child: Text(
            '$count',
            style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
