import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class TryRestoreSession {
  final AuthRepository _repository;
  const TryRestoreSession(this._repository);

  Future<AuthUser?> call() => _repository.tryRestoreSession();
}
