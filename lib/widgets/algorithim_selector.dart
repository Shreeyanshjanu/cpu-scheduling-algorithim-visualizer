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
      color: const Color(0xFF2D2D2D),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: AlgorithmType.values.map((algorithm) {
            bool isSelected = algorithm == selectedAlgorithm;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF1E1E1E)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF404040),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: RadioListTile<AlgorithmType>(
                title: Text(
                  algorithm.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                value: algorithm,
                groupValue: selectedAlgorithm,
                onChanged: onAlgorithmChanged,
                dense: true,
                activeColor: const Color(0xFF2196F3),
                selectedTileColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
