import '../../domain/entities/project.dart';

class DashboardState {
  final bool isLoading;
  final List<Project> projects;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.projects = const [],
    this.errorMessage,
  });

  int get activeCount => projects.where((p) => p.status != ProjectStatus.completed).length;

  int get quotedCount => projects.where((p) => p.status == ProjectStatus.quoted).length;

  static const Object _sentinel = Object();

  DashboardState copyWith({
    bool? isLoading,
    List<Project>? projects,
    Object? errorMessage = _sentinel,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}
