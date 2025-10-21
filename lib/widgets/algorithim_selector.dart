import 'package:flutter/material.dart';
import 'package:os_project/models/algorithim_type.dart';

class AlgorithmSelector extends StatelessWidget {
  final AlgorithmType selectedAlgorithm;
  final ValueChanged<AlgorithmType?> onAlgorithmChanged;

  const AlgorithmSelector({
    super.key,
    required this.selectedAlgorithm,
    required this.onAlgorithmChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: AlgorithmType.values.map((algorithm) {
            return RadioListTile<AlgorithmType>(
              title: Text(algorithm.displayName),
              value: algorithm,
              groupValue: selectedAlgorithm,
              onChanged: onAlgorithmChanged,
              dense: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}
