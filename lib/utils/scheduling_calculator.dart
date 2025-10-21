import 'package:os_project/models/algorithim_type.dart';

import '../models/process_model.dart';

class SchedulingCalculator {
  static int calculateServiceTime(
    List<Process> processes,
    Process targetProcess,
    AlgorithmType algorithm,
  ) {
    if (algorithm == AlgorithmType.robin) {
      return 0;
    }

    // For FCFS, calculate when this process starts
    List<Process> sortedProcesses = List.from(processes);
    sortedProcesses.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    int currentTime = 0;

    for (var process in sortedProcesses) {
      // CPU idle: wait for process to arrive
      if (currentTime < process.arrivalTime) {
        currentTime = process.arrivalTime;
      }

      // If this is our target process, return when it starts
      if (process.id == targetProcess.id) {
        return currentTime;
      }

      // Process executes
      currentTime += process.executeTime;
    }

    return 0;
  }

  static List<ResultBlock> calculate(
    List<Process> processes,
    AlgorithmType algorithm,
    int quantum,
  ) {
    List<ResultBlock> blocks = [];

    switch (algorithm) {
      case AlgorithmType.fcfs:
        // Sort by arrival time for FCFS
        List<Process> sortedProcesses = List.from(processes);
        sortedProcesses.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

        int currentTime = 0;

        for (var process in sortedProcesses) {
          // Add idle time ONLY if CPU is actually idle (currentTime < arrivalTime)
          if (currentTime < process.arrivalTime) {
            int idleTime = process.arrivalTime - currentTime;
            blocks.add(ResultBlock(
              processId: -1, // -1 indicates idle time
              duration: idleTime,
            ));
            currentTime = process.arrivalTime;
          }

          // Add process execution
          blocks.add(ResultBlock(
            processId: process.id,
            duration: process.executeTime,
          ));
          currentTime += process.executeTime;
        }
        break;

      case AlgorithmType.sjf:
        List<Process> sortedProcesses = List.from(processes);
        sortedProcesses.sort((a, b) {
          if (a.executeTime == b.executeTime) {
            return a.arrivalTime.compareTo(b.arrivalTime);
          }
          return a.executeTime.compareTo(b.executeTime);
        });

        int currentTime = 0;
        for (var process in sortedProcesses) {
          if (currentTime < process.arrivalTime) {
            currentTime = process.arrivalTime;
          }

          blocks.add(ResultBlock(
            processId: process.id,
            duration: process.executeTime,
          ));
          currentTime += process.executeTime;
        }
        break;

      case AlgorithmType.priority:
        List<Process> sortedProcesses = List.from(processes);
        sortedProcesses.sort((a, b) {
          if (a.priority == b.priority) {
            return a.arrivalTime.compareTo(b.arrivalTime);
          }
          return b.priority.compareTo(a.priority);
        });

        int currentTime = 0;
        for (var process in sortedProcesses) {
          if (currentTime < process.arrivalTime) {
            currentTime = process.arrivalTime;
          }

          blocks.add(ResultBlock(
            processId: process.id,
            duration: process.executeTime,
          ));
          currentTime += process.executeTime;
        }
        break;

      case AlgorithmType.robin:
        List<Process> sortedByArrival = List.from(processes);
        sortedByArrival.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

        List<int> remainingTimes =
            sortedByArrival.map((p) => p.executeTime).toList();
        bool allDone = false;

        while (!allDone) {
          allDone = true;
          for (int i = 0; i < sortedByArrival.length; i++) {
            if (remainingTimes[i] > 0) {
              int executionTime = remainingTimes[i] > quantum
                  ? quantum
                  : remainingTimes[i];

              blocks.add(ResultBlock(
                processId: sortedByArrival[i].id,
                duration: executionTime,
              ));

              remainingTimes[i] -= executionTime;
              allDone = false;
            }
          }
        }
        break;
    }

    return blocks;
  }
}
