import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'lesson_detail.dart';

class LessonData {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final List<LessonPage> pages;

  const LessonData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pages,
  });
}

class LessonPage {
  final String title;
  final String content;
  final String? formula;
  const LessonPage({required this.title, required this.content, this.formula});
}

final List<LessonData> allLessons = [
  LessonData(
    id: 'what_is_qubit',
    title: 'What is a Qubit?',
    subtitle: 'The fundamental unit of quantum information',
    icon: '⚛️',
    color: AppTheme.primary,
    pages: [
      LessonPage(
        title: 'Classical Bits vs Qubits',
        content: 'Classical computers use bits — the simplest unit of information, which can be either 0 or 1. Everything a classical computer does — from calculations to streaming video — is ultimately represented as sequences of 0s and 1s.\n\nQuantum computers use qubits (quantum bits). A qubit can also be 0 or 1 when measured, but unlike classical bits, a qubit can exist in a superposition of both states simultaneously before measurement.',
        formula: '|ψ⟩ = α|0⟩ + β|1⟩',
      ),
      LessonPage(
        title: 'The State of a Qubit',
        content: 'A qubit\'s state is described by a state vector |ψ⟩ = α|0⟩ + β|1⟩, where α and β are complex numbers called amplitudes.\n\nThe probability of measuring |0⟩ is |α|² and the probability of measuring |1⟩ is |β|². Since probabilities must sum to 1:\n\n|α|² + |β|² = 1\n\nThis is called the normalization condition.',
        formula: '|α|² + |β|² = 1',
      ),
      LessonPage(
        title: 'Physical Implementations',
        content: 'Qubits can be physically implemented in many ways:\n\n• Superconducting circuits (used by IBM, Google)\n• Trapped ions (used by IonQ, Quantinuum)\n• Photons (optical quantum computing)\n• Spin states of electrons or nuclei\n• Topological qubits (experimental)\n\nEach approach has different advantages in terms of coherence time, gate fidelity, and scalability.',
      ),
      LessonPage(
        title: 'Why Qubits Are Powerful',
        content: 'With n qubits, a quantum computer can simultaneously represent 2ⁿ states. A 300-qubit quantum computer can represent more states than there are atoms in the observable universe!\n\nThis exponential scaling, combined with quantum interference and entanglement, allows quantum algorithms to solve certain problems exponentially faster than classical computers.',
        formula: '2ⁿ states for n qubits',
      ),
    ],
  ),
  LessonData(
    id: 'superposition',
    title: 'Superposition',
    subtitle: 'Being in multiple states at once',
    icon: '🌊',
    color: AppTheme.secondary,
    pages: [
      LessonPage(
        title: 'What is Superposition?',
        content: 'Superposition is one of the most fundamental principles of quantum mechanics. It states that a quantum system can exist in multiple states simultaneously until it is measured.\n\nFor a qubit, this means it can be in a state that is a combination of both |0⟩ and |1⟩ at the same time. The Hadamard gate is the most common way to create superposition.',
        formula: 'H|0⟩ = (|0⟩ + |1⟩) / √2',
      ),
      LessonPage(
        title: 'The |+⟩ and |−⟩ States',
        content: 'The Hadamard gate creates two important superposition states:\n\n|+⟩ = (|0⟩ + |1⟩) / √2   — equal superposition, in phase\n|−⟩ = (|0⟩ − |1⟩) / √2   — equal superposition, out of phase\n\nBoth have 50% probability of measuring |0⟩ and 50% of measuring |1⟩, but they differ in their phase relationship, which is crucial for quantum algorithms.',
        formula: '|−⟩ = (|0⟩ − |1⟩) / √2',
      ),
      LessonPage(
        title: 'Measurement and Collapse',
        content: 'When you measure a qubit in superposition, the superposition collapses to a definite state. The measurement outcome is probabilistic — you get |0⟩ with probability |α|² or |1⟩ with probability |β|².\n\nAfter measurement, the qubit is in the measured state — superposition is destroyed. This is why quantum algorithms must be carefully designed to extract information without premature measurement.',
      ),
      LessonPage(
        title: 'Quantum Parallelism',
        content: 'Superposition enables quantum parallelism. By preparing multiple qubits in superposition, a quantum computer can evaluate a function on all 2ⁿ inputs simultaneously.\n\nHowever, we can only measure one outcome, so algorithms must use quantum interference to amplify the probability of the correct answer and suppress wrong answers.',
        formula: 'n qubits → 2ⁿ states evaluated simultaneously',
      ),
    ],
  ),
  LessonData(
    id: 'entanglement',
    title: 'Entanglement',
    subtitle: "Einstein's spooky action at a distance",
    icon: '🔗',
    color: AppTheme.accentGreen,
    pages: [
      LessonPage(
        title: 'What is Entanglement?',
        content: 'Quantum entanglement is a phenomenon where two or more qubits become correlated in such a way that the quantum state of each cannot be described independently, regardless of the distance between them.\n\nWhen you measure one entangled qubit, the state of its partner is instantly determined — even across any distance. Einstein called this "spooky action at a distance."',
      ),
      LessonPage(
        title: 'Creating Entanglement',
        content: 'The simplest way to create entanglement is with two gates:\n\n1. Apply Hadamard (H) to qubit 0 → creates superposition\n2. Apply CNOT with qubit 0 as control → entangles with qubit 1\n\nThis creates the Bell state:\n|Φ+⟩ = (|00⟩ + |11⟩) / √2\n\nIf you measure qubit 0 as |0⟩, qubit 1 must also be |0⟩. If it is |1⟩, qubit 1 must also be |1⟩.',
        formula: '|Φ+⟩ = (|00⟩ + |11⟩) / √2',
      ),
      LessonPage(
        title: 'The Four Bell States',
        content: 'There are four maximally entangled 2-qubit states, called Bell states:\n\n|Φ+⟩ = (|00⟩ + |11⟩) / √2\n|Φ−⟩ = (|00⟩ − |11⟩) / √2\n|Ψ+⟩ = (|01⟩ + |10⟩) / √2\n|Ψ−⟩ = (|01⟩ − |10⟩) / √2\n\nBell states are used as resources in quantum teleportation, superdense coding, and quantum cryptography.',
      ),
      LessonPage(
        title: 'Applications of Entanglement',
        content: 'Entanglement is the key resource behind many quantum technologies:\n\n• Quantum Teleportation — transfer quantum states perfectly\n• Superdense Coding — send 2 classical bits using 1 qubit + entanglement\n• Quantum Cryptography (QKD) — unbreakable communication\n• Quantum Error Correction — protect information from decoherence\n• Quantum Sensing — ultra-precise measurements\n\nWithout entanglement, quantum computers offer no advantage over classical ones.',
      ),
    ],
  ),
  LessonData(
    id: 'pauli_gates',
    title: 'Pauli Gates: X, Y, Z',
    subtitle: 'Single-qubit rotations on the Bloch sphere',
    icon: '🔄',
    color: AppTheme.gateX,
    pages: [
      LessonPage(
        title: 'The Pauli-X Gate',
        content: 'The Pauli-X gate is the quantum equivalent of the classical NOT gate. It flips the qubit:\n\nX|0⟩ = |1⟩\nX|1⟩ = |0⟩\n\nIts matrix is [[0,1],[1,0]]. On the Bloch sphere, X rotates the state 180° (π radians) around the X-axis.',
        formula: 'X = [[0, 1], [1, 0]]',
      ),
      LessonPage(
        title: 'The Pauli-Y Gate',
        content: 'The Pauli-Y gate rotates the qubit 180° around the Y-axis of the Bloch sphere:\n\nY|0⟩ = i|1⟩\nY|1⟩ = -i|0⟩\n\nIts matrix is [[0,-i],[i,0]]. It combines a bit flip with a phase flip, introducing imaginary numbers into the amplitude.',
        formula: 'Y = [[0, -i], [i, 0]]',
      ),
      LessonPage(
        title: 'The Pauli-Z Gate',
        content: 'The Pauli-Z gate is the phase flip gate. It leaves |0⟩ unchanged but flips the phase of |1⟩:\n\nZ|0⟩ = |0⟩\nZ|1⟩ = -|1⟩\n\nIts matrix is [[1,0],[0,-1]]. On the Bloch sphere, Z rotates 180° around the Z-axis.',
        formula: 'Z = [[1, 0], [0, -1]]',
      ),
      LessonPage(
        title: 'Pauli Matrices and Unitarity',
        content: 'The three Pauli matrices (X, Y, Z) along with the identity (I) form a basis for all 2×2 unitary matrices. Important properties:\n\n• All are self-inverse: X² = Y² = Z² = I\n• All are both Hermitian (U† = U) and unitary (U†U = I)\n• They anticommute: XY = -YX, YZ = -ZY, XZ = -ZX\n• XYZ = iI (their product gives imaginary identity)\n\nThese properties make the Pauli gates fundamental building blocks of quantum computing.',
        formula: 'X² = Y² = Z² = I',
      ),
    ],
  ),
  LessonData(
    id: 'hadamard',
    title: 'The Hadamard Gate',
    subtitle: 'Creating and destroying superposition',
    icon: 'H',
    color: AppTheme.gateH,
    pages: [
      LessonPage(
        title: 'The H Gate Matrix',
        content: 'The Hadamard gate is one of the most important in quantum computing. Its matrix is:\n\nH = (1/√2) [[1, 1], [1, -1]]\n\nIt transforms:\nH|0⟩ = (|0⟩ + |1⟩) / √2 = |+⟩\nH|1⟩ = (|0⟩ − |1⟩) / √2 = |−⟩\n\nApplying H twice returns to the original state: H² = I.',
        formula: 'H = (1/√2) [[1, 1], [1, -1]]',
      ),
      LessonPage(
        title: 'H on the Bloch Sphere',
        content: 'On the Bloch sphere, the Hadamard gate corresponds to a 90° rotation around the Y-axis followed by a 180° rotation around the X-axis.\n\nEffectively, it maps:\n• |0⟩ (north pole) → |+⟩ (equator)\n• |1⟩ (south pole) → |−⟩ (equator)\n• |+⟩ (equator) → |0⟩ (north pole)\n\nH swaps the X and Z axes of the Bloch sphere.',
      ),
      LessonPage(
        title: 'Multiple Qubit Hadamard',
        content: 'Applying H to each of n qubits creates an equal superposition of all 2ⁿ basis states:\n\nH⊗n|0...0⟩ = (1/√2ⁿ) Σ|x⟩\n\nThis creates a uniform superposition over all possible inputs — a key first step in algorithms like Grover\'s search and quantum Fourier transform.',
        formula: 'H⊗n|0⟩ⁿ = (1/√(2ⁿ)) Σₓ |x⟩',
      ),
    ],
  ),
  LessonData(
    id: 'cnot',
    title: 'The CNOT Gate',
    subtitle: 'Controlled operations and entanglement',
    icon: '⊕',
    color: AppTheme.gateCNOT,
    pages: [
      LessonPage(
        title: 'How CNOT Works',
        content: 'The CNOT (Controlled-NOT) gate is a 2-qubit gate with a control qubit and a target qubit.\n\nBehavior:\n• If control = |0⟩ → target unchanged\n• If control = |1⟩ → target flipped (X applied)\n\nTruth table:\n|00⟩ → |00⟩\n|01⟩ → |01⟩\n|10⟩ → |11⟩\n|11⟩ → |10⟩',
        formula: 'CNOT|c,t⟩ = |c, c⊕t⟩',
      ),
      LessonPage(
        title: 'CNOT Creates Entanglement',
        content: 'When the control qubit is in superposition, CNOT creates entanglement:\n\nH|0⟩ ⊗ |0⟩ = |+⟩|0⟩ = (|00⟩ + |10⟩) / √2\n\nAfter CNOT:\n(|00⟩ + |11⟩) / √2 = |Φ+⟩\n\nThis is a Bell state — the two qubits are now entangled. Neither qubit has a definite state independently.',
        formula: '(|00⟩ + |11⟩) / √2',
      ),
      LessonPage(
        title: 'CNOT Matrix',
        content: 'The 4×4 CNOT matrix in the |00⟩, |01⟩, |10⟩, |11⟩ basis is:\n\n[[1,0,0,0],\n [0,1,0,0],\n [0,0,0,1],\n [0,0,1,0]]\n\nLike all quantum gates, it is unitary (U†U = I) and reversible. Applying CNOT twice returns to the original state.',
        formula: 'CNOT² = I',
      ),
    ],
  ),
  LessonData(
    id: 'phase_gates',
    title: 'Phase Gates: S & T',
    subtitle: 'Controlling the quantum phase',
    icon: 'φ',
    color: AppTheme.gateS,
    pages: [
      LessonPage(
        title: 'What is Phase?',
        content: 'Every qubit amplitude is a complex number, which has a magnitude and a phase angle. Global phase is not observable, but relative phase between |0⟩ and |1⟩ amplitudes affects measurement outcomes when gates are applied.\n\nPhase gates modify the phase of |1⟩ while leaving |0⟩ unchanged. They are essential for quantum interference.',
      ),
      LessonPage(
        title: 'The S Gate',
        content: 'The S gate applies a 90° (π/2) phase shift to the |1⟩ component:\n\nS|0⟩ = |0⟩\nS|1⟩ = i|1⟩\n\nMatrix: [[1,0],[0,i]]\n\nS = √Z and S† (S-dagger) is its inverse. Two S gates equal one Z gate: S² = Z.',
        formula: 'S = [[1, 0], [0, i]]',
      ),
      LessonPage(
        title: 'The T Gate',
        content: 'The T gate applies a 45° (π/4) phase shift:\n\nT|0⟩ = |0⟩\nT|1⟩ = e^(iπ/4)|1⟩\n\nMatrix: [[1,0],[0,e^(iπ/4)]]\n\nT = ⁴√Z. Two T gates equal one S gate. Four T gates equal one Z gate.\n\nCritically, {H, T, CNOT} form a universal gate set for quantum computing.',
        formula: 'T = [[1, 0], [0, e^(iπ/4)]]',
      ),
    ],
  ),
  LessonData(
    id: 'measurement',
    title: 'Measurement',
    subtitle: 'Extracting classical information from qubits',
    icon: '📊',
    color: AppTheme.accent,
    pages: [
      LessonPage(
        title: 'The Measurement Problem',
        content: 'Measurement is the process of extracting classical information from a quantum state. When you measure a qubit:\n\n1. The qubit collapses to |0⟩ or |1⟩\n2. The probability of each outcome is |α|² or |β|²\n3. After measurement, the qubit is in the measured state\n4. Superposition is irreversibly destroyed\n\nThis is why quantum algorithms extract information efficiently before measurement.',
      ),
      LessonPage(
        title: 'Measurement Bases',
        content: 'You can measure in different bases:\n\n• Z-basis (computational): {|0⟩, |1⟩} — standard\n• X-basis: {|+⟩, |−⟩} — apply H before measuring\n• Y-basis: {|i+⟩, |i−⟩} — apply S†H before measuring\n\nChoosing the right measurement basis is crucial. Quantum key distribution uses random basis choices to detect eavesdroppers.',
        formula: 'P(0) = |α|², P(1) = |β|²',
      ),
      LessonPage(
        title: 'Projective Measurement',
        content: 'Formally, a measurement in the Z-basis is described by projectors:\n\nP₀ = |0⟩⟨0| = [[1,0],[0,0]]\nP₁ = |1⟩⟨1| = [[0,0],[0,1]]\n\nThe probability of outcome k is ⟨ψ|Pₖ|ψ⟩, and after measurement the state collapses to Pₖ|ψ⟩ (normalized).\n\nFor multi-qubit systems, you can measure individual qubits, and the remaining qubits collapse accordingly.',
        formula: 'P(k) = ⟨ψ|Pₖ|ψ⟩',
      ),
    ],
  ),
];

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

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
                  Text('Learn Quantum Computing',
                          style: Theme.of(context).textTheme.displaySmall)
                      .animate()
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    '8 interactive lessons from qubits to quantum algorithms',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _LessonCard(
                  lesson: allLessons[i],
                  index: i,
                ),
                childCount: allLessons.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _LessonCard extends StatefulWidget {
  final LessonData lesson;
  final int index;

  const _LessonCard({required this.lesson, required this.index});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailScreen(lesson: l),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: AppTheme.glowCard(
            glowColor: _hovered ? l.color : AppTheme.border,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: l.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: l.color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    l.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lesson ${widget.index + 1}',
                      style: TextStyle(
                        color: l.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l.pages.length} pages',
                      style: TextStyle(
                        color: l.color.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
                child: Icon(Icons.chevron_right_rounded,
                    color: l.color.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 100 * widget.index), duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }
}
