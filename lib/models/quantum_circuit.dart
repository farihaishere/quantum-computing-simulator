import 'quantum_gate.dart';

/// A single gate placed on one or more qubits at a given time step.
class CircuitOperation {
  final QuantumGate gate;
  final int targetQubit;    // Primary target
  final int? controlQubit;  // For 2-qubit gates (CNOT, CZ, SWAP)
  final int step;           // Time step (column) in the circuit

  const CircuitOperation({
    required this.gate,
    required this.targetQubit,
    this.controlQubit,
    required this.step,
  });

  CircuitOperation copyWith({
    QuantumGate? gate,
    int? targetQubit,
    int? controlQubit,
    int? step,
  }) {
    return CircuitOperation(
      gate: gate ?? this.gate,
      targetQubit: targetQubit ?? this.targetQubit,
      controlQubit: controlQubit ?? this.controlQubit,
      step: step ?? this.step,
    );
  }

  @override
  String toString() =>
      '${gate.symbol} on q$targetQubit${controlQubit != null ? ' (ctrl: q$controlQubit)' : ''} @ step $step';
}

/// A quantum circuit with N qubits and a list of operations.
class QuantumCircuit {
  final int numQubits;
  final int maxSteps;
  final List<CircuitOperation> operations;

  const QuantumCircuit({
    required this.numQubits,
    this.maxSteps = 8,
    this.operations = const [],
  });

  QuantumCircuit copyWith({
    int? numQubits,
    int? maxSteps,
    List<CircuitOperation>? operations,
  }) {
    return QuantumCircuit(
      numQubits: numQubits ?? this.numQubits,
      maxSteps: maxSteps ?? this.maxSteps,
      operations: operations ?? this.operations,
    );
  }

  /// Add a gate operation and return the updated circuit.
  QuantumCircuit addOperation(CircuitOperation op) {
    // Remove any existing op at same (step, qubit) to replace it
    final filtered = operations.where((o) {
      if (o.step == op.step) {
        if (o.targetQubit == op.targetQubit) return false;
        if (o.controlQubit != null && o.controlQubit == op.targetQubit) return false;
        if (op.controlQubit != null && o.targetQubit == op.controlQubit) return false;
      }
      return true;
    }).toList();
    return copyWith(operations: [...filtered, op]);
  }

  /// Remove operation at a given step and qubit.
  QuantumCircuit removeOperation(int step, int qubit) {
    final filtered = operations.where((o) {
      if (o.step == step) {
        if (o.targetQubit == qubit) return false;
        if (o.controlQubit == qubit) return false;
      }
      return true;
    }).toList();
    return copyWith(operations: filtered);
  }

  /// Get operations sorted by step for simulation.
  List<CircuitOperation> get sortedOperations {
    final sorted = [...operations];
    sorted.sort((a, b) => a.step.compareTo(b.step));
    return sorted;
  }

  /// Check if a cell (step, qubit) has a gate.
  CircuitOperation? operationAt(int step, int qubit) {
    try {
      return operations.firstWhere(
        (o) => o.step == step &&
               (o.targetQubit == qubit || o.controlQubit == qubit),
      );
    } catch (_) {
      return null;
    }
  }

  bool get isEmpty => operations.isEmpty;

  QuantumCircuit clear() => copyWith(operations: []);
}

/// Pre-built algorithm circuits
class AlgorithmCircuits {
  static QuantumCircuit bellState() {
    final ops = [
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 0),
      CircuitOperation(gate: QuantumGate.byType(GateType.cnot), targetQubit: 1, controlQubit: 0, step: 1),
    ];
    return QuantumCircuit(numQubits: 2, operations: ops);
  }

  static QuantumCircuit deutschJozsa() {
    // Constant oracle (all 0s) — simplified 2-qubit version
    final ops = [
      CircuitOperation(gate: QuantumGate.byType(GateType.x), targetQubit: 1, step: 0),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 1),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 1, step: 1),
      CircuitOperation(gate: QuantumGate.byType(GateType.cnot), targetQubit: 1, controlQubit: 0, step: 2),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 3),
    ];
    return QuantumCircuit(numQubits: 2, operations: ops);
  }

  static QuantumCircuit grover2Qubit() {
    // Grover's for 2-qubit, target state |11⟩
    final ops = [
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 0),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 1, step: 0),
      // Oracle: phase flip |11⟩ via CZ
      CircuitOperation(gate: QuantumGate.byType(GateType.cz), targetQubit: 1, controlQubit: 0, step: 1),
      // Diffusion operator
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 2),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 1, step: 2),
      CircuitOperation(gate: QuantumGate.byType(GateType.x), targetQubit: 0, step: 3),
      CircuitOperation(gate: QuantumGate.byType(GateType.x), targetQubit: 1, step: 3),
      CircuitOperation(gate: QuantumGate.byType(GateType.cz), targetQubit: 1, controlQubit: 0, step: 4),
      CircuitOperation(gate: QuantumGate.byType(GateType.x), targetQubit: 0, step: 5),
      CircuitOperation(gate: QuantumGate.byType(GateType.x), targetQubit: 1, step: 5),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 6),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 1, step: 6),
    ];
    return QuantumCircuit(numQubits: 2, maxSteps: 8, operations: ops);
  }

  static QuantumCircuit teleportation() {
    // Quantum teleportation (3 qubits: message, Alice, Bob)
    final ops = [
      // Prepare message qubit in |+⟩
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 0),
      // Create Bell pair between Alice (q1) and Bob (q2)
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 1, step: 1),
      CircuitOperation(gate: QuantumGate.byType(GateType.cnot), targetQubit: 2, controlQubit: 1, step: 2),
      // Bell measurement on q0, q1
      CircuitOperation(gate: QuantumGate.byType(GateType.cnot), targetQubit: 1, controlQubit: 0, step: 3),
      CircuitOperation(gate: QuantumGate.byType(GateType.h), targetQubit: 0, step: 4),
      // Corrections on Bob's qubit
      CircuitOperation(gate: QuantumGate.byType(GateType.cnot), targetQubit: 2, controlQubit: 1, step: 5),
      CircuitOperation(gate: QuantumGate.byType(GateType.cz), targetQubit: 2, controlQubit: 0, step: 6),
    ];
    return QuantumCircuit(numQubits: 3, maxSteps: 8, operations: ops);
  }
}
