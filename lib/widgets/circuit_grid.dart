import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/quantum_gate.dart';
import '../models/quantum_circuit.dart';

/// The drag-and-drop quantum circuit grid.
class CircuitGrid extends StatelessWidget {
  final QuantumCircuit circuit;
  final ValueChanged<QuantumCircuit> onCircuitChanged;

  const CircuitGrid({
    super.key,
    required this.circuit,
    required this.onCircuitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step labels
          Row(
            children: [
              const SizedBox(width: 80), // qubit label space
              ...List.generate(circuit.maxSteps, (step) => _StepLabel(step: step)),
            ],
          ),
          const SizedBox(height: 4),
          // Qubit rows
          ...List.generate(circuit.numQubits, (qubit) {
            return _QubitRow(
              qubit: qubit,
              circuit: circuit,
              onCircuitChanged: onCircuitChanged,
            );
          }),
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final int step;
  const _StepLabel({required this.step});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Center(
        child: Text(
          't$step',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _QubitRow extends StatelessWidget {
  final int qubit;
  final QuantumCircuit circuit;
  final ValueChanged<QuantumCircuit> onCircuitChanged;

  const _QubitRow({
    required this.qubit,
    required this.circuit,
    required this.onCircuitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          // Qubit label
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'q$qubit',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          // Wire + cells
          ...List.generate(circuit.maxSteps, (step) {
            return _CircuitCell(
              step: step,
              qubit: qubit,
              circuit: circuit,
              onCircuitChanged: onCircuitChanged,
            );
          }),
        ],
      ),
    );
  }
}

class _CircuitCell extends StatefulWidget {
  final int step;
  final int qubit;
  final QuantumCircuit circuit;
  final ValueChanged<QuantumCircuit> onCircuitChanged;

  const _CircuitCell({
    required this.step,
    required this.qubit,
    required this.circuit,
    required this.onCircuitChanged,
  });

  @override
  State<_CircuitCell> createState() => _CircuitCellState();
}

class _CircuitCellState extends State<_CircuitCell> {
  bool _isHovered = false;
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final op = widget.circuit.operationAt(widget.step, widget.qubit);
    final isTarget = op != null && op.targetQubit == widget.qubit;
    final isControl = op != null && op.controlQubit == widget.qubit;

    return DragTarget<QuantumGate>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        final gate = details.data;
        CircuitOperation newOp;
        if (gate.numQubits == 2) {
          // For 2-qubit gate: control = qubit-1 if possible, else qubit+1
          final ctrl = widget.qubit > 0 ? widget.qubit - 1 : widget.qubit + 1;
          newOp = CircuitOperation(
            gate: gate,
            targetQubit: widget.qubit,
            controlQubit: ctrl < widget.circuit.numQubits ? ctrl : null,
            step: widget.step,
          );
        } else {
          newOp = CircuitOperation(
            gate: gate,
            targetQubit: widget.qubit,
            step: widget.step,
          );
        }
        widget.onCircuitChanged(widget.circuit.addOperation(newOp));
      },
      builder: (context, candidateData, rejectedData) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onSecondaryTap: () {
              // Right-click to remove
              widget.onCircuitChanged(
                  widget.circuit.removeOperation(widget.step, widget.qubit));
            },
            child: SizedBox(
              width: 64,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wire
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 35,
                    child: Container(
                      height: 2,
                      color: AppTheme.border,
                    ),
                  ),
                  // Vertical connector for 2-qubit gates
                  if (isControl || (op != null && op.gate.numQubits > 1 && isTarget))
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 30,
                      child: Container(
                        width: 2,
                        color: op.gate.color.withOpacity(0.5),
                      ),
                    ),
                  // Gate cell content
                  if (op != null)
                    _GateCell(
                      op: op,
                      isTarget: isTarget,
                      isControl: isControl,
                      onRemove: () => widget.onCircuitChanged(
                          widget.circuit.removeOperation(widget.step, widget.qubit)),
                    )
                  else
                    // Empty drop zone
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isDragOver
                            ? AppTheme.primary.withOpacity(0.15)
                            : _isHovered
                                ? AppTheme.border.withOpacity(0.3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isDragOver
                              ? AppTheme.primary.withOpacity(0.7)
                              : _isHovered
                                  ? AppTheme.border
                                  : Colors.transparent,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _isDragOver || _isHovered
                          ? const Icon(Icons.add,
                              color: AppTheme.textMuted, size: 18)
                          : null,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GateCell extends StatelessWidget {
  final CircuitOperation op;
  final bool isTarget;
  final bool isControl;
  final VoidCallback onRemove;

  const _GateCell({
    required this.op,
    required this.isTarget,
    required this.isControl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final gate = op.gate;
    if (isControl && op.gate.numQubits == 2) {
      // Control dot
      return GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: gate.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: gate.color.withOpacity(0.4), blurRadius: 8)
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onRemove,
      child: Tooltip(
        message: '${gate.name}: ${gate.description}\n(Click to remove)',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: gate.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gate.color, width: 2),
            boxShadow: [
              BoxShadow(
                  color: gate.color.withOpacity(0.25), blurRadius: 10)
            ],
          ),
          child: Center(
            child: Text(
              gate.symbol,
              style: TextStyle(
                color: gate.color,
                fontSize: gate.symbol.length > 2 ? 10 : 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
