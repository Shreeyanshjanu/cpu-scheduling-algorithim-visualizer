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
      color: const Color(0xFF2D2D2D),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visualized Graph 📊 & CPU Table 💻',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
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

    return Container(
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
          // Third row: Empty spacer
          TableRow(
            children: [
              Container(
                height: 8,
                color: const Color(0xFF1E1E1E),
              ),
              ...List.generate(
                resultBlocks.length,
                (_) => Container(
                  height: 8,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          // Fourth row: Process blocks
          TableRow(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                ),
              ),
              ...resultBlocks.map((block) {
                if (block.processId == -1) {
                  return _buildProcessCell(
                    'IDLE',
                    block.duration,
                    const Color(0xFF2A2A2A),
                    isIdle: true,
                  );
                }
                return _buildProcessCell(
                  'P${block.processId}',
                  block.duration,
                  _getProcessColor(block.processId),
                );
              }),
            ],
          ),
          // Fifth row: Empty spacer
          TableRow(
            children: [
              Container(
                height: 8,
                color: const Color(0xFF1E1E1E),
              ),
              ...List.generate(
                resultBlocks.length,
                (_) => Container(
                  height: 8,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          // Sixth row: Durations
          TableRow(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                ),
              ),
              ...resultBlocks
                  .map((block) => _buildTimeCell(block.duration.toString())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTimeCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildProcessCell(
    String label,
    int duration,
    Color color, {
    bool isIdle = false,
  }) {
    return Container(
      width: duration * 35.0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isIdle ? Colors.white54 : Colors.white,
        ),
      ),
    );
  }

  Color _getProcessColor(int processId) {
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Red-Orange
      const Color(0xFFFF9800), // Orange
      const Color(0xFF009688), // Teal
      const Color(0xFFFFEB3B), // Yellow
    ];
    return colors[processId % colors.length];
  }
}
