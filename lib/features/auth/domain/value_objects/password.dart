/// Validates a plaintext password against the same strength rules used by
/// the backend (min 8 chars, ≥1 uppercase, ≥1 digit).
class Password {
  static final RegExp _strength = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

  final String value;
  const Password._(this.value);

  factory Password.create(String raw) {
    if (raw.length < 8) {
      throw const FormatException('La contraseña debe tener al menos 8 caracteres');
    }
    if (raw.length > 128) {
      throw const FormatException('La contraseña no puede tener más de 128 caracteres');
    }
    if (!_strength.hasMatch(raw)) {
      throw const FormatException(
        'La contraseña debe contener al menos una mayúscula y un número',
      );
    }
    return Password._(raw);
  }
}
