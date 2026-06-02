import '../entities/project.dart';

class CreateProjectFields {
  final String name;
  final WorkType workType;
  final String? description;
  final String? clientName;
  final String? location;
  final String? area;
  final String? totalBudget;
  final ProjectStatus? status;

  const CreateProjectFields({
    required this.name,
    required this.workType,
    this.description,
    this.clientName,
    this.location,
    this.area,
    this.totalBudget,
    this.status,
  });
}

class UpdateProjectFields {
  final String? name;
  final WorkType? workType;
  final String? description;
  final String? clientName;
  final String? location;
  final String? area;
  final String? totalBudget;
  final ProjectStatus? status;

  const UpdateProjectFields({
    this.name,
    this.workType,
    this.description,
    this.clientName,
    this.location,
    this.area,
    this.totalBudget,
    this.status,
  });

  bool get isEmpty =>
      name == null &&
      workType == null &&
      description == null &&
      clientName == null &&
      location == null &&
      area == null &&
      totalBudget == null &&
      status == null;
}

abstract class ProjectRepository {
  Future<List<Project>> list({ProjectStatus? status});
  Future<Project> getById(String id);
  Future<Project> create(CreateProjectFields fields);
  Future<Project> update(String id, UpdateProjectFields changes);
  Future<void> delete(String id);
}
