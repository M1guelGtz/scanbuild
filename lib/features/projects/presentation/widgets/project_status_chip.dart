import 'package:flutter/material.dart';

import '../../../../core/ui/atoms/status_chip.dart';
import '../../domain/entities/project.dart';

/// Bridges the generic StatusChip atom with the ProjectStatus enum. Uses
/// the color scheme shown in the prototype.
class ProjectStatusChip extends StatelessWidget {
  final ProjectStatus status;
  const ProjectStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case ProjectStatus.measured:   color = const Color(0xFFE08A2A); break; // amber
      case ProjectStatus.quoted:     color = const Color(0xFF2F6FED); break; // primary blue
      case ProjectStatus.inProgress: color = const Color(0xFF1F9E5A); break; // green
      case ProjectStatus.completed:  color = const Color(0xFF6B7280); break; // muted gray
    }
    return StatusChip(label: status.label.toUpperCase(), color: color);
  }
}
