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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Process blocks - FILTER OUT IDLE BLOCKS OR SHOW THEM CLEARLY
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: Colors.black),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      // Process names
                      TableRow(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade300],
                          ),
                        ),
                        children: resultBlocks.map((block) {
                          return Container(
                            height: 60,
                            width: block.duration * 20.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: block.processId == -1 
                                  ? Colors.white 
                                  : _getProcessColor(block.processId),
                            ),
                            child: Text(
                              block.processId == -1 
                                  ? 'IDLE' 
                                  : 'P${block.processId}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: block.processId == -1 
                                    ? Colors.grey 
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Duration
                      TableRow(
                        children: resultBlocks.map((block) {
                          return Container(
                            height: 30,
                            alignment: Alignment.center,
                            child: Text('${block.duration}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Animation progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 20,
                    child: LinearProgressIndicator(
                      value: animationProgress,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Timer
                Text(
                  'Timer: $currentTimer sec',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
