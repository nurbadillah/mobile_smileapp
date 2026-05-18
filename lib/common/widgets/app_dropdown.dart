import 'package:flutter/material.dart';

class AppDropdownItem {
  final int id;
  final String name;

  AppDropdownItem({
    required this.id,
    required this.name,
  });
}

class AppDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final int? value;
  final List<AppDropdownItem> items;
  final ValueChanged<int?> onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedExists = items.any((item) => item.id == value);

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
        DropdownButtonFormField<int>(
          initialValue: selectedExists ? value : null,
          isExpanded: true,
          hint: Text(hint),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}