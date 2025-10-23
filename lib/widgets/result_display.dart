import 'package:flutter/material.dart';
import '../models/process_model.dart';

class ResultDisplay extends StatelessWidget {
  final List<ResultBlock> resultBlocks;
  final double animationProgress;
  final int currentTimer;

  const ResultDisplay({
    super.key,
    required this.resultBlocks,
    required this.animationProgress,
    required this.currentTimer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Result:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF2D2D2D),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Process blocks table
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
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        // Process names row
                        TableRow(
                          children: resultBlocks.map((block) {
                            return Container(
                              height: 60,
                              width: block.duration * 25.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: block.processId == -1
                                    ? const Color(0xFF2A2A2A)
                                    : _getProcessColor(block.processId),
                              ),
                              child: Text(
                                block.processId == -1
                                    ? 'IDLE'
                                    : 'P${block.processId}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: block.processId == -1
                                      ? Colors.white54
                                      : Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        // Duration row
                        TableRow(
                          children: resultBlocks.map((block) {
                            return Container(
                              height: 35,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E1E1E),
                              ),
                              child: Text(
                                '${block.duration}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 24,
                    child: LinearProgressIndicator(
                      value: animationProgress,
                      backgroundColor: const Color(0xFF1E1E1E),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Timer
                Text(
                  'Timer: $currentTimer sec',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
