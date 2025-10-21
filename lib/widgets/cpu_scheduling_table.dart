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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                'CPU SCHEDULING TABLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(color: Colors.black),
                headingRowColor:
                    WidgetStateProperty.all(Colors.grey.shade300),
                columnSpacing: 10,
                horizontalMargin: 10,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 50,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Process ID',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ArrivalTime',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Burst Time',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Priority',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Response Time',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'TAT',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'CT',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Waiting Time',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Indicator',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
                rows: processes.map((process) {
                  var times = calculatedTimes[process.id]!;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return _getProcessColor(process.id);
                      },
                    ),
                    cells: [
                      DataCell(Text('P${process.id}')),
                      DataCell(Text('${process.arrivalTime}')),
                      DataCell(Text('${process.executeTime}')),
                      DataCell(Text(process.priority > 0
                          ? '${process.priority}'
                          : '')),
                      DataCell(Text('${times.responseTime}')),
                      DataCell(Text('${times.turnaroundTime}')),
                      DataCell(Text('${times.completionTime}')),
                      DataCell(Text('${times.waitingTime}')),
                      DataCell(
                        Container(
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getProcessColor(process.id),
                            border: Border.all(color: Colors.black45),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
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

  Color _getProcessColor(int processId) {
    final colors = [
      Colors.pink.shade200,
      Colors.green.shade300,
      Colors.lightBlue.shade200,
      Colors.purple.shade200,
      Colors.red.shade200,
      Colors.orange.shade200,
      Colors.teal.shade200,
      Colors.grey.shade400,
    ];
    return colors[processId % colors.length];
  }

  Widget _buildAverageBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Text(
            '$label = ',
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
