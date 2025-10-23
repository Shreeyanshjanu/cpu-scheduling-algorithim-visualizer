import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/process_model.dart';

class LineChartWidget extends StatelessWidget {
  final List<Process> processes;
  final List<ResultBlock> resultBlocks;

  const LineChartWidget({
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
              'Process Timing Metrics Trend',
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
              child: LineChart(
                _buildLineChartData(processTimes, executionOrder),
              ),
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
        burstTime: process.executeTime,
        completionTime: completionTime,
        turnaroundTime: turnaroundTime,
        waitingTime: waitingTime,
      );
    }

    return times;
  }

  LineChartData _buildLineChartData(
    Map<int, ProcessTimes> processTimes,
    List<int> executionOrder,
  ) {
    // Calculate max Y value
    double maxY = _getMaxY(processTimes);
    double chartMaxY = maxY > 0 ? maxY + 2 : 10;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: chartMaxY > 10 ? 2 : 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xFF404040),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xFF404040),
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
            interval: chartMaxY > 10 ? 2 : 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
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
      minX: 0,
      maxX: executionOrder.length > 1
          ? (executionOrder.length - 1).toDouble()
          : 1,
      minY: 0,
      maxY: chartMaxY,
      lineBarsData: [
        // Completion Time - CYAN
        _buildLineData(
          processTimes,
          executionOrder,
          (times) => times.completionTime.toDouble(),
          const Color(0xFF00BCD4),
          'Completion',
          barWidth: 3,
        ),

        // Turnaround Time - RED/PINK
        _buildLineData(
          processTimes,
          executionOrder,
          (times) => times.turnaroundTime.toDouble(),
          const Color(0xFFFF5252),
          'Turnaround',
          barWidth: 3,
        ),
      ],
    );
  }

  LineChartBarData _buildLineData(
    Map<int, ProcessTimes> processTimes,
    List<int> executionOrder,
    double Function(ProcessTimes) getValue,
    Color color,
    String label, {
    double barWidth = 3,
  }) {
    List<FlSpot> spots = [];

    for (int i = 0; i < executionOrder.length; i++) {
      var times = processTimes[executionOrder[i]]!;
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
      barWidth: barWidth,
      isStrokeCapRound: true,
      preventCurveOverShooting: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5,
            color: color,
            strokeWidth: 2,
            strokeColor: const Color(0xFF1E1E1E),
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
      if (times.completionTime > max) max = times.completionTime.toDouble();
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
        runSpacing: 8,
        children: [
          _buildLegendItem('Completion', const Color(0xFF00BCD4)),
          _buildLegendItem('Turnaround', const Color(0xFFFF5252)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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
