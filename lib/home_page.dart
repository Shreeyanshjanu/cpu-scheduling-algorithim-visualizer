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
        title: const Text(
          'CPU Scheduling Algorithms',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE91E63), // Pink
                Color(0xFF9C27B0), // Purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        // GRADIENT BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE91E63), // Pink
              Color(0xFFC2185B), // Dark Pink
              Color(0xFF9C27B0), // Purple
              Color(0xFF7B1FA2), // Dark Purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Algorithm Selector
              const Text(
                'Algorithm:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 64,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Go',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Result Display - HORIZONTAL SCROLL
              if (showResult)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: CPU Scheduling Table
                        SizedBox(
                          width: 800,
                          child: CpuSchedulingTable(
                            processes: processes,
                            resultBlocks: resultBlocks,
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Section 2: Result Display & Gantt Chart
                        SizedBox(
                          width: 700,
                          child: Column(
                            children: [
                              ResultDisplay(
                                resultBlocks: resultBlocks,
                                animationProgress: animationProgress,
                                currentTimer: currentTimer,
                              ),
                              const SizedBox(height: 24),
                              GanttChartWidget(resultBlocks: resultBlocks),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Section 3: Bar Chart
                        SizedBox(
                          width: 700,
                          child: BarChartWidget(
                            processes: processes,
                            resultBlocks: resultBlocks,
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Section 4: Line Chart
                        SizedBox(
                          width: 700,
                          child: LineChartWidget(
                            processes: processes,
                            resultBlocks: resultBlocks,
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
          arrivalTime: 0,
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
