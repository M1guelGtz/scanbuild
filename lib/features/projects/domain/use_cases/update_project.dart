import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProject {
  final ProjectRepository _repo;
  const UpdateProject(this._repo);

  Future<Project> call(String id, UpdateProjectFields changes) {
    if (changes.isEmpty) {
      throw const FormatException('No hay cambios para guardar');
    }
    if (changes.name != null && changes.name!.trim().isEmpty) {
      throw const FormatException('El nombre no puede estar vacío');
    }
    if (changes.totalBudget != null && !_isValidDecimal(changes.totalBudget!)) {
      throw const FormatException('El presupuesto debe ser un número con hasta 2 decimales');
    }
    return _repo.update(id, changes);
  }

  bool _isValidDecimal(String raw) => RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(raw);
}
