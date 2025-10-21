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
                _buildLineChartData(processTimes, executionOrder),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
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
            interval: chartMaxY > 10 ? 2 : 1,
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
      maxX: executionOrder.length > 1
          ? (executionOrder.length - 1).toDouble()
          : 1,
      minY: 0,
      maxY: chartMaxY,
      lineBarsData: [
        // Response Time - BLUE
        _buildLineData(
          processTimes,
          executionOrder,
          (times) => times.responseTime.toDouble(),
          Colors.blue.shade700,
          'Response Time',
        ),
        // Completion Time - RED
        _buildLineData(
          processTimes,
          executionOrder,
          (times) => times.completionTime.toDouble(),
          Colors.red.shade600,
          'Completion Time',
        ),
        // Waiting Time - GREEN
        _buildLineData(
          processTimes,
          executionOrder,
          (times) => times.waitingTime.toDouble(),
          Colors.green.shade600,
          'Waiting Time',
        ),
      ],
    );
  }

  LineChartBarData _buildLineData(
    Map<int, ProcessTimes> processTimes,
    List<int> executionOrder,
    double Function(ProcessTimes) getValue,
    Color color,
    String label,
  ) {
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
      curveSmoothness: 0.35,
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
