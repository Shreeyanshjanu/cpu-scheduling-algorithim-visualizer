enum AlgorithmType {
  fcfs,
  sjf,
  priority,
  robin,
}

extension AlgorithmTypeExtension on AlgorithmType {
  String get displayName {
    switch (this) {
      case AlgorithmType.fcfs:
        return 'FCFS';
      case AlgorithmType.sjf:
        return 'SJF';
      case AlgorithmType.priority:
        return 'Priority scheduling';
      case AlgorithmType.robin:
        return 'Round Robin';
    }
  }
}
