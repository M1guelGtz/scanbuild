import '../../domain/entities/project.dart';

class ProjectFormState {
  final String? editingId;
  final bool isSubmitting;
  final String? errorMessage;
  final WorkType? workType;
  final ProjectStatus status;

  const ProjectFormState({
    this.editingId,
    this.isSubmitting = false,
    this.errorMessage,
    this.workType,
    this.status = ProjectStatus.measured,
  });

  static const Object _sentinel = Object();

  ProjectFormState copyWith({
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    Object? workType = _sentinel,
    ProjectStatus? status,
  }) {
    return ProjectFormState(
      editingId: editingId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      workType:
          workType == _sentinel ? this.workType : workType as WorkType?,
      status: status ?? this.status,
    );
  }
}
