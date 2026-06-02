import '../../domain/entities/project.dart';
import '../datasources/remote/dtos/project_dto.dart';

class ProjectMapper {
  const ProjectMapper._();

  static Project toDomain(ProjectDto dto) {
    return Project(
      id: dto.id,
      ownerId: dto.ownerId,
      name: dto.name,
      description: dto.description,
      clientName: dto.clientName,
      location: dto.location,
      workType: WorkTypeX.fromWire(dto.workType),
      area: dto.area,
      totalBudget: dto.totalBudget,
      status: ProjectStatusX.fromWire(dto.status),
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }
}
