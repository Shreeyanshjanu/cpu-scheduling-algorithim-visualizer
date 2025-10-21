import 'package:flutter/material.dart';
import 'package:os_project/models/algorithim_type.dart';
import 'package:os_project/widgets/algorithim_selector.dart';
import 'package:os_project/widgets/bar_chart_widget.dart';
import 'package:os_project/widgets/cpu_scheduling_table.dart';
import 'package:os_project/widgets/gantt_chart_widget.dart';
import 'package:os_project/widgets/line_chart_widget.dart';
import 'models/process_model.dart';
import 'widgets/process_table.dart';
import 'widgets/quantum_input.dart';
import 'widgets/result_display.dart';
import 'utils/scheduling_calculator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AlgorithmType selectedAlgorithm = AlgorithmType.fcfs;
  List<Process> processes = [
    Process(id: 0, arrivalTime: 0, executeTime: 5, priority: 0),
    Process(id: 1, arrivalTime: 1, executeTime: 3, priority: 0),
  ];
  int quantum = 3;
  List<ResultBlock> resultBlocks = [];
  bool showResult = false;
  double animationProgress = 0.0;
  int currentTimer = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPU Scheduling Algorithms'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Algorithm Selector
            const Text(
              'Algorithm:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AlgorithmSelector(
              selectedAlgorithm: selectedAlgorithm,
              onAlgorithmChanged: (AlgorithmType? value) {
                setState(() {
                  selectedAlgorithm = value!;
                  _calculateServiceTime();
                });
              },
            ),
            const SizedBox(height: 24),

            // Process Table
            ProcessTable(
              processes: processes,
              selectedAlgorithm: selectedAlgorithm,
              onProcessChanged: () {
                setState(() {
                  _calculateServiceTime();
                });
              },
              onAddProcess: _addProcess,
              onDeleteProcess: _deleteProcess,
            ),
            const SizedBox(height: 24),

            // Quantum Input (for Round Robin)
            if (selectedAlgorithm == AlgorithmType.robin)
              QuantumInput(
                quantum: quantum,
                onQuantumChanged: (value) {
                  setState(() {
                    quantum = value;
                  });
                },
              ),
            const SizedBox(height: 16),

            // Go Button
            Center(
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('Go', style: TextStyle(fontSize: 18)),
              ),
            ),
            // Result Display
            // Result Display
            // Result Display
if (showResult && selectedAlgorithm == AlgorithmType.fcfs)
  Column(
    children: [
      // CPU Scheduling Table
      CpuSchedulingTable(
        processes: processes,
        resultBlocks: resultBlocks,
      ),
      const SizedBox(height: 24),
      
      // Original Result Display
      ResultDisplay(
        resultBlocks: resultBlocks,
        animationProgress: animationProgress,
        currentTimer: currentTimer,
      ),
      const SizedBox(height: 24),
      
      // Gantt Chart
      GanttChartWidget(resultBlocks: resultBlocks),
      const SizedBox(height: 24),
      
      // Bar Chart
      BarChartWidget(
        processes: processes,
        resultBlocks: resultBlocks,
      ),
      const SizedBox(height: 24),
      
      // Line Chart (NEW)
      LineChartWidget(
        processes: processes,
        resultBlocks: resultBlocks,
      ),
    ],
  )
else if (showResult)
  Column(
    children: [
      CpuSchedulingTable(
        processes: processes,
        resultBlocks: resultBlocks,
      ),
      const SizedBox(height: 24),
      ResultDisplay(
        resultBlocks: resultBlocks,
        animationProgress: animationProgress,
        currentTimer: currentTimer,
      ),
    ],
  ),

          ],
        ),
      ),
    );
  }

  void _addProcess() {
    setState(() {
      int newId = processes.length;
      processes.add(
        Process(
          id: newId,
          arrivalTime: 0, // User can now edit this
          executeTime: 0,
          priority: 0,
        ),
      );
      _calculateServiceTime();
    });
  }

  void _deleteProcess() {
    if (processes.length > 1) {
      setState(() {
        processes.removeLast();
        _calculateServiceTime();
      });
    }
  }

  void _calculateServiceTime() {
    for (var process in processes) {
      process.serviceTime = SchedulingCalculator.calculateServiceTime(
        processes,
        process,
        selectedAlgorithm,
      );
    }
  }

  void _calculate() {
    setState(() {
      resultBlocks = SchedulingCalculator.calculate(
        processes,
        selectedAlgorithm,
        quantum,
      );
      showResult = true;
      animationProgress = 0.0;
      currentTimer = 0;
    });

    // Start animation
    _startAnimation();
  }

  void _startAnimation() {
    int totalTime = resultBlocks.fold(0, (sum, block) => sum + block.duration);

    Future.delayed(Duration.zero, () {
      _animateTimer(totalTime, 0);
    });
  }

  void _animateTimer(int total, int current) {
    if (current <= total && mounted) {
      setState(() {
        currentTimer = current;
        animationProgress = current / total;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        _animateTimer(total, current + 1);
      });
    }
  }
}
