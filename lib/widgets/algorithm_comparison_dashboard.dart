import 'package:flutter/material.dart';

class AlgorithmComparisonDashboard extends StatelessWidget {
  final Map<String, AlgorithmResult> results;

  const AlgorithmComparisonDashboard({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    // Find the best algorithm
    String bestAlgorithm = _findBestAlgorithm();
    
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
            // Title with trophy
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD700),
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Algorithm Comparison Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Winner announcement
            _buildWinnerCard(bestAlgorithm),
            const SizedBox(height: 24),

            // Comparison Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildComparisonTable(bestAlgorithm),
            ),
            const SizedBox(height: 24),

            // Recommendation
            _buildRecommendation(bestAlgorithm),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard(String bestAlgorithm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 Best Algorithm',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bestAlgorithm,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lowest Average Waiting Time: ${results[bestAlgorithm]!.avgWaitingTime.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(String bestAlgorithm) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(
            color: Color(0xFF404040),
            width: 1,
          ),
        ),
        columnWidths: const {
          0: FixedColumnWidth(150),
          1: FixedColumnWidth(140),
          2: FixedColumnWidth(140),
          3: FixedColumnWidth(140),
          4: FixedColumnWidth(120),
        },
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3A),
            ),
            children: [
              _buildHeaderCell('Algorithm'),
              _buildHeaderCell('Avg Waiting\nTime'),
              _buildHeaderCell('Avg Turnaround\nTime'),
              _buildHeaderCell('Avg Response\nTime'),
              _buildHeaderCell('Rank'),
            ],
          ),
          // Data rows
          ...results.entries.map((entry) {
            bool isWinner = entry.key == bestAlgorithm;
            return TableRow(
              decoration: BoxDecoration(
                color: isWinner
                    ? const Color(0xFF2D4A2B)
                    : const Color(0xFF1E1E1E),
              ),
              children: [
                _buildDataCell(
                  entry.key,
                  isWinner: isWinner,
                  icon: isWinner ? '🏆 ' : '',
                ),
                _buildDataCell(
                  entry.value.avgWaitingTime.toStringAsFixed(2),
                  isWinner: isWinner,
                ),
                _buildDataCell(
                  entry.value.avgTurnaroundTime.toStringAsFixed(2),
                  isWinner: isWinner,
                ),
                _buildDataCell(
                  entry.value.avgResponseTime.toStringAsFixed(2),
                  isWinner: isWinner,
                ),
                _buildRankCell(entry.value.rank),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.white70,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, {bool isWinner = false, String icon = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Text(
        icon + text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: isWinner ? const Color(0xFF4CAF50) : Colors.white,
          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRankCell(int rank) {
    Color badgeColor;
    String emoji;
    
    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700);
        emoji = '🥇';
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0);
        emoji = '🥈';
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32);
        emoji = '🥉';
        break;
      default:
        badgeColor = const Color(0xFF404040);
        emoji = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$emoji #$rank',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation(String bestAlgorithm) {
    String recommendation = _getRecommendation(bestAlgorithm);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2196F3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb,
            color: Color(0xFFFFD700),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _findBestAlgorithm() {
    String best = '';
    double lowestWaitTime = double.infinity;

    results.forEach((algorithm, result) {
      if (result.avgWaitingTime < lowestWaitTime) {
        lowestWaitTime = result.avgWaitingTime;
        best = algorithm;
      }
    });

    return best;
  }

  String _getRecommendation(String bestAlgorithm) {
    switch (bestAlgorithm) {
      case 'FCFS':
        return 'FCFS is performing best for your workload. It works well when processes arrive in order with minimal overlap. Consider it for batch processing systems.';
      case 'SJF':
        return 'SJF minimizes waiting time for your workload. It\'s optimal when burst times are known in advance. Great for non-interactive batch systems.';
      case 'Priority':
        return 'Priority Scheduling is most efficient here. Use it when certain processes must be executed before others. Consider aging to prevent starvation.';
      case 'Round Robin':
        return 'Round Robin provides the best fairness for your workload. Ideal for time-sharing systems. Adjust quantum for better performance.';
      default:
        return 'Compare algorithms to find the best fit for your specific workload characteristics.';
    }
  }
}

// Algorithm Result Model
class AlgorithmResult {
  final String name;
  final double avgWaitingTime;
  final double avgTurnaroundTime;
  final double avgResponseTime;
  final int rank;

  AlgorithmResult({
    required this.name,
    required this.avgWaitingTime,
    required this.avgTurnaroundTime,
    required this.avgResponseTime,
    required this.rank,
  });
}
