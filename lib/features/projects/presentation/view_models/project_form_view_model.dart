// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/use_cases/create_project.dart';
import '../../domain/use_cases/update_project.dart';
import 'project_form_state.dart';
class ProjectFormViewModel extends ChangeNotifier {
  final CreateProject _createProject;
  final UpdateProject _updateProject;
  final Project? _editingProject;

  late ProjectFormState _state;
  ProjectFormState get state => _state;

  Project? get editingProject => _editingProject;
  bool get isEditing => _editingProject != null;

  ProjectFormViewModel({
    required CreateProject createProject,
    required UpdateProject updateProject,
    Project? editingProject,
  })  : _createProject = createProject,
        _updateProject = updateProject,
        _editingProject = editingProject {
    _state = ProjectFormState(
      editingId: editingProject?.id,
      workType: editingProject?.workType,
      status: editingProject?.status ?? ProjectStatus.measured,
    );
  }

  void setWorkType(WorkType workType) {
    _set(_state.copyWith(workType: workType));
  }

  void setStatus(ProjectStatus status) {
    _set(_state.copyWith(status: status));
  }

  void clearError() {
    if (_state.errorMessage != null) _set(_state.copyWith(errorMessage: null));
  }

  Future<Project?> save({
    required String name,
    String? description,
    String? clientName,
    String? location,
    String? area,
    String? totalBudget,
  }) async {
    if (_state.isSubmitting) return null;

    final workType = _state.workType;
    if (workType == null) {
      _set(_state.copyWith(errorMessage: 'Selecciona un tipo de trabajo.'));
      return null;
    }

    _set(_state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final Project saved;
      if (isEditing) {
        saved = await _updateProject(
          _editingProject!.id,
          UpdateProjectFields(
            name: name,
            workType: workType,
            description: description?.isEmpty == true ? null : description,
            clientName: clientName?.isEmpty == true ? null : clientName,
            location: location?.isEmpty == true ? null : location,
            area: area?.isEmpty == true ? null : area,
            totalBudget: totalBudget?.isEmpty == true ? null : totalBudget,
            status: _state.status,
          ),
        );
      } else {
        saved = await _createProject(
          CreateProjectFields(
            name: name,
            workType: workType,
            description: description?.isEmpty == true ? null : description,
            clientName: clientName?.isEmpty == true ? null : clientName,
            location: location?.isEmpty == true ? null : location,
            area: area?.isEmpty == true ? null : area,
            totalBudget: totalBudget?.isEmpty == true ? null : totalBudget,
            status: _state.status,
          ),
        );
      }
      return saved;
    } on FormatException catch (e) {
      _set(_state.copyWith(errorMessage: e.message));
      return null;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: e.message));
      return null;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo guardar el proyecto.'));
      return null;
    } finally {
      _set(_state.copyWith(isSubmitting: false));
    }
  }

  void _set(ProjectFormState next) {
    _state = next;
    notifyListeners();
  }
}
