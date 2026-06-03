import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/quantum_circuit.dart';
import 'algorithm_detail.dart';

class AlgorithmData {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String description;
  final String keyIdea;
  final List<String> steps;
  final QuantumCircuit circuit;
  final String complexity;
  final String classicalComplexity;

  const AlgorithmData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.keyIdea,
    required this.steps,
    required this.circuit,
    required this.complexity,
    required this.classicalComplexity,
  });
}

final List<AlgorithmData> allAlgorithms = [
  AlgorithmData(
    id: 'bell_state',
    title: 'Bell State',
    subtitle: 'Maximum quantum entanglement',
    icon: '🔔',
    color: AppTheme.primary,
    description:
        'Bell states are the four maximally entangled two-qubit quantum states. Creating a Bell state is the first step in many quantum protocols including teleportation and superdense coding.',
    keyIdea:
        'Apply H to put qubit 0 in superposition, then CNOT to entangle it with qubit 1. The result is a state where qubits are perfectly correlated — measuring one instantly determines the other.',
    steps: [
      'Start with |00⟩ (both qubits in ground state)',
      'Apply Hadamard (H) to qubit 0 → |+⟩|0⟩ = (|00⟩ + |10⟩)/√2',
      'Apply CNOT (control: q0, target: q1)',
      'Result: |Φ+⟩ = (|00⟩ + |11⟩)/√2 — maximally entangled!',
      'Measure: both qubits always agree (both 0 or both 1)',
    ],
    circuit: AlgorithmCircuits.bellState(),
    complexity: 'O(1)',
    classicalComplexity: 'N/A',
  ),
  AlgorithmData(
    id: 'deutsch_jozsa',
    title: 'Deutsch–Jozsa',
    subtitle: 'Exponential speedup with 1 query',
    icon: '⚡',
    color: AppTheme.secondary,
    description:
        'The Deutsch-Jozsa algorithm determines whether a Boolean function f:{0,1}ⁿ → {0,1} is constant (always 0 or always 1) or balanced (outputs 0 for exactly half the inputs). Classically, this requires up to 2ⁿ⁻¹+1 queries. Quantum: just 1.',
    keyIdea:
        'Use quantum parallelism and interference. Put all inputs in superposition (via H gates), query the oracle once, then apply H again. The result collapses to |0⟩ if constant, or a non-zero state if balanced.',
    steps: [
      'Initialize: |0⟩ⁿ|1⟩ (n input qubits + 1 ancilla in |1⟩)',
      'Apply H to all qubits → uniform superposition',
      'Query the oracle Uf once (evaluates f on all inputs simultaneously)',
      'Apply H to input qubits again (interference step)',
      'Measure input qubits: all-zeros → constant, else → balanced',
    ],
    circuit: AlgorithmCircuits.deutschJozsa(),
    complexity: 'O(1) queries',
    classicalComplexity: 'O(2^(n-1)+1) queries',
  ),
  AlgorithmData(
    id: 'grovers',
    title: "Grover's Search",
    subtitle: 'Quadratic speedup for unstructured search',
    icon: '🔍',
    color: AppTheme.accentGreen,
    description:
        "Grover's algorithm searches an unsorted database of N items for a marked item in O(√N) time, compared to the classical O(N). For 2 qubits (4 items), one Grover iteration is sufficient to find the marked state |11⟩ with near certainty.",
    keyIdea:
        'Use amplitude amplification. Start with a uniform superposition, then alternately apply the oracle (phase-flips the target) and the diffusion operator (inversion about average). After O(√N) iterations, measuring gives the target.',
    steps: [
      'Apply H to all qubits → uniform superposition over all 4 states',
      'Oracle: phase-flip |11⟩ using a CZ gate',
      'Diffusion operator: H → X → CZ → X → H (inversion about average)',
      'After 1 iteration, |11⟩ has probability ≈ 1.0',
      'Measure: guaranteed to find the marked state',
    ],
    circuit: AlgorithmCircuits.grover2Qubit(),
    complexity: 'O(√N)',
    classicalComplexity: 'O(N)',
  ),
  AlgorithmData(
    id: 'teleportation',
    title: 'Quantum Teleportation',
    subtitle: 'Transfer quantum state using entanglement',
    icon: '🛸',
    color: AppTheme.accent,
    description:
        'Quantum teleportation transfers the quantum state of a qubit to another location using a pre-shared Bell pair and 2 classical bits of communication. The original qubit is destroyed in the process (no-cloning theorem).',
    keyIdea:
        "Alice shares an entangled Bell pair with Bob. She performs a Bell measurement on her qubit and the message qubit, then sends 2 classical bits to Bob. Bob applies corrections and reconstructs Alice's original state perfectly.",
    steps: [
      'Prepare message qubit in state |ψ⟩ = H|0⟩ = |+⟩',
      'Create Bell pair: H on q1, CNOT(q1→q2) → shared entanglement',
      'Bell measurement: CNOT(q0→q1) then H on q0',
      'Alice measures q0 and q1 → gets 2 classical bits',
      'Bob applies CNOT (from bit 1) and CZ (from bit 0) to q2',
      "Bob's q2 now has exactly Alice's original state |ψ⟩",
    ],
    circuit: AlgorithmCircuits.teleportation(),
    complexity: '2 classical bits communication',
    classicalComplexity: 'Impossible (quantum state cannot be cloned)',
  ),
];

class AlgorithmsScreen extends StatelessWidget {
  const AlgorithmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantum Algorithms',
                      style: Theme.of(context).textTheme.displaySmall)
                      .animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Explore famous quantum algorithms with step-by-step simulations',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _AlgorithmCard(
                  algo: allAlgorithms[i],
                  index: i,
                ),
                childCount: allAlgorithms.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _AlgorithmCard extends StatefulWidget {
  final AlgorithmData algo;
  final int index;

  const _AlgorithmCard({required this.algo, required this.index});

  @override
  State<_AlgorithmCard> createState() => _AlgorithmCardState();
}

class _AlgorithmCardState extends State<_AlgorithmCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.algo;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 650;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlgorithmDetailScreen(algo: a),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: AppTheme.glowCard(glowColor: _hovered ? a.color : AppTheme.border),
            padding: const EdgeInsets.all(24),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: a.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: a.color.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: Text(a.icon, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a.subtitle,
                                  style: TextStyle(
                                    color: a.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        a.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ComplexityBadge(
                            label: 'Quantum',
                            value: a.complexity,
                            color: a.color,
                          ),
                          _ComplexityBadge(
                            label: 'Classical',
                            value: a.classicalComplexity,
                            color: AppTheme.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _hovered ? a.color.withOpacity(0.2) : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _hovered ? a.color : AppTheme.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore',
                                style: TextStyle(
                                  color: _hovered ? a.color : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: _hovered ? a.color : AppTheme.textSecondary,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: a.color.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(a.icon, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a.subtitle,
                              style: TextStyle(
                                color: a.color,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              a.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _ComplexityBadge(
                                  label: 'Quantum',
                                  value: a.complexity,
                                  color: a.color,
                                ),
                                _ComplexityBadge(
                                  label: 'Classical',
                                  value: a.classicalComplexity,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _hovered ? a.color.withOpacity(0.2) : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _hovered ? a.color : AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore',
                              style: TextStyle(
                                color: _hovered ? a.color : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: _hovered ? a.color : AppTheme.textSecondary,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 150 * widget.index), duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

class _ComplexityBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ComplexityBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
