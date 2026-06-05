import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/project.dart';
class WorkTypeChoiceCard extends StatelessWidget {
  final WorkType workType;
  final bool selected;
  final VoidCallback? onTap;

  const WorkTypeChoiceCard({
    super.key,
    required this.workType,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;
    final border = selected ? accent : AppColors.border;
    final bg = selected ? accent.withValues(alpha: 0.06) : AppColors.surface;
    final fg = selected ? accent : AppColors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(workType), size: 24, color: fg),
            const SizedBox(height: 16),
            Text(
              workType.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(WorkType w) {
    switch (w) {
      case WorkType.floor:    return Icons.crop_square_outlined;
      case WorkType.wall:     return Icons.grid_view_outlined;
      case WorkType.ceiling:  return Icons.cabin_outlined;
      case WorkType.combined: return Icons.dashboard_outlined;
    }
  }
}
