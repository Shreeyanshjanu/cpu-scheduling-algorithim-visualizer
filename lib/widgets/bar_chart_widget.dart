import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/process_model.dart';

class BarChartWidget extends StatelessWidget {
  final List<Process> processes;
  final List<ResultBlock> resultBlocks;

  const BarChartWidget({
    super.key,
    required this.processes,
    required this.resultBlocks,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate times
    Map<int, ProcessTimes> processTimes = _calculateProcessTimes();

    // Get execution order from result blocks
    List<int> executionOrder = _getExecutionOrder();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCFS Scheduling - Time Metrics Comparison',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: BarChart(_buildBarChartData(processTimes, executionOrder)),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _getExecutionOrder() {
    List<int> order = [];
    Set<int> addedProcesses = {};

    for (var block in resultBlocks) {
      // Skip idle blocks and duplicates
      if (block.processId != -1 && !addedProcesses.contains(block.processId)) {
        order.add(block.processId);
        addedProcesses.add(block.processId);
      }
    }

    return order;
  }

  Map<int, ProcessTimes> _calculateProcessTimes() {
    Map<int, ProcessTimes> times = {};
    Map<int, int> startTimes = {};
    Map<int, int> completionTimes = {};
    int currentTime = 0;

    // Calculate start and completion times
    for (var block in resultBlocks) {
      // Skip idle time
      if (block.processId == -1) {
        currentTime += block.duration;
        continue;
      }

      if (!startTimes.containsKey(block.processId)) {
        startTimes[block.processId] = currentTime;
      }

      currentTime += block.duration;
      completionTimes[block.processId] = currentTime;
    }

    // Calculate all timing parameters
    for (var process in processes) {
      int startTime = startTimes[process.id] ?? 0;
      int completionTime = completionTimes[process.id] ?? 0;

      // Response Time = Start Time - Arrival Time
      int responseTime = startTime - process.arrivalTime;

      // Turnaround Time = Completion Time - Arrival Time
      int turnaroundTime = completionTime - process.arrivalTime;

      // Waiting Time = Turnaround Time - Burst Time
      int waitingTime = turnaroundTime - process.executeTime;

      times[process.id] = ProcessTimes(
        processId: process.id,
        responseTime: responseTime,
        completionTime: completionTime,
        turnaroundTime: turnaroundTime,
        waitingTime: waitingTime,
      );
    }

    return times;
  }

  BarChartData _buildBarChartData(
    Map<int, ProcessTimes> processTimes,
    List<int> executionOrder,
  ) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _getMaxY(processTimes) + 2,
      minY: 0,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String metric = '';
            switch (rodIndex) {
              case 0:
                metric = 'Completion';
                break;
              case 1:
                metric = 'Turnaround';
                break;
              case 2:
                metric = 'Waiting';
                break;
              case 3:
                metric = 'Response';
                break;
            }
            return BarTooltipItem(
              '$metric\n${rod.toY.toInt()}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < executionOrder.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'P${executionOrder[index]}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 2,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
      ),
      barGroups: executionOrder.asMap().entries.map((entry) {
        int index = entry.key;
        int processId = entry.value;
        var times = processTimes[processId]!;

        return BarChartGroupData(
          x: index,
          barRods: [
            // Completion Time - Cyan
            BarChartRodData(
              toY: times.completionTime.toDouble(),
              color: Colors.cyan,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Turnaround Time - Red
            BarChartRodData(
              toY: times.turnaroundTime.toDouble(),
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Waiting Time - Teal/Green
            BarChartRodData(
              toY: times.waitingTime.toDouble(),
              color: Colors.teal,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Response Time - Dark Gray
            BarChartRodData(
              toY: times.responseTime.toDouble(),
              color: Colors.grey.shade700,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          barsSpace: 4,
        );
      }).toList(),
    );
  }

  double _getMaxY(Map<int, ProcessTimes> processTimes) {
    if (processTimes.isEmpty) return 10;

    double max = 0;
    for (var times in processTimes.values) {
      if (times.responseTime > max) max = times.responseTime.toDouble();
      if (times.completionTime > max) max = times.completionTime.toDouble();
      if (times.waitingTime > max) max = times.waitingTime.toDouble();
      if (times.turnaroundTime > max) max = times.turnaroundTime.toDouble();
    }
    return max > 0 ? max : 10;
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Completion', Colors.cyan),
        _buildLegendItem('Turnaround', Colors.red),
        _buildLegendItem('Waiting', Colors.teal),
        _buildLegendItem('Response', Colors.grey.shade700),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class ProcessTimes {
  final int processId;
  int responseTime;
  int completionTime;
  int turnaroundTime;
  int waitingTime;

  ProcessTimes({
    required this.processId,
    required this.responseTime,
    required this.completionTime,
    required this.turnaroundTime,
    required this.waitingTime,
  });
}
