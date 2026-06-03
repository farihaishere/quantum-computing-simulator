import 'dart:math' as math;
import '../models/qubit.dart';
import '../models/quantum_gate.dart';
import '../models/quantum_circuit.dart';

/// Pure-Dart statevector quantum simulator.
///
/// Supports up to 4 qubits. Applies gates via tensor products and
/// matrix-vector multiplication on the full statevector.
class QuantumEngine {
  /// Simulate a quantum circuit and return the final statevector.
  static Qubit simulate(QuantumCircuit circuit) {
    var state = Qubit(circuit.numQubits);
    final ops = circuit.sortedOperations;
    for (final op in ops) {
      if (op.gate.type == GateType.measure) continue; // Skip measurement placeholders
      state = _applyOperation(state, op);
    }
    return state.normalize();
  }

  /// Simulate step-by-step, returning statevector after each operation.
  static List<Qubit> simulateStepByStep(QuantumCircuit circuit) {
    final steps = <Qubit>[];
    var state = Qubit(circuit.numQubits);
    steps.add(state);
    final ops = circuit.sortedOperations;
    for (final op in ops) {
      if (op.gate.type == GateType.measure) continue;
      state = _applyOperation(state, op);
      steps.add(state.normalize());
    }
    return steps;
  }

  /// Apply a single gate operation to the statevector.
  static Qubit _applyOperation(Qubit state, CircuitOperation op) {
    if (op.gate.numQubits == 1) {
      return _applySingleQubitGate(state, op.gate.matrix, op.targetQubit);
    } else {
      final ctrl = op.controlQubit;
      if (ctrl != null) {
        return _applyTwoQubitGate(state, op.gate.matrix, ctrl, op.targetQubit);
      }
      return state;
    }
  }

  /// Apply a 2×2 single-qubit gate matrix to qubit [qubitIndex].
  static Qubit _applySingleQubitGate(
      Qubit state, List<Complex> gateMatrix, int qubitIndex) {
    final n = state.numQubits;
    final dim = 1 << n;
    final newAmps = List<Complex>.filled(dim, const Complex.zero());

    for (int i = 0; i < dim; i++) {
      // Determine if bit [qubitIndex] is 0 or 1 in state |i⟩
      // Bit ordering: qubit 0 is the most significant bit
      final bit = (i >> (n - 1 - qubitIndex)) & 1;
      if (bit == 0) {
        // i has qubit=0, pair state has qubit=1 (flip that bit)
        final j = i | (1 << (n - 1 - qubitIndex));
        // newAmps[i] += g[0][0] * amp[i] + g[0][1] * amp[j]
        // newAmps[j] += g[1][0] * amp[i] + g[1][1] * amp[j]
        newAmps[i] = newAmps[i] +
            gateMatrix[0] * state.amplitudes[i] +
            gateMatrix[1] * state.amplitudes[j];
        newAmps[j] = newAmps[j] +
            gateMatrix[2] * state.amplitudes[i] +
            gateMatrix[3] * state.amplitudes[j];
      }
    }
    return Qubit.fromAmplitudes(newAmps);
  }

  /// Apply a 4×4 two-qubit gate to qubits [controlIndex] and [targetIndex].
  static Qubit _applyTwoQubitGate(
      Qubit state, List<Complex> gateMatrix, int controlIndex, int targetIndex) {
    final n = state.numQubits;
    final dim = 1 << n;
    final newAmps = List<Complex>.filled(dim, const Complex.zero());

    for (int i = 0; i < dim; i++) {
      final cBit = (i >> (n - 1 - controlIndex)) & 1;
      final tBit = (i >> (n - 1 - targetIndex)) & 1;
      final row = (cBit << 1) | tBit; // 0,1,2,3

      // Find the four basis states that pair with this row
      for (int col = 0; col < 4; col++) {
        final newCBit = (col >> 1) & 1;
        final newTBit = col & 1;

        // Build the index j by flipping the control and target bits
        var j = i;
        // Set control bit
        if (newCBit == 1) {
          j = j | (1 << (n - 1 - controlIndex));
        } else {
          j = j & ~(1 << (n - 1 - controlIndex));
        }
        // Set target bit
        if (newTBit == 1) {
          j = j | (1 << (n - 1 - targetIndex));
        } else {
          j = j & ~(1 << (n - 1 - targetIndex));
        }

        final matVal = gateMatrix[row * 4 + col];
        if (matVal.magnitude > 1e-12) {
          newAmps[i] = newAmps[i] + matVal * state.amplitudes[j];
        }
      }
    }
    return Qubit.fromAmplitudes(newAmps);
  }

  /// Compute expectation value of Z operator on a given qubit.
  static double expectationZ(Qubit state, int qubitIndex) {
    final n = state.numQubits;
    double exp = 0.0;
    for (int i = 0; i < (1 << n); i++) {
      final bit = (i >> (n - 1 - qubitIndex)) & 1;
      final sign = bit == 0 ? 1.0 : -1.0;
      exp += sign * state.amplitudes[i].magnitudeSquared;
    }
    return exp;
  }

  /// Compute Bloch sphere vector (x,y,z) for a given qubit (partial trace for multi-qubit).
  static (double x, double y, double z) blochVector(Qubit state, int qubitIndex) {
    if (state.numQubits == 1) {
      final (theta, phi) = state.blochAngles;
      return (
        math.sin(theta) * math.cos(phi),
        math.sin(theta) * math.sin(phi),
        math.cos(theta),
      );
    }
    // For multi-qubit: compute reduced density matrix diagonal
    final n = state.numQubits;
    // rho_00, rho_11 (populations), rho_01 (coherence)
    double rho00 = 0, rho11 = 0;
    Complex rho01 = const Complex.zero();
    for (int i = 0; i < (1 << n); i++) {
      final bit = (i >> (n - 1 - qubitIndex)) & 1;
      if (bit == 0) {
        // |0⟩ component for this qubit
        rho00 += state.amplitudes[i].magnitudeSquared;
        // Find paired state where this qubit is |1⟩
        final j = i | (1 << (n - 1 - qubitIndex));
        rho01 = rho01 + state.amplitudes[i] * state.amplitudes[j].conjugate;
      } else {
        rho11 += state.amplitudes[i].magnitudeSquared;
      }
    }
    final x = 2 * rho01.real;
    final y = -2 * rho01.imaginary;
    final z = rho00 - rho11;
    return (x, y, z);
  }
}
