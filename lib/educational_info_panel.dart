import 'package:flutter/material.dart';

class EducationalInfoPanel extends StatelessWidget {
  final String selectedAlgorithm;

  const EducationalInfoPanel({
    Key? key,
    required this.selectedAlgorithm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Title with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Color(0xFF2196F3),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Algorithm Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAlgorithmInfo(),
            const SizedBox(height: 24),
            _buildMetricsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmInfo() {
    Map<String, Map<String, dynamic>> algorithmData = {
      'FCFS': {
        'name': 'First Come First Serve (FCFS)',
        'description':
            'Processes are executed in the order they arrive. Simple but can suffer from convoy effect.',
        'pros': [
          'Simple to implement',
          'Fair in terms of arrival order',
          'No starvation'
        ],
        'cons': [
          'Poor average waiting time',
          'Convoy effect',
          'Not suitable for time-sharing'
        ],
        'useCase': 'Batch processing systems, Print queue management',
        'complexity': 'O(n)',
        'color': const Color(0xFFE91E63),
      },
      'SJF': {
        'name': 'Shortest Job First (SJF)',
        'description':
            'Process with shortest burst time is executed first. Minimizes average waiting time.',
        'pros': [
          'Minimum average waiting time',
          'Optimal for batch systems',
          'Better throughput'
        ],
        'cons': [
          'Can cause starvation',
          'Difficult to predict burst time',
          'Not ideal for interactive systems'
        ],
        'useCase': 'Batch systems where execution times are known',
        'complexity': 'O(n log n)',
        'color': const Color(0xFF4CAF50),
      },
      'Priority': {
        'name': 'Priority Scheduling',
        'description':
            'Each process has a priority. Higher priority processes execute first.',
        'pros': [
          'Important tasks get CPU first',
          'Flexible priority assignment',
          'Good for real-time systems'
        ],
        'cons': [
          'Can cause starvation',
          'Priority inversion problem',
          'Complex to implement'
        ],
        'useCase':
            'Operating systems, Real-time systems, Critical task management',
        'complexity': 'O(n log n)',
        'color': const Color(0xFF9C27B0),
      },
      'Round Robin': {
        'name': 'Round Robin (RR)',
        'description':
            'Each process gets a fixed time quantum. Processes are executed in circular order.',
        'pros': [
          'Fair CPU allocation',
          'Good response time',
          'No starvation',
          'Best for time-sharing'
        ],
        'cons': [
          'Higher context switching overhead',
          'Performance depends on quantum',
          'Higher average turnaround time'
        ],
        'useCase':
            'Time-sharing systems, Interactive applications, Multi-user systems',
        'complexity': 'O(n)',
        'color': const Color(0xFFFF9800),
      },
    };

    var data = algorithmData[selectedAlgorithm] ?? algorithmData['FCFS']!;
    Color accentColor = data['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Algorithm Name with colored accent
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['description']!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pros and Cons Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSection(
                'Advantages',
                data['pros']! as List<String>,
                const Color(0xFF4CAF50),
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSection(
                'Disadvantages',
                data['cons']! as List<String>,
                const Color(0xFFFF5252),
                Icons.cancel_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Use Case
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.work_outline, color: accentColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best Use Case',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['useCase']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Complexity Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed, color: accentColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'Time Complexity: ',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                data['complexity']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      String title, List<String> items, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMetricsInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Understanding Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetric(
            'Completion Time (CT)',
            'Time at which process finishes execution',
            'CT = Start Time + Burst Time',
            Icons.check_circle_outline,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildMetric(
            'Turnaround Time (TAT)',
            'Total time from arrival to completion',
            'TAT = CT - Arrival Time',
            Icons.schedule,
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildMetric(
            'Waiting Time (WT)',
            'Time process waits in ready queue',
            'WT = TAT - Burst Time',
            Icons.access_time,
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildMetric(
            'Response Time (RT)',
            'Time from arrival to first CPU allocation',
            'RT = First CPU Time - Arrival Time',
            Icons.timer,
            const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String name, String description, String formula,
      IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF404040),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
