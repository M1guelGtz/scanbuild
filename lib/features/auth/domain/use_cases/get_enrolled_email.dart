import '../repositories/auth_repository.dart';

class GetEnrolledEmail {
  final AuthRepository _repository;
  const GetEnrolledEmail(this._repository);

  Future<String?> call() => _repository.getEnrolledEmail();
}
