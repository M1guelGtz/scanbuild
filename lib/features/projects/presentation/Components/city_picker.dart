import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
class CityPicker extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const CityPicker({
    super.key,
    required this.controller,
    this.suggestions = const ['Tuxtla Gutiérrez', 'CDMX', 'Guadalajara', 'Tapachula', 'Monterrey'],
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: 'Ciudad',
            prefixIcon: const Icon(Icons.place_outlined,
                color: AppColors.iconMuted, size: 20),
            suffixIcon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.iconMuted, size: 20),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((c) {
            final selected = controller.text.trim().toLowerCase() == c.toLowerCase();
            return _CityChip(
              label: c,
              selected: selected,
              onTap: enabled
                  ? () {
                      controller.text = c;
                      controller.selection =
                          TextSelection.collapsed(offset: c.length);
                      onChanged?.call(c);
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CityChip({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.surface;
    final border = selected ? AppColors.primary : AppColors.border;
    final fg = selected ? Colors.white : AppColors.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
