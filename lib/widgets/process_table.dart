import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:os_project/models/algorithim_type.dart';
import '../models/process_model.dart';


class ProcessTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Get screen width to make responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Wrap the table in SingleChildScrollView for horizontal scrolling
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: {
                  0: FixedColumnWidth(isSmallScreen ? 70 : 80),
                  1: FixedColumnWidth(isSmallScreen ? 100 : 120), // Arrival Time (now editable)
                  2: FixedColumnWidth(isSmallScreen ? 100 : 120), // Burst Time
                  if (selectedAlgorithm != AlgorithmType.robin)
                    3: FixedColumnWidth(isSmallScreen ? 100 : 120),
                  if (selectedAlgorithm == AlgorithmType.priority)
                    4: FixedColumnWidth(isSmallScreen ? 80 : 100),
                },
                children: [
                  // Header Row
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    children: [
                      _buildHeaderCell('Process\nID'),
                      _buildHeaderCell('Arrival\nTime'),
                      _buildHeaderCell('Burst\nTime'),
                      if (selectedAlgorithm != AlgorithmType.robin)
                        _buildHeaderCell('Service\nTime'),
                      if (selectedAlgorithm == AlgorithmType.priority)
                        _buildHeaderCell('Priority'),
                    ],
                  ),
                  // Data Rows
                  ...processes.map((process) => _buildDataRow(process)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onAddProcess,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('+', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: processes.length > 1 ? onDeleteProcess : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('-', style: TextStyle(fontSize: 18)),
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
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.visible,
      ),
    );
  }


  TableRow _buildDataRow(Process process) {
    return TableRow(
      children: [
        _buildDataCell('P${process.id}'),
        // Make Arrival Time editable
        _buildEditableCell(
          process.arrivalTime.toString(),
          (value) {
            if (value.isNotEmpty) {
              process.arrivalTime = int.tryParse(value) ?? 0;
              onProcessChanged();
            }
          },
        ),
        // Burst Time (Execute Time)
        _buildEditableCell(
          process.executeTime.toString(),
          (value) {
            if (value.isNotEmpty) {
              process.executeTime = int.tryParse(value) ?? 0;
              onProcessChanged();
            }
          },
        ),
        if (selectedAlgorithm != AlgorithmType.robin)
          _buildDataCell('${process.serviceTime}'),
        if (selectedAlgorithm == AlgorithmType.priority)
          _buildEditableCell(
            process.priority.toString(),
            (value) {
              if (value.isNotEmpty) {
                process.priority = int.tryParse(value) ?? 0;
                onProcessChanged();
              }
            },
          ),
      ],
    );
  }


  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }


  Widget _buildEditableCell(String initialValue, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
