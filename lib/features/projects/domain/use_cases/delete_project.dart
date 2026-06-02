import '../repositories/project_repository.dart';

class DeleteProject {
  final ProjectRepository _repo;
  const DeleteProject(this._repo);

  Future<void> call(String id) => _repo.delete(id);
}
