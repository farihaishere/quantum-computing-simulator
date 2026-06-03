import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'qubit.dart';

/// Types of quantum gates supported by the simulator.
enum GateType {
  x, y, z, h, s, t, sdg, tdg,
  cnot, swap, cz,
  rx, ry, rz,
  measure,
}

/// Definition of a quantum gate including its unitary matrix and metadata.
class QuantumGate {
  final GateType type;
  final String name;
  final String symbol;
  final String latex;
  final Color color;
  final String description;
  final String explanation;
  final int numQubits; // 1 for single-qubit, 2 for two-qubit
  final double? angle; // for rotation gates Rx, Ry, Rz

  const QuantumGate({
    required this.type,
    required this.name,
    required this.symbol,
    required this.latex,
    required this.color,
    required this.description,
    required this.explanation,
    this.numQubits = 1,
    this.angle,
  });

  /// Returns the 2×2 (or 4×4 for 2-qubit) unitary matrix as flat list row-major.
  List<Complex> get matrix {
    const i = Complex(0, 1);
    const negI = Complex(0, -1);
    const zero = Complex.zero();
    const one = Complex.one();
    final s2 = 1 / math.sqrt(2);
    final hs = Complex(s2, 0); // 1/√2

    switch (type) {
      case GateType.x:
        return [zero, one, one, zero];
      case GateType.y:
        return [zero, negI, i, zero];
      case GateType.z:
        return [one, zero, zero, Complex(-1, 0)];
      case GateType.h:
        return [hs, hs, hs, Complex(-s2, 0)];
      case GateType.s:
        return [one, zero, zero, i];
      case GateType.t:
        return [one, zero, zero, Complex.fromPolar(1, math.pi / 4)];
      case GateType.sdg:
        return [one, zero, zero, negI];
      case GateType.tdg:
        return [one, zero, zero, Complex.fromPolar(1, -math.pi / 4)];
      case GateType.rx:
        final a = angle ?? 0;
        return [
          Complex(math.cos(a / 2), 0),
          Complex(0, -math.sin(a / 2)),
          Complex(0, -math.sin(a / 2)),
          Complex(math.cos(a / 2), 0),
        ];
      case GateType.ry:
        final a = angle ?? 0;
        return [
          Complex(math.cos(a / 2), 0),
          Complex(-math.sin(a / 2), 0),
          Complex(math.sin(a / 2), 0),
          Complex(math.cos(a / 2), 0),
        ];
      case GateType.rz:
        final a = angle ?? 0;
        return [
          Complex.fromPolar(1, -a / 2),
          zero,
          zero,
          Complex.fromPolar(1, a / 2),
        ];
      case GateType.cnot:
        // 4x4: |00><00| + |01><01| + |11><10| + |10><11|
        return [
          one, zero, zero, zero,
          zero, one, zero, zero,
          zero, zero, zero, one,
          zero, zero, one, zero,
        ];
      case GateType.cz:
        return [
          one, zero, zero, zero,
          zero, one, zero, zero,
          zero, zero, one, zero,
          zero, zero, zero, Complex(-1, 0),
        ];
      case GateType.swap:
        return [
          one, zero, zero, zero,
          zero, zero, one, zero,
          zero, one, zero, zero,
          zero, zero, zero, one,
        ];
      case GateType.measure:
        return [one, zero, zero, zero]; // placeholder
    }
  }

