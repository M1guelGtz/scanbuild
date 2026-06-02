import '../../domain/entities/project.dart';

class ProjectDetailState {
  final bool isLoading;
  final bool isDeleting;
  final Project? project;
  final String? errorMessage;

  const ProjectDetailState({
    this.isLoading = true,
    this.isDeleting = false,
    this.project,
    this.errorMessage,
  });

  static const Object _sentinel = Object();

  ProjectDetailState copyWith({
    bool? isLoading,
    bool? isDeleting,
    Object? project = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return ProjectDetailState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      project: project == _sentinel ? this.project : project as Project?,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}
