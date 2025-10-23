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
              'FCFS Scheduling - Time Metrics Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
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
          // FIXED: Changed from tooltipBgColor to getTooltipColor
          getTooltipColor: (group) => const Color(0xFF1E1E1E),
          tooltipBorder: const BorderSide(
            color: Color(0xFF404040),
            width: 1,
          ),
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
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
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
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
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Color(0xFF404040), width: 1),
          bottom: BorderSide(color: Color(0xFF404040), width: 1),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xFF404040),
            strokeWidth: 1,
          );
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
              color: const Color(0xFF00BCD4),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Turnaround Time - Red
            BarChartRodData(
              toY: times.turnaroundTime.toDouble(),
              color: const Color(0xFFFF5252),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Waiting Time - Green
            BarChartRodData(
              toY: times.waitingTime.toDouble(),
              color: const Color(0xFF4CAF50),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Response Time - Purple
            BarChartRodData(
              toY: times.responseTime.toDouble(),
              color: const Color(0xFF9C27B0),
              width: 14,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 12,
        children: [
          _buildLegendItem('Completion', const Color(0xFF00BCD4)),
          _buildLegendItem('Turnaround', const Color(0xFFFF5252)),
          _buildLegendItem('Waiting', const Color(0xFF4CAF50)),
          _buildLegendItem('Response', const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
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