  static final List<QuantumGate> singleQubitGates = [
    QuantumGate(
      type: GateType.h,
      name: 'Hadamard',
      symbol: 'H',
      latex: 'H',
      color: AppTheme.gateH,
      description: 'Creates superposition',
      explanation: 'The Hadamard gate puts a qubit into an equal superposition of |0⟩ and |1⟩. It maps |0⟩ → (|0⟩+|1⟩)/√2 and |1⟩ → (|0⟩−|1⟩)/√2.',
    ),
    QuantumGate(
      type: GateType.x,
      name: 'Pauli-X',
      symbol: 'X',
      latex: 'X',
      color: AppTheme.gateX,
      description: 'Quantum NOT gate',
      explanation: 'The Pauli-X gate flips |0⟩ to |1⟩ and |1⟩ to |0⟩. It is the quantum equivalent of the classical NOT gate.',
    ),
    QuantumGate(
      type: GateType.y,
      name: 'Pauli-Y',
      symbol: 'Y',
      latex: 'Y',
      color: AppTheme.gateY,
      description: 'Rotation around Y-axis',
      explanation: 'The Pauli-Y gate rotates the qubit state π radians around the Y-axis of the Bloch sphere. It maps |0⟩ → i|1⟩ and |1⟩ → -i|0⟩.',
    ),
    QuantumGate(
      type: GateType.z,
      name: 'Pauli-Z',
      symbol: 'Z',
      latex: 'Z',
      color: AppTheme.gateZ,
      description: 'Phase flip gate',
      explanation: 'The Pauli-Z gate leaves |0⟩ unchanged and flips the phase of |1⟩ to -|1⟩. It rotates π around the Z-axis of the Bloch sphere.',
    ),
    QuantumGate(
      type: GateType.s,
      name: 'S Gate',
      symbol: 'S',
      latex: 'S',
      color: AppTheme.gateS,
      description: 'π/2 phase shift',
      explanation: 'The S gate applies a 90° (π/2) phase shift to |1⟩. It is equivalent to T² and maps |1⟩ → i|1⟩.',
    ),
    QuantumGate(
      type: GateType.t,
      name: 'T Gate',
      symbol: 'T',
      latex: 'T',
      color: AppTheme.gateT,
      description: 'π/4 phase shift',
      explanation: 'The T gate applies a 45° (π/4) phase shift. It maps |1⟩ → e^(iπ/4)|1⟩. It is essential for universal quantum computing.',
    ),
    QuantumGate(
      type: GateType.rx,
      name: 'Rx(π/2)',
      symbol: 'Rx',
      latex: 'R_x(\\pi/2)',
      color: AppTheme.gateX,
      description: 'X-axis rotation',
      explanation: 'Rotates the qubit state around the X-axis of the Bloch sphere by angle θ = π/2.',
      angle: math.pi / 2,
    ),
    QuantumGate(
      type: GateType.ry,
      name: 'Ry(π/2)',
      symbol: 'Ry',
      latex: 'R_y(\\pi/2)',
      color: AppTheme.gateY,
      description: 'Y-axis rotation',
      explanation: 'Rotates the qubit state around the Y-axis of the Bloch sphere by angle θ = π/2.',
      angle: math.pi / 2,
    ),
    QuantumGate(
      type: GateType.rz,
      name: 'Rz(π/2)',
      symbol: 'Rz',
      latex: 'R_z(\\pi/2)',
      color: AppTheme.gateZ,
      description: 'Z-axis rotation',
      explanation: 'Rotates the qubit state around the Z-axis of the Bloch sphere by angle θ = π/2.',
      angle: math.pi / 2,
    ),
  ];

  static final List<QuantumGate> twoQubitGates = [
    QuantumGate(
      type: GateType.cnot,
      name: 'CNOT',
      symbol: 'CX',
      latex: 'CNOT',
      color: AppTheme.gateCNOT,
      description: 'Controlled-NOT',
      explanation: 'The CNOT gate flips the target qubit if the control qubit is |1⟩. It creates entanglement between qubits.',
      numQubits: 2,
    ),
    QuantumGate(
      type: GateType.cz,
      name: 'CZ',
      symbol: 'CZ',
      latex: 'CZ',
      color: AppTheme.secondary,
      description: 'Controlled-Z gate',
      explanation: 'The CZ gate applies a Z gate to the target if the control is |1⟩. Both qubits serve symmetrically.',
      numQubits: 2,
    ),
    QuantumGate(
      type: GateType.swap,
      name: 'SWAP',
      symbol: '⇄',
      latex: 'SWAP',
      color: AppTheme.accentGreen,
      description: 'Swap two qubits',
      explanation: 'The SWAP gate exchanges the quantum states of two qubits.',
      numQubits: 2,
    ),
  ];

  static List<QuantumGate> get allGates => [...singleQubitGates, ...twoQubitGates];

  static QuantumGate byType(GateType t) =>
      allGates.firstWhere((g) => g.type == t);
}
