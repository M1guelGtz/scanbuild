import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjects {
  final ProjectRepository _repo;
  const GetProjects(this._repo);

  Future<List<Project>> call({ProjectStatus? status}) => _repo.list(status: status);
}
