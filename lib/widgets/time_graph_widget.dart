import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/process_model.dart';

class TimeGraphWidget extends StatelessWidget {
  final List<Process> processes;
  final List<ResultBlock> resultBlocks;

  const TimeGraphWidget({
    super.key,
    required this.processes,
    required this.resultBlocks,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate times
    Map<int, ProcessTimes> processTimes = _calculateProcessTimes();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Graph',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: LineChart(
                _buildLineChartData(processTimes),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
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
      int startTime = startTimes[process.id] ?? process.arrivalTime;
      int completionTime = completionTimes[process.id] ?? process.arrivalTime;
      int responseTime = startTime - process.arrivalTime;
      int turnaroundTime = completionTime - process.arrivalTime;
      int waitingTime = turnaroundTime - process.executeTime;

      times[process.id] = ProcessTimes(
        processId: process.id,
        responseTime: responseTime >= 0 ? responseTime : 0,
        burstTime: process.executeTime,
        completionTime: completionTime,
        turnaroundTime: turnaroundTime >= 0 ? turnaroundTime : 0,
        waitingTime: waitingTime >= 0 ? waitingTime : 0,
      );

      // DEBUG PRINT
      print('P${process.id}: RT=${times[process.id]!.responseTime}, '
          'CT=${times[process.id]!.completionTime}, '
          'WT=${times[process.id]!.waitingTime}');
    }

    return times;
  }

  LineChartData _buildLineChartData(Map<int, ProcessTimes> processTimes) {
    // Sort by process ID for consistent X-axis
    List<int> sortedIds = processTimes.keys.toList()..sort();

    // Calculate max Y value
    double maxY = _getMaxY(processTimes);
    double chartMaxY = maxY > 0 ? maxY + 2 : 10;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < sortedIds.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'P${sortedIds[index]}',
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
            interval: 2,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black, width: 1),
      ),
      minX: 0,
      maxX: sortedIds.length > 1 ? (sortedIds.length - 1).toDouble() : 1,
      minY: 0,
      maxY: chartMaxY,
      lineBarsData: [
        // Response Time - BLUE - DRAW FIRST SO IT'S VISIBLE
        _buildLineData(
          processTimes,
          sortedIds,
          (times) => times.responseTime.toDouble(),
          Colors.blue.shade700,
          'Response Time',
        ),
        // Waiting Time - GREEN - DRAW SECOND
        _buildLineData(
          processTimes,
          sortedIds,
          (times) => times.waitingTime.toDouble(),
          Colors.green.shade600,
          'Waiting Time',
        ),
        // Completion Time - RED - DRAW LAST (ON TOP)
        _buildLineData(
          processTimes,
          sortedIds,
          (times) => times.completionTime.toDouble(),
          Colors.red.shade600,
          'Completion Time',
        ),
      ],
    );
  }

  LineChartBarData _buildLineData(
    Map<int, ProcessTimes> processTimes,
    List<int> sortedIds,
    double Function(ProcessTimes) getValue,
    Color color,
    String label,
  ) {
    List<FlSpot> spots = [];

    for (int i = 0; i < sortedIds.length; i++) {
      var times = processTimes[sortedIds[i]]!;
      double yValue = getValue(times);
      spots.add(FlSpot(
        i.toDouble(),
        yValue,
      ));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      preventCurveOverShooting: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 3,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  double _getMaxY(Map<int, ProcessTimes> processTimes) {
    if (processTimes.isEmpty) return 10;

    double max = 0;
    for (var times in processTimes.values) {
      if (times.responseTime > max) max = times.responseTime.toDouble();
      if (times.completionTime > max) max = times.completionTime.toDouble();
      if (times.waitingTime > max) max = times.waitingTime.toDouble();
    }
    return max > 0 ? max : 10;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Response Time', Colors.blue.shade700),
        const SizedBox(width: 16),
        _buildLegendItem('Completion Time', Colors.red.shade600),
        const SizedBox(width: 16),
        _buildLegendItem('Waiting Time', Colors.green.shade600),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
  final int burstTime;

  ProcessTimes({
    required this.processId,
    required this.responseTime,
    required this.burstTime,
    this.completionTime = 0,
    this.turnaroundTime = 0,
    this.waitingTime = 0,
  });
}
