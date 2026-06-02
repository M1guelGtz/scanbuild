enum ProjectStatus { measured, quoted, inProgress, completed }

extension ProjectStatusX on ProjectStatus {
  String get wire {
    switch (this) {
      case ProjectStatus.measured:   return 'MEASURED';
      case ProjectStatus.quoted:     return 'QUOTED';
      case ProjectStatus.inProgress: return 'IN_PROGRESS';
      case ProjectStatus.completed:  return 'COMPLETED';
    }
  }

  /// Short Spanish label shown in status chips ("COTIZADO", "EN OBRA").
  String get label {
    switch (this) {
      case ProjectStatus.measured:   return 'Medido';
      case ProjectStatus.quoted:     return 'Cotizado';
      case ProjectStatus.inProgress: return 'En obra';
      case ProjectStatus.completed:  return 'Completado';
    }
  }

  static ProjectStatus fromWire(String raw) {
    switch (raw) {
      case 'MEASURED':    return ProjectStatus.measured;
      case 'QUOTED':      return ProjectStatus.quoted;
      case 'IN_PROGRESS': return ProjectStatus.inProgress;
      case 'COMPLETED':   return ProjectStatus.completed;
      default:
        throw FormatException('Unknown project status: $raw');
    }
  }
}

enum WorkType { floor, wall, ceiling, combined }

extension WorkTypeX on WorkType {
  String get wire {
    switch (this) {
      case WorkType.floor:    return 'FLOOR';
      case WorkType.wall:     return 'WALL';
      case WorkType.ceiling:  return 'CEILING';
      case WorkType.combined: return 'COMBINED';
    }
  }

  String get label {
    switch (this) {
      case WorkType.floor:    return 'Piso';
      case WorkType.wall:     return 'Pared';
      case WorkType.ceiling:  return 'Techo';
      case WorkType.combined: return 'Combinado';
    }
  }

  /// Uppercase compact label used in the dashboard cards ("COMBINADO", "PARED").
  String get cardLabel => label.toUpperCase();

  static WorkType fromWire(String raw) {
    switch (raw) {
      case 'FLOOR':    return WorkType.floor;
      case 'WALL':     return WorkType.wall;
      case 'CEILING':  return WorkType.ceiling;
      case 'COMBINED': return WorkType.combined;
      default:
        throw FormatException('Unknown work type: $raw');
    }
  }
}

/// Pure domain entity. Decimal values stay as strings ("14.20") to preserve
/// precision from the wire.
class Project {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? clientName;
  final String? location;
  final WorkType workType;
  final String? area;
  final String? totalBudget;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.workType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.clientName,
    this.location,
    this.area,
    this.totalBudget,
  });
}
