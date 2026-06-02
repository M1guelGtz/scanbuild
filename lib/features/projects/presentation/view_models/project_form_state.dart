import '../../domain/entities/project.dart';

/// Shared state for the add + edit forms. `editingId == null` means "create";
/// otherwise the VM is editing the project with that id.
///
/// Two interactive bits live in state so the view stays declarative:
///   - workType: the selected card in the 2×2 grid (none until tapped).
///   - status: pre-selected when editing, defaulted to measured when creating.
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
