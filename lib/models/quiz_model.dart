import 'package:shared_preferences/shared_preferences.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizTopic {
  final String id;
  final String title;
  final String icon;
  final List<QuizQuestion> questions;

  const QuizTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.questions,
  });
}

class QuizResult {
  final String topicId;
  final int score;
  final int total;
  final DateTime completedAt;

  QuizResult({
    required this.topicId,
    required this.score,
    required this.total,
    required this.completedAt,
  });

  double get percentage => total == 0 ? 0 : score / total;
  bool get passed => percentage >= 0.6;
}

class QuizProgress {
  static const String _prefix = 'quiz_score_';

  static Future<void> saveScore(String topicId, int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix${topicId}_score', score);
    await prefs.setInt('$_prefix${topicId}_total', total);
  }

  static Future<QuizResult?> loadResult(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('$_prefix${topicId}_score');
    final total = prefs.getInt('$_prefix${topicId}_total');
    if (score == null || total == null) return null;
    return QuizResult(
      topicId: topicId,
      score: score,
      total: total,
      completedAt: DateTime.now(),
    );
  }

  static Future<Map<String, QuizResult>> loadAll(List<String> ids) async {
    final results = <String, QuizResult>{};
    for (final id in ids) {
      final r = await loadResult(id);
      if (r != null) results[id] = r;
    }
    return results;
  }
}

