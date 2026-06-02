import '../repositories/auth_repository.dart';

/// Looks up which account is currently set up for biometric unlock on
/// this device. The ViewModel uses it to decide whether the user who just
/// logged in is the same one already enrolled.
class GetEnrolledEmail {
  final AuthRepository _repository;
  const GetEnrolledEmail(this._repository);

  Future<String?> call() => _repository.getEnrolledEmail();
}
