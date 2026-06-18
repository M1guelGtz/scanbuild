import '../../../core/network/api_client.dart';
import '../../auth/data/local/token_storage.dart';
import '../../auth/domain/use_cases/try_restore_session.dart';
import '../data/datasources/remote/project_remote_data_source.dart';
import '../data/repositories/project_repository_impl.dart';
import '../domain/entities/project.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/use_cases/create_project.dart';
import '../domain/use_cases/delete_project.dart';
import '../domain/use_cases/get_project.dart';
import '../domain/use_cases/get_projects.dart';
import '../domain/use_cases/update_project.dart';
import '../presentation/view_models/dashboard_view_model.dart';
import '../presentation/view_models/project_detail_view_model.dart';
import '../presentation/view_models/project_form_view_model.dart';

class ProjectsModule {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectRepository repository;

  final GetProjects getProjectsUseCase;
  final GetProject getProjectUseCase;
  final CreateProject createProjectUseCase;
  final UpdateProject updateProjectUseCase;
  final DeleteProject deleteProjectUseCase;

  ProjectsModule._({
    required this.remoteDataSource,
    required this.repository,
    required this.getProjectsUseCase,
    required this.getProjectUseCase,
    required this.createProjectUseCase,
    required this.updateProjectUseCase,
    required this.deleteProjectUseCase,
  });

  factory ProjectsModule.create({
    required ApiClient projectsApiClient,
    required TokenStorage tokenStorage,
  }) {
    final remote = ProjectRemoteDataSource(projectsApiClient, tokenStorage);
    final ProjectRepository repo = ProjectRepositoryImpl(remote);
    return ProjectsModule._(
      remoteDataSource: remote,
      repository: repo,
      getProjectsUseCase: GetProjects(repo),
      getProjectUseCase: GetProject(repo),
      createProjectUseCase: CreateProject(repo),
      updateProjectUseCase: UpdateProject(repo),
      deleteProjectUseCase: DeleteProject(repo),
    );
  }


  ProjectFormViewModel projectFormViewModelFactory({Project? editing}) =>
      ProjectFormViewModel(
        createProject: createProjectUseCase,
        updateProject: updateProjectUseCase,
        editingProject: editing,
      );

  ProjectDetailViewModel projectDetailViewModelFactory(String projectId) =>
      ProjectDetailViewModel(
        getProject: getProjectUseCase,
        deleteProject: deleteProjectUseCase,
        projectId: projectId,
      );

  DashboardViewModel dashboardViewModelFactory({
    required TryRestoreSession tryRestoreSession,
  }) =>
      DashboardViewModel(
        getProjects: getProjectsUseCase,
        deleteProject: deleteProjectUseCase,
        tryRestoreSession: tryRestoreSession,
      );
}
