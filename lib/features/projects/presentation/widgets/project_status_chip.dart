import 'package:flutter/material.dart';

import '../../../../core/ui/atoms/status_chip.dart';
import '../../domain/entities/project.dart';

class ProjectStatusChip extends StatelessWidget {
  final ProjectStatus status;
  const ProjectStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case ProjectStatus.measured:   color = const Color(0xFFE08A2A); break;
      case ProjectStatus.quoted:     color = const Color(0xFF2F6FED); break;
      case ProjectStatus.inProgress: color = const Color(0xFF1F9E5A); break;
      case ProjectStatus.completed:  color = const Color(0xFF6B7280); break;
    }
    return StatusChip(label: status.label.toUpperCase(), color: color);
  }
}
