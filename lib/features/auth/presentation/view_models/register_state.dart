/// Immutable snapshot driving the RegisterPage.
class RegisterState {
  final bool isSubmitting;
  final bool isGoogleLoading;
  final String? errorMessage;
  final bool acceptedTerms;

  const RegisterState({
    this.isSubmitting = false,
    this.isGoogleLoading = false,
    this.errorMessage,
    this.acceptedTerms = true,
  });

  bool get isBusy => isSubmitting || isGoogleLoading;

  static const Object _sentinel = Object();

  RegisterState copyWith({
    bool? isSubmitting,
    bool? isGoogleLoading,
    Object? errorMessage = _sentinel,
    bool? acceptedTerms,
  }) {
    return RegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
    );
  }
}
