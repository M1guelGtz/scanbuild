// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/use_cases/delete_project.dart';
import '../../domain/use_cases/get_project.dart';
import 'project_detail_state.dart';

class ProjectDetailViewModel extends ChangeNotifier {
  final GetProject _getProject;
  final DeleteProject _deleteProject;
  final String _projectId;

  ProjectDetailState _state = const ProjectDetailState();
  ProjectDetailState get state => _state;

  ProjectDetailViewModel({
    required GetProject getProject,
    required DeleteProject deleteProject,
    required String projectId,
  })  : _getProject = getProject,
        _deleteProject = deleteProject,
        _projectId = projectId;

  Future<void> load() async {
    _set(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      final project = await _getProject(_projectId);
      _set(_state.copyWith(isLoading: false, project: project));
    } on ApiException catch (e) {
      _set(_state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (_) {
      _set(_state.copyWith(isLoading: false, errorMessage: 'No se pudo cargar el proyecto.'));
    }
  }

  Future<bool> delete() async {
    _set(_state.copyWith(isDeleting: true, errorMessage: null));
    try {
      await _deleteProject(_projectId);
      return true;
    } on ApiException catch (e) {
      _set(_state.copyWith(isDeleting: false, errorMessage: e.message));
      return false;
    } catch (_) {
      _set(_state.copyWith(isDeleting: false, errorMessage: 'No se pudo eliminar el proyecto.'));
      return false;
    }
  }

  void clearError() {
    if (_state.errorMessage != null) _set(_state.copyWith(errorMessage: null));
  }

  void _set(ProjectDetailState next) {
    _state = next;
    notifyListeners();
  }
}
