import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProject {
  final ProjectRepository _repo;
  const GetProject(this._repo);

  Future<Project> call(String id) => _repo.getById(id);
}
