import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:os_project/models/algorithim_type.dart';
import '../models/process_model.dart';

class ProcessTable extends StatefulWidget {
  final List<Process> processes;
  final AlgorithmType selectedAlgorithm;
  final VoidCallback onProcessChanged;
  final VoidCallback onAddProcess;
  final VoidCallback onDeleteProcess;

  const ProcessTable({
    super.key,
    required this.processes,
    required this.selectedAlgorithm,
    required this.onProcessChanged,
    required this.onAddProcess,
    required this.onDeleteProcess,
  });

  @override
  State<ProcessTable> createState() => _ProcessTableState();
}

class _ProcessTableState extends State<ProcessTable> {
  @override
  Widget build(BuildContext context) {
    // Get screen width to make responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      color: const Color(0xFF2D2D2D),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Wrap the table in SingleChildScrollView for horizontal scrolling
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF404040),
                    width: 1,
                  ),
                ),
                child: Table(
                  border: TableBorder.symmetric(
                    inside: const BorderSide(
                      color: Color(0xFF404040),
                      width: 1,
                    ),
                  ),
                  columnWidths: {
                    0: FixedColumnWidth(isSmallScreen ? 80 : 100),
                    1: FixedColumnWidth(isSmallScreen ? 120 : 140),
                    2: FixedColumnWidth(isSmallScreen ? 120 : 140),
                    if (widget.selectedAlgorithm != AlgorithmType.robin)
                      3: FixedColumnWidth(isSmallScreen ? 120 : 140),
                    if (widget.selectedAlgorithm == AlgorithmType.priority)
                      4: FixedColumnWidth(isSmallScreen ? 100 : 120),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3A),
                      ),
                      children: [
                        _buildHeaderCell('Process\nID'),
                        _buildHeaderCell('Arrival\nTime'),
                        _buildHeaderCell('Burst\nTime'),
                        if (widget.selectedAlgorithm != AlgorithmType.robin)
                          _buildHeaderCell('Service\nTime'),
                        if (widget.selectedAlgorithm == AlgorithmType.priority)
                          _buildHeaderCell('Priority'),
                      ],
                    ),
                    // Data Rows
                    ...widget.processes.map((process) => _buildDataRow(process)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.onAddProcess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: widget.processes.length > 1 ? widget.onDeleteProcess : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.processes.length > 1
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF404040),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: widget.processes.length > 1 ? 4 : 0,
                  ),
                  child: const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.white70,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.visible,
      ),
    );
  }

  TableRow _buildDataRow(Process process) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      children: [
        _buildDataCell('P${process.id}'),
        // Make Arrival Time editable
        _EditableCell(
          key: ValueKey('arrival_${process.id}'),
          initialValue: process.arrivalTime,
          onChanged: (value) {
            process.arrivalTime = value;
            widget.onProcessChanged();
          },
        ),
        // Burst Time (Execute Time)
        _EditableCell(
          key: ValueKey('burst_${process.id}'),
          initialValue: process.executeTime,
          onChanged: (value) {
            process.executeTime = value;
            widget.onProcessChanged();
          },
        ),
        if (widget.selectedAlgorithm != AlgorithmType.robin)
          _buildDataCell('${process.serviceTime}'),
        if (widget.selectedAlgorithm == AlgorithmType.priority)
          _EditableCell(
            key: ValueKey('priority_${process.id}'),
            initialValue: process.priority,
            onChanged: (value) {
              process.priority = value;
              widget.onProcessChanged();
            },
          ),
      ],
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Separate StatefulWidget for editable cells
class _EditableCell extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _EditableCell({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void didUpdateWidget(_EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the value changed externally
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Color(0xFF404040),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Color(0xFF404040),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Color(0xFF2196F3),
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          isDense: true,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            widget.onChanged(int.tryParse(value) ?? 0);
          }
        },
      ),
    );
  }
}
