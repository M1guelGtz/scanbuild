// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/use_cases/try_restore_session.dart';
import '../../domain/entities/project.dart';
import '../../domain/use_cases/delete_project.dart';
import '../../domain/use_cases/get_projects.dart';
import 'dashboard_state.dart';

class DashboardViewModel extends ChangeNotifier {
  final GetProjects _getProjects;
  final DeleteProject _deleteProject;
  final TryRestoreSession _tryRestoreSession;

  DashboardState _state = const DashboardState(isLoading: true);
  DashboardState get state => _state;

  AuthUser? _user;
  AuthUser? get user => _user;

  DashboardViewModel({
    required GetProjects getProjects,
    required DeleteProject deleteProject,
    required TryRestoreSession tryRestoreSession,
  })  : _getProjects = getProjects,
        _deleteProject = deleteProject,
        _tryRestoreSession = tryRestoreSession;

  Future<void> load() async {
    _set(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      _user = await _tryRestoreSession();
    } catch (e, st) {
      debugPrint('tryRestoreSession failed (non-fatal): $e\n$st');
      _user = null;
    }

    List<Project> list;
    try {
      list = await _getProjects();
    } on ApiException catch (e, st) {
      debugPrint('GET /projects failed: ${e.statusCode} ${e.code} ${e.message}\n$st');
      _set(_state.copyWith(isLoading: false, errorMessage: e.message));
      return;
    } catch (e, st) {
      debugPrint('GET /projects threw: $e\n$st');
      _set(_state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el dashboard: $e',
      ));
      return;
    }

    _set(_state.copyWith(isLoading: false, projects: list));
  }

  Future<bool> deleteProject(String id) async {
    try {
      await _deleteProject(id);
      _set(_state.copyWith(
        projects: _state.projects.where((p) => p.id != id).toList(),
      ));
      return true;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: e.message));
      return false;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo eliminar el proyecto.'));
      return false;
    }
  }

  void clearError() {
    if (_state.errorMessage != null) _set(_state.copyWith(errorMessage: null));
  }

  void _set(DashboardState next) {
    _state = next;
    notifyListeners();
  }
}
