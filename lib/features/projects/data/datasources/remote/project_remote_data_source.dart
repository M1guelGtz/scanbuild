import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../auth/data/local/token_storage.dart';
import 'dtos/project_dto.dart';

/// Speaks HTTP to /projects/* of the projects-service. Every request is
/// authenticated with the access token from secure storage; if the token
/// is missing it throws an [ApiException] with code AUTH_ERROR so the UI
/// layer can redirect to login.
class ProjectRemoteDataSource {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  const ProjectRemoteDataSource(this._apiClient, this._tokenStorage);

  Future<List<ProjectDto>> list({String? status}) async {
    final token = await _requireToken();
    final query = status == null ? '' : '?status=$status';
    final json = await _apiClient.getJson('/projects$query', accessToken: token);
    final raw = (json['projects'] as List<dynamic>?) ?? const [];
    return raw
        .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<ProjectDto> getById(String id) async {
    final token = await _requireToken();
    final json = await _apiClient.getJson('/projects/$id', accessToken: token);
    return ProjectDto.fromJson(json['project'] as Map<String, dynamic>);
  }

  Future<ProjectDto> create(Map<String, dynamic> body) async {
    final token = await _requireToken();
    final json = await _apiClient.postJson('/projects', body, accessToken: token);
    return ProjectDto.fromJson(json['project'] as Map<String, dynamic>);
  }

  Future<ProjectDto> update(String id, Map<String, dynamic> changes) async {
    final token = await _requireToken();
    final res = await _apiClient.patch('/projects/$id', changes, accessToken: token);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _apiClient.decodeError(res);
    }
    final body = _apiClient.decodeJson(res);
    return ProjectDto.fromJson(body['project'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final token = await _requireToken();
    final res = await _apiClient.deleteRaw('/projects/$id', accessToken: token);
    if (res.statusCode == 204 || res.statusCode == 200) return;
    throw _apiClient.decodeError(res);
  }

  Future<String> _requireToken() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        code: 'AUTH_ERROR',
        message: 'No hay sesión activa',
      );
    }
    return token;
  }
}
