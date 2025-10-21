import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantumInput extends StatelessWidget {
  final int quantum;
  final ValueChanged<int> onQuantumChanged;

  const QuantumInput({
    super.key,
    required this.quantum,
    required this.onQuantumChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quantum:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                controller: TextEditingController(text: quantum.toString()),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    onQuantumChanged(int.tryParse(value) ?? 3);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
