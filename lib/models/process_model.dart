class Process {
  final int id;
  int arrivalTime;
  int executeTime;
  int priority;
  int serviceTime;

  Process({
    required this.id,
    required this.arrivalTime,
    required this.executeTime,
    required this.priority,
    this.serviceTime = 0,
  });

  Process copyWith({
    int? id,
    int? arrivalTime,
    int? executeTime,
    int? priority,
    int? serviceTime,
  }) {
    return Process(
      id: id ?? this.id,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      executeTime: executeTime ?? this.executeTime,
      priority: priority ?? this.priority,
      serviceTime: serviceTime ?? this.serviceTime,
    );
  }
}

class ResultBlock {
  final int processId;
  final int duration;

  ResultBlock({
    required this.processId,
    required this.duration,
  });
}
