import '../entities/project.dart';
import '../repositories/project_repository.dart';

class CreateProject {
  final ProjectRepository _repo;
  const CreateProject(this._repo);

  Future<Project> call(CreateProjectFields fields) {
    if (fields.name.trim().isEmpty) {
      throw const FormatException('El nombre del proyecto no puede estar vacío');
    }
    if (fields.totalBudget != null && !_isValidDecimal(fields.totalBudget!)) {
      throw const FormatException('El presupuesto debe ser un número con hasta 2 decimales');
    }
    return _repo.create(fields);
  }

  bool _isValidDecimal(String raw) => RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(raw);
}
