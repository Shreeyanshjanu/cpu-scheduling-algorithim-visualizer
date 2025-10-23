import 'package:flutter/material.dart';
import '../models/process_model.dart';

class CpuSchedulingTable extends StatelessWidget {
  final List<Process> processes;
  final List<ResultBlock> resultBlocks;

  const CpuSchedulingTable({
    super.key,
    required this.processes,
    required this.resultBlocks,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate all timing values
    Map<int, CalculatedTimes> calculatedTimes = _calculateAllTimes();

    // Calculate averages
    double avgCompletionTime = calculatedTimes.values
            .map((e) => e.completionTime)
            .reduce((a, b) => a + b)
            .toDouble() /
        calculatedTimes.length;

    double avgTurnaroundTime = calculatedTimes.values
            .map((e) => e.turnaroundTime)
            .reduce((a, b) => a + b)
            .toDouble() /
        calculatedTimes.length;

    return Card(
      color: const Color(0xFF2D2D2D), // Dark background
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark themed table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header Row
                  _buildHeaderRow(),
                  const Divider(
                    height: 1,
                    color: Color(0xFF404040),
                  ),
                  // Data Rows
                  ...processes.asMap().entries.map((entry) {
                    int index = entry.key;
                    Process process = entry.value;
                    var times = calculatedTimes[process.id]!;
                    
                    return Column(
                      children: [
                        _buildDataRow(
                          index + 1,
                          process,
                          times,
                          index % 2 == 0,
                        ),
                        if (index < processes.length - 1)
                          const Divider(
                            height: 1,
                            color: Color(0xFF404040),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Average times display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAverageBox(
                  'Avg. Completion Time',
                  avgCompletionTime.toStringAsFixed(2),
                ),
                const SizedBox(width: 20),
                _buildAverageBox(
                  'Avg. Turn Around Time',
                  avgTurnaroundTime.toStringAsFixed(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('#', flex: 1),
          _buildHeaderCell('Process ID', flex: 2),
          _buildHeaderCell('Arrival Time', flex: 2),
          _buildHeaderCell('Burst Time', flex: 2),
          _buildHeaderCell('Priority', flex: 2),
          _buildHeaderCell('Response Time', flex: 2),
          _buildHeaderCell('TAT', flex: 2),
          _buildHeaderCell('CT', flex: 2),
          _buildHeaderCell('Waiting Time', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataRow(
    int index,
    Process process,
    CalculatedTimes times,
    bool isEven,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isEven 
            ? const Color(0xFF2A2A2A) 
            : const Color(0xFF1E1E1E),
      ),
      child: Row(
        children: [
          _buildDataCell('$index', flex: 1),
          _buildDataCell('P${process.id}', flex: 2),
          _buildDataCell('${process.arrivalTime}', flex: 2),
          _buildDataCell('${process.executeTime}', flex: 2),
          _buildDataCell(
            process.priority > 0 ? '${process.priority}' : '-',
            flex: 2,
          ),
          _buildDataCell('${times.responseTime}', flex: 2),
          _buildDataCell('${times.turnaroundTime}', flex: 2),
          _buildDataCell('${times.completionTime}', flex: 2),
          _buildDataCell('${times.waitingTime}', flex: 2),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Map<int, CalculatedTimes> _calculateAllTimes() {
    Map<int, CalculatedTimes> times = {};
    Map<int, int> startTimes = {};
    Map<int, int> completionTimes = {};
    int currentTime = 0;

    // Calculate start and completion times from result blocks
    for (var block in resultBlocks) {
      // Skip idle time blocks
      if (block.processId == -1) {
        currentTime += block.duration;
        continue;
      }

      // Record FIRST start time (for response time)
      if (!startTimes.containsKey(block.processId)) {
        startTimes[block.processId] = currentTime;
      }

      currentTime += block.duration;
      completionTimes[block.processId] = currentTime;
    }

    // Calculate all timing parameters for each process
    for (var process in processes) {
      int startTime = startTimes[process.id] ?? 0;
      int completionTime = completionTimes[process.id] ?? 0;

      // FCFS Formulas:
      // Response Time = Start Time - Arrival Time
      int responseTime = startTime - process.arrivalTime;

      // Completion Time = absolute time when process finishes
      int ct = completionTime;

      // Turnaround Time = Completion Time - Arrival Time
      int turnaroundTime = ct - process.arrivalTime;

      // Waiting Time = Turnaround Time - Burst Time
      int waitingTime = turnaroundTime - process.executeTime;

      times[process.id] = CalculatedTimes(
        responseTime: responseTime,
        completionTime: ct,
        turnaroundTime: turnaroundTime,
        waitingTime: waitingTime,
      );
    }

    return times;
  }

  Widget _buildAverageBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
      ),
      child: Row(
        children: [
          Text(
            '$label = ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFF2A2A2A),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatedTimes {
  final int responseTime;
  final int completionTime;
  final int turnaroundTime;
  final int waitingTime;

  CalculatedTimes({
    required this.responseTime,
    required this.completionTime,
    required this.turnaroundTime,
    required this.waitingTime,
  });
}