/// All quiz data
class QuizData {
  static final List<QuizTopic> topics = [
    QuizTopic(
      id: 'qubits',
      title: 'Qubits & States',
      icon: '⚛️',
      questions: [
        QuizQuestion(
          question: 'What is a qubit?',
          options: [
            'A classical binary digit (0 or 1)',
            'A quantum bit that can exist in superposition of 0 and 1',
            'A unit of quantum memory storage',
            'A quantum error correction code',
          ],
          correctIndex: 1,
          explanation: 'A qubit is the basic unit of quantum information. Unlike classical bits, qubits can exist in a superposition of both 0 and 1 simultaneously.',
        ),
        QuizQuestion(
          question: 'How many complex amplitudes describe an n-qubit state?',
          options: ['n', 'n²', '2ⁿ', '2n'],
          correctIndex: 2,
          explanation: 'An n-qubit system is described by 2ⁿ complex amplitudes, one for each possible basis state.',
        ),
        QuizQuestion(
          question: 'What is the Bloch sphere?',
          options: [
            'A model for visualizing a single qubit state geometrically',
            'A quantum error model',
            'A type of quantum gate',
            'A measurement device',
          ],
          correctIndex: 0,
          explanation: 'The Bloch sphere is a geometric representation of a single qubit state, where the north pole is |0⟩ and the south pole is |1⟩.',
        ),
        QuizQuestion(
          question: 'What happens when you measure a qubit in superposition?',
          options: [
            'It stays in superposition',
            'It collapses to either |0⟩ or |1⟩ probabilistically',
            'It always returns |0⟩',
            'It splits into two qubits',
          ],
          correctIndex: 1,
          explanation: 'Measuring a qubit in superposition causes wavefunction collapse — it randomly becomes |0⟩ or |1⟩ with probabilities given by the squared amplitudes.',
        ),
        QuizQuestion(
          question: 'What constraint must qubit amplitudes satisfy?',
          options: [
            'Their sum equals 1',
            'Their squares sum to 1',
            'The sum of their magnitudes squared equals 1',
            'Each amplitude must be real',
          ],
          correctIndex: 2,
          explanation: 'Qubit amplitudes α and β must satisfy |α|² + |β|² = 1, ensuring total probability equals 1 (normalization condition).',
        ),
      ],
    ),
    QuizTopic(
      id: 'superposition',
      title: 'Superposition',
      icon: '🌊',
      questions: [
        QuizQuestion(
          question: 'Which gate creates superposition from |0⟩?',
          options: ['Pauli-X', 'Hadamard (H)', 'Pauli-Z', 'CNOT'],
          correctIndex: 1,
          explanation: 'The Hadamard gate maps |0⟩ to (|0⟩+|1⟩)/√2, creating an equal superposition of both basis states.',
        ),
        QuizQuestion(
          question: 'What is |+⟩?',
          options: [
            '(|0⟩ + |1⟩) / √2',
            '|0⟩ + |1⟩',
            '|0⟩',
            '(|0⟩ - |1⟩) / √2',
          ],
          correctIndex: 0,
          explanation: '|+⟩ = (|0⟩ + |1⟩) / √2 is the equal superposition state, the result of applying H to |0⟩.',
        ),
        QuizQuestion(
          question: 'What is the probability of measuring |1⟩ from the state (|0⟩ + i|1⟩) / √2?',
          options: ['0', '0.25', '0.5', '1'],
          correctIndex: 2,
          explanation: 'The probability is |i/√2|² = 1/2 = 0.5. The imaginary unit i has magnitude 1, so the amplitude magnitude is 1/√2.',
        ),
        QuizQuestion(
          question: 'Superposition is destroyed by what process?',
          options: ['Entanglement', 'Gate application', 'Measurement (decoherence)', 'Superposition cannot be destroyed'],
          correctIndex: 2,
          explanation: 'Measuring a qubit (or decoherence from environment interaction) collapses superposition into a definite classical state.',
        ),
        QuizQuestion(
          question: 'How many qubits are in |+⟩|0⟩?',
          options: ['1', '2', '3', '4'],
          correctIndex: 1,
          explanation: '|+⟩|0⟩ is a 2-qubit product state where the first qubit is in superposition and the second is in |0⟩.',
        ),
      ],
    ),
    QuizTopic(
      id: 'entanglement',
      title: 'Entanglement',
      icon: '🔗',
      questions: [
        QuizQuestion(
          question: 'What is a Bell state?',
          options: [
            'A single qubit superposition',
            'A maximally entangled 2-qubit state',
            'A quantum error correction code',
            'A 3-qubit entangled state',
          ],
          correctIndex: 1,
          explanation: 'Bell states are the four maximally entangled 2-qubit states. The most common is |Φ+⟩ = (|00⟩ + |11⟩) / √2.',
        ),
        QuizQuestion(
          question: 'Which circuit creates a Bell state from |00⟩?',
          options: [
            'H on q0, then X on q1',
            'H on q0, then CNOT (q0→q1)',
            'CNOT (q0→q1), then H on q0',
            'X on q0, then CNOT (q0→q1)',
          ],
          correctIndex: 1,
          explanation: 'Apply H to q0 to get superposition, then CNOT with q0 as control and q1 as target creates |Φ+⟩ = (|00⟩ + |11⟩) / √2.',
        ),
        QuizQuestion(
          question: 'If two qubits are maximally entangled and you measure one as |0⟩, what is the other?',
          options: [
            'Still in superposition',
            'Random with 50/50 probability',
            'Immediately determined (|0⟩ or |1⟩ depending on state)',
            'Undefined',
          ],
          correctIndex: 2,
          explanation: 'For Bell state (|00⟩+|11⟩)/√2: measuring q0=|0⟩ instantly collapses q1 to |0⟩, regardless of distance.',
        ),
        QuizQuestion(
          question: 'What does Einstein famously called entanglement?',
          options: [
            '"Quantum weirdness"',
            '"Spooky action at a distance"',
            '"Quantum teleportation"',
            '"Wavefunction collapse"',
          ],
          correctIndex: 1,
          explanation: 'Einstein called entanglement "spooky action at a distance" (spukhafte Fernwirkung), which troubled him as it seemed to violate locality.',
        ),
        QuizQuestion(
          question: 'Can entanglement be used to send information faster than light?',
          options: [
            'Yes, always',
            'Yes, but only in theory',
            'No — measurement outcomes are random and cannot carry a message',
            'Only with a quantum repeater',
          ],
          correctIndex: 2,
          explanation: 'No — while entangled qubits are correlated, measurement outcomes are random. You cannot control the result to send a message FTL.',
        ),
      ],
    ),
    QuizTopic(
      id: 'gates',
      title: 'Quantum Gates',
      icon: '🔧',
      questions: [
        QuizQuestion(
          question: 'What does the Pauli-X gate do?',
          options: [
            'Applies a phase flip',
            'Creates superposition',
            'Flips |0⟩ to |1⟩ and |1⟩ to |0⟩',
            'Swaps two qubits',
          ],
          correctIndex: 2,
          explanation: 'The X gate is the quantum NOT gate. Its matrix is [[0,1],[1,0]], swapping the |0⟩ and |1⟩ amplitudes.',
        ),
        QuizQuestion(
          question: 'What property must quantum gates satisfy?',
          options: ['Commutativity', 'Unitarity', 'Associativity', 'Linearity only'],
          correctIndex: 1,
          explanation: 'Quantum gates must be unitary (U†U = I) to preserve the total probability (normalization) of the quantum state.',
        ),
        QuizQuestion(
          question: 'The CNOT gate requires how many qubits?',
          options: ['1', '2', '3', '4'],
          correctIndex: 1,
          explanation: 'CNOT is a 2-qubit gate with one control qubit and one target qubit. It flips the target if and only if the control is |1⟩.',
        ),
        QuizQuestion(
          question: 'What does H·H equal?',
          options: ['2H', 'I (identity)', 'X gate', 'Z gate'],
          correctIndex: 1,
          explanation: 'The Hadamard gate is its own inverse: H² = I. Applying H twice returns the qubit to its original state.',
        ),
        QuizQuestion(
          question: 'Which set of gates is universal for quantum computing?',
          options: [
            '{H, X, Z}',
            '{H, T, CNOT}',
            '{X, Y, Z}',
            '{H, SWAP}',
          ],
          correctIndex: 1,
          explanation: '{H, T, CNOT} is a universal gate set — any unitary operation can be approximated to arbitrary precision using these gates.',
        ),
      ],
    ),
    QuizTopic(
      id: 'algorithms',
      title: 'Quantum Algorithms',
      icon: '🧮',
      questions: [
        QuizQuestion(
          question: 'What does Grover\'s algorithm achieve?',
          options: [
            'Exponential speedup for all problems',
            'Quadratic speedup for unstructured search',
            'Factoring large numbers',
            'Solving linear equations',
          ],
          correctIndex: 1,
          explanation: 'Grover\'s algorithm searches an unsorted database of N items in O(√N) time, a quadratic speedup over the classical O(N).',
        ),
        QuizQuestion(
          question: 'What does the Deutsch-Jozsa algorithm determine?',
          options: [
            'Whether a function is balanced or constant',
            'The prime factors of a number',
            'The optimal path in a graph',
            'The ground state energy of a molecule',
          ],
          correctIndex: 0,
          explanation: 'Deutsch-Jozsa determines if a Boolean function is constant (always 0 or 1) or balanced (half 0, half 1) in ONE query vs N/2+1 classically.',
        ),
        QuizQuestion(
          question: 'Quantum teleportation transfers:',
          options: [
            'Physical matter',
            'A qubit\'s quantum state (not the physical qubit)',
            'Classical information',
            'Energy between qubits',
          ],
          correctIndex: 1,
          explanation: 'Quantum teleportation transfers the exact quantum state of a qubit to another location using entanglement and classical communication.',
        ),
        QuizQuestion(
          question: 'Shor\'s algorithm is known for:',
          options: [
            'Searching databases',
            'Simulating quantum chemistry',
            'Factoring large integers exponentially faster',
            'Solving optimization problems',
          ],
          correctIndex: 2,
          explanation: 'Shor\'s algorithm factors an N-digit number in polynomial time O((log N)³), exponentially faster than the best known classical algorithm.',
        ),
        QuizQuestion(
          question: 'Which resource does quantum teleportation require besides entanglement?',
          options: [
            'Faster-than-light channel',
            'Classical communication channel',
            'A quantum repeater',
            'No additional resource',
          ],
          correctIndex: 1,
          explanation: 'Quantum teleportation requires a classical communication channel to send 2 classical bits of measurement results to the receiver.',
        ),
      ],
    ),
  ];
}
