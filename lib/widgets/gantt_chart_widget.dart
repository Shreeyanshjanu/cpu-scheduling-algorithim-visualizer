import 'package:flutter/material.dart';
import '../models/process_model.dart';

class GanttChartWidget extends StatelessWidget {
  final List<ResultBlock> resultBlocks;

  const GanttChartWidget({
    super.key,
    required this.resultBlocks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visualized Graph 📊 & CPU Table 💻',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildGanttChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGanttChart() {
    // Calculate cumulative times
    List<int> startTimes = [];
    List<int> endTimes = [];
    int currentTime = 0;

    for (var block in resultBlocks) {
      startTimes.add(currentTime);
      currentTime += block.duration;
      endTimes.add(currentTime);
    }

    return Table(
      border: TableBorder.all(color: Colors.black),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        // First row: CPU Idle (start times)
        TableRow(
          children: [
            _buildHeaderCell('CPU Idle'),
            ...startTimes.map((time) => _buildTimeCell(time.toString())),
          ],
        ),
        // Second row: CPU Idle (end times)
        TableRow(
          children: [
            _buildHeaderCell('CPU Idle'),
            ...endTimes.map((time) => _buildTimeCell(time.toString())),
          ],
        ),
        // Third row: Process blocks
        TableRow(
          children: [
            Container(), // Empty cell for alignment
            ...resultBlocks.map((block) {
              if (block.processId == -1) {
                return _buildProcessCell('IDLE', block.duration, Colors.white, isIdle: true);
              }
              return _buildProcessCell(
                'P${block.processId}',
                block.duration,
                _getProcessColor(block.processId),
              );
            }),
          ],
        ),
        // Fourth row: Durations
        TableRow(
          children: [
            Container(), // Empty cell for alignment
            ...resultBlocks.map((block) => _buildTimeCell(block.duration.toString())),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTimeCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildProcessCell(String label, int duration, Color color, {bool isIdle = false}) {
    return Container(
      width: duration * 30.0, // Adjust width based on duration
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isIdle ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

  Color _getProcessColor(int processId) {
    final colors = [
      Colors.pink.shade200,
      Colors.green.shade300,
      Colors.lightBlue.shade200,
      Colors.purple.shade200,
      Colors.red.shade200,
      Colors.orange.shade200,
      Colors.teal.shade200,
      Colors.amber.shade200,
    ];
    return colors[processId % colors.length];
  }
}
