import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/quantum_gate.dart';

/// A draggable gate chip used in the gate palette.
class DraggableGateChip extends StatelessWidget {
  final QuantumGate gate;

  const DraggableGateChip({super.key, required this.gate});

  @override
  Widget build(BuildContext context) {
    return Draggable<QuantumGate>(
      data: gate,
      feedback: Material(
        color: Colors.transparent,
        child: _GateChip(gate: gate, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _GateChip(gate: gate),
      ),
      child: _GateChip(gate: gate),
    );
  }
}

class _GateChip extends StatefulWidget {
  final QuantumGate gate;
  final bool isDragging;

  const _GateChip({required this.gate, this.isDragging = false});

  @override
  State<_GateChip> createState() => _GateChipState();
}

class _GateChipState extends State<_GateChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final gate = widget.gate;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: gate.color.withOpacity(_hovered || widget.isDragging ? 0.25 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gate.color.withOpacity(_hovered || widget.isDragging ? 0.9 : 0.5),
            width: 1.5,
          ),
          boxShadow: _hovered || widget.isDragging
              ? [BoxShadow(color: gate.color.withOpacity(0.3), blurRadius: 12)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gate.symbol,
              style: TextStyle(
                color: gate.color,
                fontSize: gate.symbol.length > 2 ? 11 : 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              gate.name.length > 8 ? gate.name.substring(0, 7) : gate.name,
              style: TextStyle(
                color: gate.color.withOpacity(0.7),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// The gate palette panel with single-qubit and two-qubit gates.
class GatePalette extends StatefulWidget {
  const GatePalette({super.key});

  @override
  State<GatePalette> createState() => _GatePaletteState();
}

class _GatePaletteState extends State<GatePalette>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.surfaceCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text('Gate Palette',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tab,
            tabs: const [Tab(text: '1-Qubit'), Tab(text: '2-Qubit')],
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            dividerColor: AppTheme.border,
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _GateGrid(gates: QuantumGate.singleQubitGates),
                _GateGrid(gates: QuantumGate.twoQubitGates),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Drag gates onto the circuit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GateGrid extends StatelessWidget {
  final List<QuantumGate> gates;
  const _GateGrid({required this.gates});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: gates.map((g) => DraggableGateChip(gate: g)).toList(),
      ),
    );
  }
}
