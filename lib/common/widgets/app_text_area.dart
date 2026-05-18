import 'package:flutter/material.dart';

class AppTextArea extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final int maxLength;
  final int maxLines;

  const AppTextArea({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength = 1000,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}