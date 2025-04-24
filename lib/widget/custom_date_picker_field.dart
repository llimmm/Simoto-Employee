import 'package:flutter/material.dart';

class CustomDatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const CustomDatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TANGGAL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Pilih tanggal'
                      : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
                  style: const TextStyle(color: Colors.black87),
                ),
                const Icon(Icons.calendar_today, color: Colors.black45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
