import '../repositories/auth_repository.dart';


class ExpireSessionForInactivity {
  final AuthRepository _repository;
  const ExpireSessionForInactivity(this._repository);

  Future<void> call({required Duration idleTimeout}) {
    return _repository.expireSessionForInactivity(idleTimeout: idleTimeout);
  }
}
