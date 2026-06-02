import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/remote/project_remote_data_source.dart';
import '../mappers/project_mapper.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remote;
  const ProjectRepositoryImpl(this._remote);

  @override
  Future<List<Project>> list({ProjectStatus? status}) async {
    final dtos = await _remote.list(status: status?.wire);
    return dtos.map(ProjectMapper.toDomain).toList(growable: false);
  }

  @override
  Future<Project> getById(String id) async {
    final dto = await _remote.getById(id);
    return ProjectMapper.toDomain(dto);
  }

  @override
  Future<Project> create(CreateProjectFields fields) async {
    final dto = await _remote.create({
      'name': fields.name,
      'workType': fields.workType.wire,
      if (fields.description != null) 'description': fields.description,
      if (fields.clientName != null) 'clientName': fields.clientName,
      if (fields.location != null) 'location': fields.location,
      if (fields.area != null) 'area': fields.area,
      if (fields.totalBudget != null) 'totalBudget': fields.totalBudget,
      if (fields.status != null) 'status': fields.status!.wire,
    });
    return ProjectMapper.toDomain(dto);
  }

  @override
  Future<Project> update(String id, UpdateProjectFields changes) async {
    final payload = <String, dynamic>{};
    if (changes.name != null) payload['name'] = changes.name;
    if (changes.workType != null) payload['workType'] = changes.workType!.wire;
    if (changes.description != null) payload['description'] = changes.description;
    if (changes.clientName != null) payload['clientName'] = changes.clientName;
    if (changes.location != null) payload['location'] = changes.location;
    if (changes.area != null) payload['area'] = changes.area;
    if (changes.totalBudget != null) payload['totalBudget'] = changes.totalBudget;
    if (changes.status != null) payload['status'] = changes.status!.wire;
    final dto = await _remote.update(id, payload);
    return ProjectMapper.toDomain(dto);
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
