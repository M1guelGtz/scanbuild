/// Immutable email value object. Validation mirrors the backend
/// (Email VO in auth-service) so error messages are consistent end-to-end.
class Email {
  static final RegExp _regex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  final String value;
  const Email._(this.value);

  factory Email.create(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const FormatException('El correo no puede estar vacío');
    }
    if (normalized.length > 254) {
      throw const FormatException('El correo es demasiado largo');
    }
    if (!_regex.hasMatch(normalized)) {
      throw const FormatException('El formato del correo es inválido');
    }
    return Email._(normalized);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
