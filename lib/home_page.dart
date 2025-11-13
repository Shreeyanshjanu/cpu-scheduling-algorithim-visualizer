import 'package:flutter/material.dart';
import 'package:os_project/educational_info_panel.dart';
import 'package:os_project/models/algorithim_type.dart';
import 'package:os_project/widgets/algorithim_selector.dart';
import 'package:os_project/widgets/bar_chart_widget.dart';
import 'package:os_project/widgets/cpu_scheduling_table.dart';
import 'package:os_project/widgets/gantt_chart_widget.dart';
import 'package:os_project/widgets/line_chart_widget.dart';
import 'package:os_project/widgets/algorithm_comparison_dashboard.dart';
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

  // Comparison Dashboard Variables
  bool showComparison = false;
  Map<String, AlgorithmResult> comparisonResults = {};

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

              // Buttons Row - MODIFIED
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Go Button
                    ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
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
                    
                    // Compare All Algorithms Button
                    ElevatedButton.icon(
                      onPressed: _compareAllAlgorithms,
                      icon: const Icon(Icons.compare_arrows, size: 24),
                      label: const Text(
                        'Compare All',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    
                    // NEW: Educational Info Button
                    ElevatedButton.icon(
                      onPressed: () => _showEducationalPanel(context),
                      icon: const Icon(Icons.school, size: 24),
                      label: const Text(
                        'Learn About Algorithms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Show Comparison Dashboard
              if (showComparison)
                AlgorithmComparisonDashboard(
                  results: comparisonResults,
                ),

              if (showComparison) const SizedBox(height: 24),

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
                          child: SingleChildScrollView(
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

  // NEW: Show Educational Panel Method
  void _showEducationalPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Algorithm Guide',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Panel content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: EducationalInfoPanel(
                    selectedAlgorithm: selectedAlgorithm.displayName,
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

  // Compare All Algorithms Method
  void _compareAllAlgorithms() {
    setState(() {
      comparisonResults.clear();

      // Run all 4 algorithms
      List<AlgorithmType> algorithms = [
        AlgorithmType.fcfs,
        AlgorithmType.sjf,
        AlgorithmType.priority,
        AlgorithmType.robin,
      ];

      Map<String, double> waitingTimes = {};

      for (var algorithm in algorithms) {
        List<ResultBlock> blocks = SchedulingCalculator.calculate(
          processes,
          algorithm,
          quantum,
        );

        // Calculate average times
        double avgWait = _calculateAvgWaitingTime(processes, blocks);
        double avgTurnaround = _calculateAvgTurnaroundTime(processes, blocks);
        double avgResponse = _calculateAvgResponseTime(processes, blocks);

        waitingTimes[algorithm.displayName] = avgWait;

        comparisonResults[algorithm.displayName] = AlgorithmResult(
          name: algorithm.displayName,
          avgWaitingTime: avgWait,
          avgTurnaroundTime: avgTurnaround,
          avgResponseTime: avgResponse,
          rank: 0, // Will be set below
        );
      }

      // Assign ranks based on waiting time (lower is better)
      List<MapEntry<String, double>> sorted = waitingTimes.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      for (int i = 0; i < sorted.length; i++) {
        String algoName = sorted[i].key;
        comparisonResults[algoName] = AlgorithmResult(
          name: algoName,
          avgWaitingTime: comparisonResults[algoName]!.avgWaitingTime,
          avgTurnaroundTime: comparisonResults[algoName]!.avgTurnaroundTime,
          avgResponseTime: comparisonResults[algoName]!.avgResponseTime,
          rank: i + 1,
        );
      }

      showComparison = true;
    });
  }

  // Helper method to calculate avg waiting time
  double _calculateAvgWaitingTime(
      List<Process> procs, List<ResultBlock> blocks) {
    Map<int, int> startTimes = {};
    Map<int, int> completionTimes = {};
    int currentTime = 0;

    for (var block in blocks) {
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

    double totalWaiting = 0;
    for (var process in procs) {
      // ignore: unused_local_variable
      int startTime = startTimes[process.id] ?? 0;
      int completionTime = completionTimes[process.id] ?? 0;
      int turnaroundTime = completionTime - process.arrivalTime;
      int waitingTime = turnaroundTime - process.executeTime;
      totalWaiting += waitingTime;
    }

    return totalWaiting / procs.length;
  }

  // Helper method to calculate avg turnaround time
  double _calculateAvgTurnaroundTime(
      List<Process> procs, List<ResultBlock> blocks) {
    Map<int, int> completionTimes = {};
    int currentTime = 0;

    for (var block in blocks) {
      if (block.processId == -1) {
        currentTime += block.duration;
        continue;
      }
      currentTime += block.duration;
      completionTimes[block.processId] = currentTime;
    }

    double totalTurnaround = 0;
    for (var process in procs) {
      int completionTime = completionTimes[process.id] ?? 0;
      int turnaroundTime = completionTime - process.arrivalTime;
      totalTurnaround += turnaroundTime;
    }

    return totalTurnaround / procs.length;
  }

  // Helper method to calculate avg response time
  double _calculateAvgResponseTime(
      List<Process> procs, List<ResultBlock> blocks) {
    Map<int, int> startTimes = {};
    int currentTime = 0;

    for (var block in blocks) {
      if (block.processId == -1) {
        currentTime += block.duration;
        continue;
      }
      if (!startTimes.containsKey(block.processId)) {
        startTimes[block.processId] = currentTime;
      }
      currentTime += block.duration;
    }

    double totalResponse = 0;
    for (var process in procs) {
      int startTime = startTimes[process.id] ?? 0;
      int responseTime = startTime - process.arrivalTime;
      totalResponse += responseTime;
    }

    return totalResponse / procs.length;
  }
}
